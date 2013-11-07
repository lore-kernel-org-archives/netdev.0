From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Linux sends IPv6 NS packets with the link-local address
Date: Thu, 7 Nov 2013 01:46:11 +0100
Message-ID: <20131107004610.GB8144@order.stressinduktion.org>
References: <20131107002946.GA16324@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, ayourtch@gmail.com
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54364 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044Ab3KGAqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 19:46:12 -0500
Content-Disposition: inline
In-Reply-To: <20131107002946.GA16324@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steinar,

On Thu, Nov 07, 2013 at 01:29:46AM +0100, Steinar H. Gunderson wrote:
> Since this is a SHOULD, there's nothing inherently _illegal_ about sending the
> packets with the link-layer address as source, but the RFC does have a point.
> Most of the time, Linux indeed seems to be sending with the global source
> address (heeding the SHOULD), and again, for some reason it suddenly switches
> to it in this case.
> 
> Would anyone happen to know why it uses the link-local in the first place,
> and why it suddenly changes its mind after ten tries or so? I'm not sure if I
> can _force_ this behavior, but judging from a tcpdump, it happens many times
> a day from that specific machine.

I am currently a bit busy to look into this closely but maybe there is
a patch which does help; it is currently in net-next:

<https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/net/core/neighbour.c?id=4ed377e36ec2f385484d12e516faf88516fad31c>

Problem was, if we enqueue a packet to the resolving queue we use those
packets source address as the address we use as the source address. This
patch chooses the last enqueued skb's source address to do the resolving
thus switching over to a global address much more early (hopefully). I
have seen this problem with routers doing uRPF on the source address of
arp packets, too.

Does this happen when you configure addresses? Do your addresses have
a short lifetime advertised by radvd etc?

Greetings,

  Hannes
