From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] net, TTY: initialize tty->driver_data before usage
Date: Thu,  4 Oct 2012 20:01:21 -0400
Message-ID: <1349395281-12495-1-git-send-email-sasha.levin@oracle.com>
Cc: levinsasha928@gmail.com, davej@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: samuel@sortiz.org, davem@davemloft.net, gregkh@linuxfoundation.org,
	jslaby@suse.cz, alan@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 9c650ffc ("TTY: ircomm_tty, add tty install") split _open() to
_install() and _open(). It also moved the initialization of driver_data
out of open(), but never added it to install() - causing a NULL ptr
deref whenever the driver was used.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/irda/ircomm/ircomm_tty.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 95a3a7a..496ce2c 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -421,6 +421,8 @@ static int ircomm_tty_install(struct tty_driver *driver, struct tty_struct *tty)
 		hashbin_insert(ircomm_tty, (irda_queue_t *) self, line, NULL);
 	}
 
+	tty->driver_data = self;
+
 	return tty_port_install(&self->port, driver, tty);
 }
 
-- 
1.7.12
