From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/15]: More SKB list abstrations, this time frag lists
Date: Tue, 09 Jun 2009 05:01:47 -0700 (PDT)
Message-ID: <20090609.050147.83763570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755051AbZFIMBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:01:45 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 28D59C8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:01:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This adds some interface butter to skbuff.h so that we can (begin)
getting rid of explicit references to how frag lists of skbs are
managed.

I couldn't kill every such reference just yet.  Some things are
hard to abstract.

Looking forward I did some work to see what happens if we use
a list_head for the frag lists.  It doesn't work right unless
we clone all frag list SKBs during a pskb_copy() for example.

The single linked list we have no lets us just copy the head
skb->next pointer and bump SKB ref counts, so we may keep it
that way in the end.

Anyways, most of this is mechanical and will be pushed out to
net-next-2.6 in a few moments.
