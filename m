From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: libertas and endianness
Date: Sun, 7 Oct 2007 12:15:06 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710071209290.8127@anakin>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hoboe2bl1.telenet-ops.be ([195.130.137.73]:35721 "EHLO
	hoboe2bl1.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbXJGKPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 06:15:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Somehow (haven't found out why it suddenly got compiled, no .config
changes) this showed up in the list of warnings in 2.6.23-rc9 compared
to -rc8 on one of my m68k builds:

| drivers/net/wireless/libertas/cmd.c:189: warning: large integer implicitly truncated to unsigned type
| drivers/net/wireless/libertas/cmd.c:195: warning: large integer implicitly truncated to unsigned type

The offending lines are:

| wep->keytype[i] = cpu_to_le16(cmd_type_wep_40_bit);
| wep->keytype[i] = cpu_to_le16(cmd_type_wep_104_bit);

I.e. it tries to store 0x0100 resp. 0x0200 into keytype[i], which is is u8.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
