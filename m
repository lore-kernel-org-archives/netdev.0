From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Initial benchmarks of some VJ ideas [mmap memcpy vs
 copy_to_user].
Date: Wed, 10 May 2006 12:58:48 -0700 (PDT)
Message-ID: <20060510.125848.44052388.davem@davemloft.net>
References: <20060508122418.GA22554@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40363
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751499AbWEJT7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 15:59:23 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060508122418.GA22554@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 8 May 2006 16:24:22 +0400

> I hope he does not take offence at name shortening :)

Perhaps you are still not convinced how truly expensive the code path
from netif_receive_skb() to the protocol receive processing really is.

Van's channels eliminate that entire code path, and all it's data
structure references and locks, completely.  And by foregoing all of
those data references and expensive locks, we free up precious cpu
cache space and cpu cycles for other work.

Because you cannot "simulate" the extra cache lines that are available
by eliminating the code path between netif_receive_skb() and udp_rcv()
you will really need to compare with a full implementation of channels
to say anything for certain.

And we've known that getting rid of this code path is necessary for
_AGES_.  Ask anyone who has been to any of the yearly Linux networking
conferences, over and over again we talk about a grand unified flow
cache that would turn all of the routing, netfilter, and socket lookups
into one lookup.

All of these lookups touch different data structures, have different
locking rules, and have very poor cache behavior.

Van gets the transformation into a single lookup as a side effect of
how his channels work.

It is absolutely necessary to find ways to get rid of these layering
costs.  "Layering is how you design networking protocols, not how you
implement them."
