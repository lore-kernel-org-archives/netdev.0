From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv6 routing type - not at par with IPv4 one?
Date: Thu, 06 Sep 2012 12:35:05 +0200
Message-ID: <1346927705.2484.22.camel@edumazet-glaptop>
References: <loom.20120906T115737-277@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Markus Stenberg <markus.stenberg@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62159 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754428Ab2IFKfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 06:35:09 -0400
Received: by eekc1 with SMTP id c1so613011eek.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 03:35:08 -0700 (PDT)
In-Reply-To: <loom.20120906T115737-277@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 10:02 +0000, Markus Stenberg wrote:
> ~ # ip route add throw 1.2.3.4
> ~ # ip -6 route add throw ::1.2.3.4
> RTNETLINK answers: No such device
> ~ # ip route add blackhole 1.2.3.5
> ~ # ip -6 route add blackhole ::1.2.3.5
> RTNETLINK answers: No such device
> ~ #
> 
> The reason for this is in net/ipv6/route.c - ipv6_route_add:
> 
> Eventually code winds up at this (1423 line in 3.5.3):
> 
> 	err = -ENODEV;
> 	if (!dev)
> 		goto out;
> 
> and poof, ENODEV.
> 
> Is there some reason for this? Or should I write a patch? 
> Or does someone else want to? Support for dev=NULL 
> elsewhere in the code seems to be ok.
> 
> Based on quick googling I'm not the first one to have encountered this.

Well, it  seems you missed this : 

http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=commitdiff;h=ef2c7d7b59708d54213c7556a82d14de9a7e4475

At least the blackhole is now supported on IPv6, so you probably have to
add the 'throw' bit, if it makes any sense.
