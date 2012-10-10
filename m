From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [patch] isdn: fix a wrapping bug in isdn_ppp_ioctl()
Date: Wed, 10 Oct 2012 15:58:38 +0200
Message-ID: <m2sj9m5sz5.fsf@igel.home>
References: <20121010093816.GA3669@elgon.mountain>
	<1349864358.2386.27.camel@joe-AO722> <m21uh67csy.fsf@igel.home>
	<1349874007.2386.42.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:58668 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755954Ab2JJN6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 09:58:41 -0400
In-Reply-To: <1349874007.2386.42.camel@joe-AO722> (Joe Perches's message of
	"Wed, 10 Oct 2012 06:00:07 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I was misremembering the history of the bit ops.  There has
historically been issues with varying bit order, but noadays set_bit is
always defined consistently with C shifts.

But another issue, set_bit is an atomic operation which may be
significantly more expensive than the equivalent C operation.  Better
use __set_bit when atomicity is not needed.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
