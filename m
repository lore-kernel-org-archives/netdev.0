From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: avoid csum_partial() for validated skb
Date: Wed, 01 Jun 2016 17:41:51 -0700 (PDT)
Message-ID: <20160601.174151.1773614070251060832.davem@davemloft.net>
References: <1464733361.5939.130.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samanthakumar@google.com, willemb@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbcFBAlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 20:41:55 -0400
In-Reply-To: <1464733361.5939.130.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 May 2016 15:22:41 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit e6afc8ace6dd5 ("udp: remove headers from UDP packets before
> queueing"), udp_csum_pull_header() helper was added but missed fact
> that CHECKSUM_UNNECESSARY packets were now converted to CHECKSUM_NONE
> and skb->csum_valid was set to 1 for them.
> 
> Since csum_partial() is quite expensive, even for 8-byte area, it is
> worth adding a test.
> 
> We also can use skb->data instead of udp_hdr() as we are pulling
> UDP headers, as it is sightly faster.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
