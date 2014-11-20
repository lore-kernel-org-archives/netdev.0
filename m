From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question on bulk dequeue support in virtual drivers
Date: Thu, 20 Nov 2014 07:26:28 -0800
Message-ID: <1416497188.8629.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <546DE110.8060607@openvpn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: James Yonan <james@openvpn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:39329 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418AbaKTP0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 10:26:30 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so2940301iec.22
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 07:26:30 -0800 (PST)
In-Reply-To: <546DE110.8060607@openvpn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-20 at 05:39 -0700, James Yonan wrote:
> Consider a tunneling driver that receives packets in ndo_start_xmit, 
> encapsulates them in UDP, and forwards via ip_local_out.  The 
> ndo_start_xmit implementation can implement bulking by looking at 
> skb->xmit_more.  But then how to efficiently transmit the resulting 
> bulked list of encapsulated packets via UDP, so that the packets both 
> enter and leave the driver in bulked form?  Is there an ip_local_out 
> alternative for bulked skb lists?

There is no such thing. Quite frankly it wont happen. Consider IP stacks
and netfilter, there is no provision for batches (other than GSO/TSO)

xmit_more addresses a specific hardware problem, it is not an
alternative for batches.

xmit_more will happen in your case in the last step, from qdisc to
ethernet device.
