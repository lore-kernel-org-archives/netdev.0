From: David Miller <davem@davemloft.net>
Subject: Re: [patch sungem] improved locking
Date: Mon, 13 Nov 2006 16:46:22 -0800 (PST)
Message-ID: <20061113.164622.28395064.davem@davemloft.net>
References: <5cac192f0611100528r4a53498emc8d866955cc36c8d@mail.gmail.com>
	<20061110.124246.41636039.davem@davemloft.net>
	<5cac192f0611121511w6a8fec54pdf6124b5f2f79a08@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41639
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933267AbWKNAqO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 19:46:14 -0500
To: eric.lemoine@gmail.com
In-Reply-To: <5cac192f0611121511w6a8fec54pdf6124b5f2f79a08@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric Lemoine" <eric.lemoine@gmail.com>
Date: Mon, 13 Nov 2006 00:11:49 +0100

> +#if GEM_INTERRUPT_LOCKLESS
> +
> +/* Bitmask representing the interrupt conditions that we clear using GREG_IACK.
> + * We clear all the top-level interrupt conditions (bits 0 through 6) that we
> + * handle.
> + */
> +#define GREG_STAT_IACK		(GREG_STAT_NAPI & 0x3f)
> +#endif

I'm asking for this a second time...  and to be honest I'm a little
bit ticked off.

Please spell out the explicit bits using the existing defines to
create this mask.  Do not use this magic 0x3f magic number which
contains bits which are undefined, so obtain this mask (as I asked the
first time) like this:

	(GREG_STAT_TXINTME | GREG_STAT_TXALL |
	 GREG_STAT_TXDONE | GREG_STAT_RXDONE |
	 GREG_STAT_RXNOBUF)

I will not go through the effort a third time, instead I will simply
ignore your patch submissions, it's that simple.  If you ignore me, I
ignore you.

You want me to review this patch and the locking bits, but you're
never going to get to that point if you continually ignore the
most simple requests I'm making of you. :-(
