From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH v2 00/11] hso: fix some problems in the disconnect path
Date: Fri, 30 Jan 2015 13:21:52 +0100
Message-ID: <1422620523-15021-1-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>, Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches attempt to fix some problems I observed when the hso
device is disconnected.
Several patches of this serie are fixing crashes or memleaks when a
hso device is disconnected.
This serie of patches is based on v3.18.

changes in v2:
 - Last patch of the serie dropped since another patch fix the issue.
   See http://marc.info/?l=linux-usb&m=142186699418489 for more info.

 - Added an extra patch avoiding name conflicts for the rfkill interface.

Olivier Sobrie (11):
  hso: remove useless header file timer.h
  hso: fix crash when device disappears while serial port is open
  hso: fix memory leak when device disconnects
  hso: fix memory leak in hso_create_rfkill()
  hso: fix small indentation error
  hso: rename hso_dev into serial in hso_free_interface()
  hso: replace reset_device work by usb_queue_reset_device()
  hso: move tty_unregister outside hso_serial_common_free()
  hso: update serial_table in usb disconnect method
  hso: add missing cancel_work_sync in disconnect()
  hso: fix rfkill name conflicts

 drivers/net/usb/hso.c | 91 ++++++++++++++++++++++-----------------------------
 1 file changed, 40 insertions(+), 51 deletions(-)

-- 
2.2.0
