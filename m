From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: net: allow handlers to be processed for orig_dev
Date: Tue, 1 Mar 2011 07:43:56 +0100
Message-ID: <20110301064355.GE2855@psychotron.redhat.com>
References: <20110301062631.GC2855@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39039 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755008Ab1CAGn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 01:43:59 -0500
Content-Disposition: inline
In-Reply-To: <20110301062631.GC2855@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ou, forgot [PATCH net-next-2.6] - sorry

Tue, Mar 01, 2011 at 07:26:31AM CET, jpirko@redhat.com wrote:
>This was there before, I forgot about this. Allows deliveries to
>ptype_base handlers registered for orig_dev. I presume this is still
>desired.
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>---
> net/core/dev.c |    3 ++-
> 1 files changed, 2 insertions(+), 1 deletions(-)
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 30440e7..9f66de9 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -3208,7 +3208,8 @@ ncls:
> 	list_for_each_entry_rcu(ptype,
> 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
> 		if (ptype->type == type &&
>-		    (ptype->dev == null_or_dev || ptype->dev == skb->dev)) {
>+		    (ptype->dev == null_or_dev || ptype->dev == skb->dev ||
>+		     ptype->dev == orig_dev)) {
> 			if (pt_prev)
> 				ret = deliver_skb(skb, pt_prev, orig_dev);
> 			pt_prev = ptype;
>-- 
>1.7.3.4
>
