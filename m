From: David Miller <davem@davemloft.net>
Subject: Re: many sockets, slow sendto
Date: Wed, 21 Mar 2007 18:14:16 -0700 (PDT)
Message-ID: <20070321.181416.71097141.davem@davemloft.net>
References: <4600592E.80605@fw.hu>
	<460064C6.5030302@cosmosbay.com>
	<4601A949.2000005@fw.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, baruch@ev-en.org, netdev@vger.kernel.org
To: zacco@fw.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49583
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932473AbXCVBOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 21:14:16 -0400
In-Reply-To: <4601A949.2000005@fw.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zacco <zacco@fw.hu>
Date: Wed, 21 Mar 2007 22:53:13 +0100

> Do you think there is interest in such a modification? If so, how could 
> we go on with it?

The best thing you can do is hash on both saddr/sport.  In order
to handle the saddr==0 case the socket lookup has to try two
lookups, one with the packets saddr, and one with saddr zero.
If the first lookup hits, we use that, since a precise match
should match over one to a wildcard saddr, otherwise we use the
result of the second lookup.

I'm not very inclined to hack on this, so anyone else is welcome
to.

FWIW, pretty much every other networking stack only hashes on sport
for UDP, just like Linux.
