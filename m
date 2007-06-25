From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC SKBUFF]: Keep track of writable header len of headerless
 clones
Date: Mon, 25 Jun 2007 10:53:52 +0200
Message-ID: <467F82A0.3070801@trash.net>
References: <467E6950.4020707@trash.net> <20070624.193751.46198776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62632 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094AbXFYIya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 04:54:30 -0400
In-Reply-To: <20070624.193751.46198776.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Sun, 24 Jun 2007 14:53:36 +0200
>
>   
>> - sendmsg eth0, no NAT:		sys     0m2.508s
>> - sendmsg eth0, NAT:		sys     0m2.539s
>> - sendmsg eth0, NAT + patch:	sys     0m2.445s	(no change)
>>     
>
> This is probably because we're touching all the data anyways
> and if the resident set size is small enough (as a gigabit
> or 100MB ethernet TCP stream window would be) then it all fits
> mostly in the L2 caches of the cpu.

Yeah, thats what I suspected too. On loopback it seems to exceed
the cache size, which is a bit strange since its 1MB. Or maybe
there is some loopback optimization interfering.

