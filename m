From: Patrick Schaaf <netdev@bof.de>
Subject: kernel 3.14.53 + bnx2x loss of connectivity / parity errors / MCP SCPAD
Date: Wed, 04 Nov 2015 12:31:46 +0100
Message-ID: <1727409.Ct3NHyBiXb@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Greg KH <gregkh@linuxfoundation.org>, ariele@broadcom.com
To: NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mars.intermailgate.com ([80.242.145.70]:59095 "EHLO
	mars.intermailgate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754545AbbKDLia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 06:38:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear netdevs,

on a production server (HP DL380 Gen9 with HP 10GE dual port card - bnx2x 
driver), I just encountered a full loss of connectivity through the 10 GE 
ports. Kernel in use is vanilla 3.14.53.

On the console I could see this (timestamps omitted, have to type by hand, 
damn ILO console does not let me copy+paste text...)

MCP SCPAD
MCP SCPAD
bnx2x 0000:04:00.1 eth1: Parity errors detected in blocks:
MCP SCPAD
MCP SCPAD
bnx2x 0000:04:00.0 eth0: Parity errors detected in blocks:
bnx2x: [bnx2x_attn_int_deasserted3:4080(eth0)]LATCHED attention 0x80000000 
(masked)
MCP SCPAD
...
systemd-journald[491]: /dev/kmsg buffer overrun, some messages lost.

Some googling around finds:

https://github.com/torvalds/linux/commit/ad6afbe9578d1fa26680faf78c846bd8c00d1d6e 

which might be related. If I read that correctly (and I have no real idea what 
I'm talking about, sorry...) that patch removes superflous printks which 
might, e.g. in our case, hide the real cause. i.e. even with that patch we 
would have had a problem / loss of connectivity, but we might know better why.

Maybe that changeset would be suitable for backporting to long term stable 
kernels?

Incidentally, how should these parity events be judged generally? Hope it's a 
one time cosmic ray incident? Cry "faulty hardware, please repair" to the 
supplier? Anything else?

best regards
  Patrick
