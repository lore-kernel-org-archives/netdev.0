From: David Miller <davem@davemloft.net>
Subject: Re: [Resend PATCH 2/3] TCP: options clean up
Date: Wed, 16 Jul 2008 20:46:15 -0700 (PDT)
Message-ID: <20080716.204615.94767359.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069012@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40471
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751419AbYGQDqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 23:46:15 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069012@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Tue, 15 Jul 2008 09:30:40 -0700

> +struct tcp_out_options {
> +	unsigned options;		/* bit field of OPTION_* */
> +	unsigned mss;			/* 0 to disable */
> +	unsigned ws;			/* window scale, 0 to disable */
> +	__u32 tsval, tsecr;		/* need to include OPTION_TS */
> +	unsigned num_sack_blocks;	/* number of SACK blocks to include */
> +};

Please specify the type fully, f.e. 'unsigned int', but most of
the time fixed sized types are more appriate, and that is the case
here.

'mss' is a "u16"

You only have a tiny number of option bits, a 'u8' would suffice.
Window scale has a very small possible value range as well, it
also would fit in a 'u8'.

Those changes should make this structure 8 bytes.
