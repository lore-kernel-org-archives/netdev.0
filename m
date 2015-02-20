From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 5/7 linux-next] hso: replace current->state by __set_current_state()
Date: Fri, 20 Feb 2015 19:12:55 +0100
Message-ID: <1424455977-21903-5-git-send-email-fabf@skynet.be>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be>
Cc: Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Fabian Frederick <fabf@skynet.be>,
	Jan Dumon <j.dumon@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424455977-21903-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use helper functions to access current->state.
Direct assignments are prone to races and therefore buggy.

Thanks to Peter Zijlstra for the exact definition of the problem.

Suggested-By: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/usb/hso.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 9cdfb3f..778e915 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1594,7 +1594,7 @@ hso_wait_modem_status(struct hso_serial *serial, unsigned long arg)
 		}
 		cprev = cnow;
 	}
-	current->state = TASK_RUNNING;
+	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(&tiocmget->waitq, &wait);
 
 	return ret;
-- 
2.1.0
