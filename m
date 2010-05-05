From: Brian Haley <brian.haley@hp.com>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Wed, 05 May 2010 11:36:31 -0400
Message-ID: <4BE1907F.40903@hp.com>
References: <OF8BB88147.4F3756DA-ON88257719.002A895A-88257719.002AEB08@us.ibm.com>	<20100504.005757.97355845.davem@davemloft.net>	<4BE031FA.6040006@hp.com> <20100504.144647.157477097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, enh@google.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:45741 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760536Ab0EEPgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 11:36:43 -0400
In-Reply-To: <20100504.144647.157477097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Brian Haley <brian.haley@hp.com>
> Date: Tue, 04 May 2010 10:40:58 -0400
> 
>> Specifying -1 for setsockopt(IPV6_MULTICAST_HOPS) should set the socket
>> value back to the system default value of IPV6_DEFAULT_MCASTHOPS (1).
>>
>> Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> In cast it wasn't clear from my other reply, I'm not applying this
> patch because I intentionally left this behavior there based upon
> some comments from Elliot in that this lets developers get the
> old default by asking for "-1" explicitly with a setsockopt.

I now see that in Elliot's email, but I think it's incorrect.  The RFC
says that setting it to -1 should get you the kernel default, which is
now 1.  Without this change, setting it to -1 will get you 64, the
old behavior.  If the user wants to, they can always just set it to
64 themselves, that's better than assuming when you set it to -1
you're going to get 64.

I'm just trying to make this follow the RFC and behave like other OSes
for consistency.

-Brian
