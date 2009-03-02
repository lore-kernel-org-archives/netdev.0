From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Tue, 03 Mar 2009 00:03:00 +0100
Message-ID: <49AC65A4.6020908@trash.net>
References: <20090227103812.14af52b3@nehalam>	<49AC597B.4090404@candelatech.com>	<49AC5BC1.3030901@trash.net> <20090302.144725.223672439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, shemminger@vyatta.com,
	ebiederm@xmission.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56489 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757933AbZCBXDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 18:03:07 -0500
In-Reply-To: <20090302.144725.223672439.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 02 Mar 2009 23:20:49 +0100
> 
>> This looks like its working fine. Despite the non-desirable active
>> spinning, this seems like the best fix (actually much simpler than
>> I expected to be possible) at this time. If we just could avoid
>> the spinning when unnecessary, it would be perfect :)
> 
> Could you give that "not actually in-progress" detection a shot?
> 
> I don't like the spinning either.


I tried this morning, the problem is that its always the sysctl
handler which will run into the deadlock first, but there is no
reliable indication to avoid it other than that the RTNL is
already held. The problem is that the sysctl interface puts the
process holding the RTNL to sleep and allows a process requiring
it to run. Any different synchronization attempt will have the
same problem, it seems you simply can't hold any locks while
unregistering sysctls.
