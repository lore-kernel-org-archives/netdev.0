From: Trent Piepho <tpiepho@gmail.com>
Subject: Re: [RFC 0/3] arm: mxs: sanitize enet_out clock handling
Date: Fri, 15 Mar 2013 14:27:35 -0700
Message-ID: <CA+7tXiinVCjs7NAdGd+0KyUL+kfwWUi_XAPYdMHiugT3W2Xz4w@mail.gmail.com>
References: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Shawn Guo <shawn.guo@freescale.com>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:45512 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932531Ab3COV1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 17:27:35 -0400
Received: by mail-ie0-f169.google.com with SMTP id 13so4992262iea.14
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 14:27:35 -0700 (PDT)
In-Reply-To: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 29, 2013 at 6:46 AM, Wolfram Sang <w.sang@pengutronix.de> wrote:
> Handling enet_out on MX28 is cumbersome at the moment. Most boards need it
> enabled and for that, they have to add code to mach-mxs.c (see sps1 as an
> example). Since this is board specific, we better encode it in the
> devicetree, that is the reason it was made for.
>
> My proposal will overwrite the generic "clock" and "clock-names" properties
> from imx28.dtsi in the board file. The original one has 2 entries, and boards
> needing enet_out will overload it with three entries. The network driver will
> enable the clock if it was specified. The old code enabling the clock will be
> backward compatible but print a WARN if the legacy mode needs to be used.

Trying this again with proper CCs.  gmane's reply interface don't
allow cross-posting or CCs, so I'm trying an alternate method where I
export the raw email from gmane, convert it to an mbox file, then
upload it via imap to gmail, so I can reply from there.  We'll see how
badly gmail mangles it.

Anyway, I found this same problem when adding support for a new imx28
board.  Ethernet stopped working as soon as I changed the board name
from imx28-evk since the imx28-evk board setup function stopped
running.  These patches seem like a good way to fix the problem
without require the same board specific code in the kernel to be
duplicated for each new board.

But as you say most boards need enet_out (AFAICT, all but the Denx
board).  So wouldn't it make more sense to add enet_out to the dtsi
file and then just override it in the one board that doesn't need it,
instead of overriding in every board except that one?
