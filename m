From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2 1/5] pktgen: fix crash when generating IPv6 packets
Date: Wed, 10 Oct 2012 22:33:54 -0400 (EDT)
Message-ID: <20121010.223354.756507387487997570.davem@davemloft.net>
References: <1349840900-24138-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58729 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159Ab2JKCd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 22:33:57 -0400
In-Reply-To: <1349840900-24138-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 10 Oct 2012 11:48:16 +0800

> For IPv6, sizeof(struct ipv6hdr) = 40, thus the following
> expression will result negative:
> 
>         datalen = pkt_dev->cur_pkt_size - 14 -
>                   sizeof(struct ipv6hdr) - sizeof(struct udphdr) -
>                   pkt_dev->pkt_overhead;
> 
> And,  the check "if (datalen < sizeof(struct pktgen_hdr))" will be
> passed as "datalen" is promoted to unsigned, therefore will cause
> a crash later.
> 
> This is a quick fix by checking if "datalen" is negative. The following
> patch will increase the default value of 'min_pkt_size' for IPv6.
> 
> This bug should exist for a long time, so Cc -stable too.
> 
> Cc: <stable@vger.kernel.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
