From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [GIT PATCH] TTY/serial patches for 3.4-rc1
Date: Sun, 25 Mar 2012 19:12:37 +0200
Message-ID: <20120325171837.67310140074@xenon.ts.pxnet.com>
References: <20120319195649.GD9883@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org, hjlipp@web.de
To: Greg KH <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <20120319195649.GD9883@kroah.com>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri, Greg,

On 19.03.2012 20:56, Greg KH wrote:
> tty and serial merge for 3.4-rc1
[...]
> Jiri Slaby (77):
[...]
>       TTY: isdn/gigaset, do not set tty->driver_data to NULL

It seems that the amendment we discussed on 05.03.2012 did not
make it into this patch. It would be nice if the following patch
could still be added on top of it.

Thanks,
Tilman

From: Tilman Schmidt <tilman@imap.cc>
Date: Sun, 25 Mar 2012 12:21:57 +0200
Subject: [PATCH] isdn/gigaset: use gig_dbg() for debugging output

The "TTY buffer in tty_port" patchset introduced an opencoded
debug message in the Gigaset tty device if_close() function.
Change it to use the gig_dbg() macro like everywhere else in
the driver.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/interface.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index b3d6ac1..a6d9fd2 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -176,7 +176,7 @@ static void if_close(struct tty_struct *tty, struct file *filp)
 	struct cardstate *cs = tty->driver_data;
 
 	if (!cs) { /* happens if we didn't find cs in open */
-		printk(KERN_DEBUG "%s: no cardstate\n", __func__);
+		gig_dbg(DEBUG_IF, "%s: no cardstate", __func__);
 		return;
 	}
 
-- 
1.7.3.4

