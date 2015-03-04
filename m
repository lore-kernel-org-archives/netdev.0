From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 0/5] TTY: fix tty_wait_until_sent on 64-bit machines
Date: Wed,  4 Mar 2015 10:39:02 +0100
Message-ID: <1425461947-15888-1-git-send-email-johan@kernel.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>,
	Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org,
	ZIV-Asier Llano Palacios <asier.llano@cgglobal.com>,
	Johan Hovold <johan@kernel.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes an overflow bug in tty_wait_until_sent, which is
currently broken on 64-bit machines for most TTY drivers (with
serial-core being the notable exception).

The final patch makes the tty_wait_until_sent timeout a maximum one so
that we actually honour the closing-wait timeout.

All but the second (clean-up) and final patch are marked for stable.

These patches are for v4.0 and I suggest Greg takes them all through the
TTY tree.

Thanks,
Johan


Johan Hovold (5):
  net: irda: fix wait_until_sent poll timeout
  TTY: bfin_jtag_comm: remove incorrect wait_until_sent operation
  USB: serial: fix infinite wait_until_sent timeout
  TTY: fix tty_wait_until_sent on 64-bit machines
  TTY: fix tty_wait_until_sent maximum timeout

 drivers/tty/bfin_jtag_comm.c | 13 -------------
 drivers/tty/tty_ioctl.c      | 16 +++++++++++-----
 drivers/usb/serial/generic.c |  5 +++--
 net/irda/ircomm/ircomm_tty.c |  4 +++-
 4 files changed, 17 insertions(+), 21 deletions(-)

-- 
2.0.5
