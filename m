From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFC crap-patch [PATCH] net: Per CPU separate frag mem accounting
Date: Thu, 14 Mar 2013 20:59:03 +0000
Message-ID: <1363294743.2695.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130308221647.5312.33631.stgit@dragon>
	 <20130308221744.5312.14924.stgit@dragon>
	 <1363245955.14913.21.camel@localhost> <1363251561.14913.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<netdev@vger.kernel.org>, <yoshfuji@linux-ipv6.org>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13490 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687Ab3CNU7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 16:59:11 -0400
In-Reply-To: <1363251561.14913.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-14 at 09:59 +0100, Jesper Dangaard Brouer wrote:
> On Thu, 2013-03-14 at 08:25 +0100, Jesper Dangaard Brouer wrote:
> > This is NOT the patch I just mentioned in the other thread, of removing
> > the LRU list.  This patch does real per cpu mem acct, and LRU per CPU.
> > 
> > I get really good performance number with this patch, but I still think
> > this might not be the correct solution.
> 
> The reason is this depend on fragments entering the same HW queue, some
> NICs might not put the first fragment (which have the full header
> tuples) and the remaining fragments on the same queue. In which case
> this patch will loose its performance gain.
[...]

The Microsoft RSS spec only includes port numbers in the flow hash for
TCP, presumably because TCP avoids IP fragmentation whereas datagram
protocols cannot.  Some Linux drivers allow UDP ports to be included in
the flow hash but I don't think this is the default for any of them.

In Solarflare hardware the IPv4 MF bit inhibits layer 4 flow steering,
so all fragments will be unsteered.  I don't know whether everyone else
got that right though. :-)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
