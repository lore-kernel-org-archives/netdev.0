From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize 	modifications
Date: Fri, 05 Feb 2010 12:22:17 +0100
Message-ID: <4B6BFF69.6050503@trash.net>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net>	 <4B6AFE22.20304@trash.net> <20100204194744.GA4185@x200>	 <4B6BEC23.8020101@trash.net> <4B6BFE29.1040204@trash.net> <b6fcc0a1002050319p2ba0ff30y4bc8bdba08ff65d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jonathan@jonmasters.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34178 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015Ab0BELWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 06:22:20 -0500
In-Reply-To: <b6fcc0a1002050319p2ba0ff30y4bc8bdba08ff65d9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> On Fri, Feb 5, 2010 at 1:16 PM, Patrick McHardy <kaber@trash.net> wrote:
>> OK testing looks fine, although I'm quite surprised that its actually
>> possible to change module parameters from within non-init namespaces.
>> How is this supposed to work at all? I don't see how sysfs could
>> possibly provide a network namespace context ...
> 
> 
> You can do in write hook
> 
>     if (!net_eq(current->nsproxy->net_ns, &init_net))
>             return -EINVAL;

Right, I see. So we could actually make resizing work for all
namespaces quite easily. Is there any reason not to do this?
