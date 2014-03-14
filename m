From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] flowcache: Tune per cpu flow cache shrink size
Date: Fri, 14 Mar 2014 11:26:25 +0100
Message-ID: <20140314102625.GJ32371@secunet.com>
References: <1394782966-9792-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43607 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662AbaCNK02 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 06:26:28 -0400
Content-Disposition: inline
In-Reply-To: <1394782966-9792-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 14, 2014 at 03:42:46PM +0800, Fan Du wrote:
> When per cpu flow cache entries count reaches over high_watermark,
> flow cache will be shrinked gently to around low_watermark, not
> brutally killing most of cached entries by left only two.
> 

We currently keep two entries per hash bucket, this means that
we keep low_watermark entries at most in the flow cache.

With your change, we would keep low_watermark entries per hash bucket.
The flow cache would grow to low_watermark * flow_cache_hash_size then.
This would make DoS attacks against the flow cache quite easy.
