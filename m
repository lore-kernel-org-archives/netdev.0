From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] isdn: avoid calling tty_ldisc_flush() in atomic
 context
Date: Mon, 05 Jul 2010 19:24:34 -0700 (PDT)
Message-ID: <20100705.192434.58441475.davem@davemloft.net>
References: <20100705-patch-isdn-00.tilman@imap.cc>
	<20100705-patch-isdn-02.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, hjlipp@web.de, keil@b1-systems.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36221
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756980Ab0GFCYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:24:21 -0400
In-Reply-To: <20100705-patch-isdn-02.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Tue,  6 Jul 2010 02:18:27 +0200 (CEST)

> Remove the call to tty_ldisc_flush() from the RESULT_NO_CARRIER
> branch of isdn_tty_modem_result(), as already proposed in commit
> 00409bb045887ec5e7b9e351bc080c38ab6bfd33.
> This avoids a "sleeping function called from invalid context" BUG
> when the hardware driver calls the statcallb() callback with
> command==ISDN_STAT_DHUP in atomic context, which in turn calls
> isdn_tty_modem_result(RESULT_NO_CARRIER, ~), and from there,
> tty_ldisc_flush() which may sleep.
> 
> Impact: bugfix
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied to net-next-2.6, thanks.
