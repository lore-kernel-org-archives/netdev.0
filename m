From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: [PATCH] [EXPERIMENTAL] 2.6: de2104x.c jumbo frames, take two
Date: Sat, 10 Jan 2004 00:33:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040110003304.A3788@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

Attached is a patch which enables jumbo frames on DS2104x based boards. The
maximum supported MTU is 4066 bytes (but see below). Room for a VLAN tag is
included.

The maximum supported MTU is about twice as large as in my first jumbo frame
patch because both buffers of RX and TX descriptors are used (just like the
winbond-840 driver on TX). The media tables have been adjusted to disable
the RX watchdog and TX jabber timers.

Tested with a DS21041 and an MTU of 3544 on BNC media with an NE3200 board
at the other end without problems.

Known bugs and problems:
1. Although the DS21143 manual says that the RX frame descriptor size field
is 14 bits wide, the DS21041 seems to use only 11 bits. This means that
frames larger than 1518+2048 bytes can not be told apart from frames larger
than 1518 bytes but smaller than 2048 bytes. As a result, setting the MTU
larger than 3544 will cause problems.

Please report success or failure with this patch.

-- 
Regards,
Rask Ingemann Lambertsen
