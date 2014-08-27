From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 15:56:51 +0200
Message-ID: <20140827155651.04fe49d0@redhat.com>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	<1409142672.26515.24.camel@localhost>
	<1409145838.3173.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32760 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933404AbaH0N5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 09:57:07 -0400
In-Reply-To: <1409145838.3173.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Aug 2014 06:23:58 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> I am afraid Jesper tests are not complete to truly have a picture of the
> extra costs, because he made sure no false sharing was possible (A
> single cpu does everything and keeps skb in its cache)

I fully agree. My tests a very artificial benchmarks only for the
optimal case.

I do worry a bit, if writing skb->xmit_more in a more cache cold
scenarios could hurt us (as that cacheline seems to be read mostly),
but this is not a problem right now because it will always be cache
hot, as we always clear the entire SKB in alloc.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
