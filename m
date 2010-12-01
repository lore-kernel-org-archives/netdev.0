From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6] net: Add batman-adv meshing protocol
Date: Wed, 01 Dec 2010 10:43:14 -0800 (PST)
Message-ID: <20101201.104314.112592938.davem@davemloft.net>
References: <1289136377-18350-1-git-send-email-sven.eckelmann@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: sven.eckelmann@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50378
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751280Ab0LASmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 13:42:47 -0500
In-Reply-To: <1289136377-18350-1-git-send-email-sven.eckelmann@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven.eckelmann@gmx.de>
Date: Sun,  7 Nov 2010 14:26:17 +0100

> +		if (seq_bits[word_num] & 1 << word_offset)
 ...
> +	seq_bits[word_num] |= 1 << word_offset;	/* turn the position on */
 ...
> +#define TYPE_OF_WORD unsigned long

"1" is an 'int' and won't get promoted to unsigned long which means
this code won't work on 64-bit, you need to explicitly say "1UL".

This seems to duplicate a lot of existing functionality, we have
properly bit set/clear/change/test routines, that operate on
"unsigned long" just as your code does.

And since you don't use the existing facilities, you end up with
bugs like this one.  Bug which are completely unnecessary.

The badman-adv code is full of duplicated functionality, and until
all of these cases are cured I refuse to integrate this code.  I
already complained about the hashing stuff, and now there's this
stuff too.

Every time I review the batman-adv code I find a bug, and the bug is
often in facilities which the kernel has already and are being
duplicated.  That is by definition a waste of my and everyone else's
time.

Probably your submission will be almost half the size that it is
currently once you take care of this issue. :-)

