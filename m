From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 0/4] net: define accessors to get/set skb->dst and skb->rtable
Date: Tue, 02 Jun 2009 17:12:13 +0200
Message-ID: <4A25414D.6040605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58125 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752975AbZFBPMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 11:12:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David

Here are patches I originally cooked to review all places that could need skb->dst

I believe they could be applied in net-next-2.6 because we could then
implement what we discussed in last december, about avoiding
refcounting on dst_entries in input path (thread about IP_PKTINFO stuff,
and a patch we had to revert)

You suggested to use the low order bit of skb->dst to tell if we got a
refcount or not.

These four patches implement grounding for this idea (no functional changes yet)

Next step is adding the low order bit handling (or another bit if it happens
to be too expensive to check this bit each time we want skb->dst, we
still have to benchmark this)


First patchs adds _skb_dst opaque field in existing union

Second patch removes skb->rtable field and implements skb_rtable() method :

struct rtable *skb_rtable(const struct sk_buff *skb)

Third patch removes skb->dst field and implements several methods :

struct dst_entry *skb_dst(const struct sk_buff *skb)
void skb_dst_set(struct sk_buff *skb, struct dst_entry *dst)
void skb_dst_drop(struct sk_buff *skb)
(skb_dst_drop() is not yet necessary but prepares next patches)

Fourth patch is a cleanup, avoiding the mono-field anonymous union.

Thank you


