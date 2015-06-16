From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
Date: Tue, 16 Jun 2015 10:21:10 +0200
Message-ID: <20150616102110.55208fdd@redhat.com>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155256.18824.42651.stgit@devil>
	<20150616072806.GC13125@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>, brouer@redhat.com
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54552 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756277AbbFPIVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 04:21:15 -0400
In-Reply-To: <20150616072806.GC13125@js1304-P5Q-DELUXE>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 16 Jun 2015 16:28:06 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> Is this really better than just calling __kmem_cache_free_bulk()?

Yes, as can be seen by cover-letter, but my cover-letter does not seem
to have reached mm-list.

Measurements for the entire patchset:

Bulk - Fallback bulking           - fastpath-bulking
   1 -  47 cycles(tsc) 11.921 ns  -  45 cycles(tsc) 11.461 ns   improved  4.3%
   2 -  46 cycles(tsc) 11.649 ns  -  28 cycles(tsc)  7.023 ns   improved 39.1%
   3 -  46 cycles(tsc) 11.550 ns  -  22 cycles(tsc)  5.671 ns   improved 52.2%
   4 -  45 cycles(tsc) 11.398 ns  -  19 cycles(tsc)  4.967 ns   improved 57.8%
   8 -  45 cycles(tsc) 11.303 ns  -  17 cycles(tsc)  4.298 ns   improved 62.2%
  16 -  44 cycles(tsc) 11.221 ns  -  17 cycles(tsc)  4.423 ns   improved 61.4%
  30 -  75 cycles(tsc) 18.894 ns  -  57 cycles(tsc) 14.497 ns   improved 24.0%
  32 -  73 cycles(tsc) 18.491 ns  -  56 cycles(tsc) 14.227 ns   improved 23.3%
  34 -  75 cycles(tsc) 18.962 ns  -  58 cycles(tsc) 14.638 ns   improved 22.7%
  48 -  80 cycles(tsc) 20.049 ns  -  64 cycles(tsc) 16.247 ns   improved 20.0%
  64 -  87 cycles(tsc) 21.929 ns  -  74 cycles(tsc) 18.598 ns   improved 14.9%
 128 -  98 cycles(tsc) 24.511 ns  -  89 cycles(tsc) 22.295 ns   improved  9.2%
 158 - 101 cycles(tsc) 25.389 ns  -  93 cycles(tsc) 23.390 ns   improved  7.9%
 250 - 104 cycles(tsc) 26.170 ns  - 100 cycles(tsc) 25.112 ns   improved  3.8%

I'll do a compare against the previous patch, and post the results.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
