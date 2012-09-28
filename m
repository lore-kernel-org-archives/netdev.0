From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 4/5] be2net: get rid of AMAP_SET/GET macros in
 TX path
Date: Thu, 27 Sep 2012 22:29:00 -0400 (EDT)
Message-ID: <20120927.222900.1633352325278735069.davem@davemloft.net>
References: <1348727568-2011-1-git-send-email-sathya.perla@emulex.com>
	<92de1988-73db-4864-bf19-10ed11dac557@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664Ab2I1C3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 22:29:02 -0400
In-Reply-To: <92de1988-73db-4864-bf19-10ed11dac557@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Thu, 27 Sep 2012 12:02:47 +0530

> The AMAP macros are used in be2net for setting and parsing bits in HW
> descriptors. The macros do this by calculating the mask & offset of each
> field from the AMAP structure definition.
> In the TX patch, replace the usage of these macros with code to explicitly
> shift & mask each field. Doing this reduces instructions and improves
> readability.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Now you have endianness bugs.  The previous code worked with 8-bit
struct members and as such was endian neutral.

Now you're working with words, so you thus have to take endianness
into consideration.

The readability aspect is also extremely questionable, here's why.
The old code accessed struct members with _NAMES_ which described what
the values are and what they do.

This new code puts values into opaque "word" array members.  That's
about as crappy as it comes wrt. readability.  What in the world
does word[0] do?  I can't tell from it's name.  Yet with the existing
"struct amap_eth_hdr_wrb" there is none of that kind of confusion.

So don't pretend this new code even looks better, it looks like opaque
garbage to me.

Just admit this is an optimization that broke things on the endianness
you did not test.

be2net patches have been of a very low quality lately.  So I suggest
you improve things or else your submissions will be processed with an
extremely low priority.

Thanks.
