From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2 / match / meta bug?
Date: Tue, 29 Jul 2008 07:54:05 +0200
Message-ID: <488EB07D.50406@trash.net>
References: <200807290843.29447.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40481 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668AbYG2Fy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 01:54:59 -0400
In-Reply-To: <200807290843.29447.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> Kernel 2.6.26, iproute2 latest release. All required modules is loaded.
> What did i miss or doing wrong?
>
> tc filter add dev ifb0 protocol all basic match "meta(rt_iif eq tap0)" classid 1:100 
>
> tc -s -d filter show dev ifb0
> filter parent 1: protocol all pref 49152 basic
> filter parent 1: protocol all pref 49152 basic handle 0x1 flowid 1:100
>   meta(-1 eq -1)
>
> Whatever i try - it doesn't work
> ./tc filter add dev ifb0 protocol all basic match meta \(rt_iif eq tap0\) classid 1:100
>   

You probably need to add support for skb->iif in case the
packet didn't went through IPv4.
