From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Linux sends IPv6 NS packets with the link-local address
Date: Thu, 7 Nov 2013 02:16:40 +0100
Message-ID: <20131107011640.GE8144@order.stressinduktion.org>
References: <20131107002946.GA16324@sesse.net> <20131107004610.GB8144@order.stressinduktion.org> <20131107005615.GA21230@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, ayourtch@gmail.com
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54444 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805Ab3KGBQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 20:16:41 -0500
Content-Disposition: inline
In-Reply-To: <20131107005615.GA21230@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 01:56:15AM +0100, Steinar H. Gunderson wrote:
> On Thu, Nov 07, 2013 at 01:46:11AM +0100, Hannes Frederic Sowa wrote:
> > Problem was, if we enqueue a packet to the resolving queue we use those
> > packets source address as the address we use as the source address. This
> > patch chooses the last enqueued skb's source address to do the resolving
> > thus switching over to a global address much more early (hopefully). I
> > have seen this problem with routers doing uRPF on the source address of
> > arp packets, too.
> > 
> > Does this happen when you configure addresses? Do your addresses have
> > a short lifetime advertised by radvd etc?
> 
> There are no autoconfigured addresses on the machine; statically set plus
> link-layer only. It does _serve_ RA for another VLAN, though (it does
> 802.1q, some tunnels, and some BGP).

Ok, still the patch should improve the situation if the first packet queued up
used the ll-address as source.

Greetings,

  Hannes
