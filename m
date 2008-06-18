From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows
 with MD5SIG enabled (v2)
Date: Tue, 17 Jun 2008 21:03:23 -0700 (PDT)
Message-ID: <20080617.210323.220620741.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe0683144@europa>
	<20080617.170718.260234361.davem@davemloft.net>
	<396556a20806171745k63bb3516s5971593ecf216bc4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40349
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750779AbYFREDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 00:03:23 -0400
In-Reply-To: <396556a20806171745k63bb3516s5971593ecf216bc4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Tue, 17 Jun 2008 17:45:52 -0700

> How's this:
> 
> If we receive a SYN packet with MD5 + SACK + TS was assume that it's
> from an older kernel and reply with MD5 + TS. Not including SACK means
> that it won't send us corrupt packets and since we couldn't previously
> do SACK with these packets anyway, we're not loosing anything.

We should reject invalid packets, even those created by
Linus, regardless of the ramifications of such.

If we drop such frames, things will reset and a timeout
based retransmission will occur.

I don't see any value in trying to recognize these
invalid frames.  We should instead just fix the part
of Linux that emits the bogus packets to begin with.
