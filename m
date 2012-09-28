From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 4/5] be2net: get rid of AMAP_SET/GET macros in
 TX path
Date: Fri, 28 Sep 2012 02:40:34 -0400 (EDT)
Message-ID: <20120928.024034.1426515423229309957.davem@davemloft.net>
References: <92de1988-73db-4864-bf19-10ed11dac557@CMEXHTCAS2.ad.emulex.com>
	<20120927.222900.1633352325278735069.davem@davemloft.net>
	<CF9D1877D81D214CB0CA0669EFAE020C6562EE@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995Ab2I1Gkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 02:40:37 -0400
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C6562EE@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Date: Fri, 28 Sep 2012 05:47:25 +0000

> endianness is handled even in this patch. The call to wrb_fill_hdr()
> is followed by be_dws_cpu_to_le() to handle this.

That swap_dws() thing is the most inefficient thing I've ever seen.

Instead of being able to benefit from compile time optimizations
such as byte swaps of constants, you do everything hidden from the
compiler so nothing gets optimized.

The aspect you are changing is the least of your problems in this
area.
