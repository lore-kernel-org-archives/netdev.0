From: David Miller <davem@davemloft.net>
Subject: skb_shared_info()
Date: Tue, 08 Aug 2006 16:39:15 -0700 (PDT)
Message-ID: <20060808.163915.03600382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60577
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030333AbWHHXjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 19:39:10 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm beginning to think that where we store the
skb_shared_info() is a weakness of the SKB design.

It makes it more difficult to have local memory
management schemes and to just wrap SKB's around
arbitrary pieces of data.

The e1000 issue is just one example of this, another
would be any attempt to consolidate the TCP retransmit
queue data management.

How to deal with data refcounting and destruction is
the primary matter to deal with if we want to move
skb_shared_info() somewhere else.  But that can probably
be handled with a data destructor callback of some sort
which we're always talking about adding anyways. :)
