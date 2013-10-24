From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] ipv6: reset dst.expires value when clearing
 expire flag
Date: Wed, 23 Oct 2013 23:36:53 -0700
Message-ID: <1382596613.7572.42.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131024054816.GB5973@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgunderson@bigfoot.com, valentyn@blub.net,
	yoshfuji@linux-ipv6.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:58656 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775Ab3JXGg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 02:36:57 -0400
Received: by mail-ea0-f181.google.com with SMTP id d10so953191eaj.12
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 23:36:56 -0700 (PDT)
In-Reply-To: <20131024054816.GB5973@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-24 at 07:48 +0200, Hannes Frederic Sowa wrote:
> On receiving a packet too big icmp error we update the expire value by
> calling rt6_update_expires. This function uses dst_set_expires which is
> implemented that it can only reduce the expiration value of the dst entry.
> 
> If we insert new routing non-expiry information into the ipv6 fib where
> we already have a matching rt6_info we only clear the RTF_EXPIRES flag
> in rt6i_flags and leave the dst.expires value as is.
> 
> When new mtu information arrives for that cached dst_entry we again
> call dst_set_expires. This time it won't update the dst.expire value
> because we left the dst.expire value intact from the last update. So
> dst_set_expires won't touch dst.expires.
> 
> Fix this by resetting dst.expires when clearing the RTF_EXPIRE flag.
> dst_set_expires checks for a zero expiration and updates the
> dst.expires.
> 
> In the past this (not updating dst.expires) was necessary because
> dst.expire was placed in a union with the dst_entry *from reference. So
> an update on the value would have caused page faults. This split happend
> in ecd9883724b78cc72ed92c98bcb1a46c764fff21 ("ipv6: fix race condition
> regarding dst->expires and dst->from").
> 

Well, this patch removed the :

rt->dst.from = NULL;

from rt6_clean_expires(), right ?

Acked-by: Eric Dumazet <edumazet@google.com>
