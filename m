From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Wed, 01 May 2013 03:36:50 -0400 (EDT)
Message-ID: <20130501.033650.703182794549888825.davem@davemloft.net>
References: <1367370761.11020.22.camel@edumazet-glaptop>
	<1367372393.22115.6.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, paulus@samba.org,
	ambrose@google.com, linuxppc-dev@lists.ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509Ab3EAHgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 03:36:54 -0400
In-Reply-To: <1367372393.22115.6.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 01 May 2013 11:39:53 +1000

> I'm not even completely certain bytes are safe to be honest, though
> probably more than bitfields. I'll poke our compiler people.

Older Alpha only has 32-bit and 64-bit loads and stores, so byte sized
accesses are not atomic, and therefore use racey read-modify-write
sequences.
