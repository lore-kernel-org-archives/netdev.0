From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fq_codel with 802.15.4 6LoWPAN fragmentation issue
Date: Fri, 16 Jan 2015 05:04:16 -0800
Message-ID: <1421413456.11734.125.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150116120232.GD10068@omega>
	 <1421413071.11734.120.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1421413211.11734.121.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wpan@vger.kernel.org,
	stephen@networkplumber.org, jukka.rissanen@linux.intel.com
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:41179 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349AbbAPNES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 08:04:18 -0500
In-Reply-To: <1421413211.11734.121.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-16 at 05:00 -0800, Eric Dumazet wrote:
> On Fri, 2015-01-16 at 04:57 -0800, Eric Dumazet wrote:
> >  example :
> > 
> 
> Sorry, one keyword was missing :
> 
> tc qdisc replace dev lowpan0 root fq_codel interval XXX
> 

But the parameter that you probably want to change is not the interval.
It is probably the target :

tc qdisc replace dev lowpan0 root fq_codel interval 200ms target 25ms

Now, if the fragmentation was done after qdisc dequeue, as in GSO layer,
you would not have this issue : all segments of one ipv6 message would
be transmitted, no matter what.
