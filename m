From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND][PATCH 1/3] PPPoE: improved hashing routine
Date: Tue, 31 Jul 2007 01:26:09 -0700 (PDT)
Message-ID: <20070731.012609.41193630.davem@davemloft.net>
References: <20070729060423.GA27573@florz.florz.dyndns.org>
	<20070730.174721.17862949.davem@davemloft.net>
	<20070731080719.GA12071@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@earthlink.net, netdev@vger.kernel.org
To: florz@florz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32973
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752235AbXGaI0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 04:26:10 -0400
In-Reply-To: <20070731080719.GA12071@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Zumbiehl <florz@florz.de>
Date: Tue, 31 Jul 2007 10:07:19 +0200

> Erm, I'd say this not only produces different results than the old
> version, but it also produces "wrong" results, in that it ignores quite
> a bit of the data that's supposed to be hashed. If I didn't overlook
> something, it only considers addr&0x0f0f0f0f0f00 and sid&0x0f0f, given
> the right endianness of addr and that PPPOE_HASH_SIZE stays 16.

You're right, I need to fix the shifts up.  How does this version
look?

	hash ^= (hash >> 4) ^ (hash >> 12) ^ (hash >> 20);
	return (head ^ (hash >> 8) ^ (hash >> 24)) &
		(PPPOE_HASH_SIZE - 1);

Actually it might be simpler and more efficient to just make
PPPOE_HASH_SHIFT be 8.
