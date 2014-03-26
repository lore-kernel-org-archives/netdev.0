From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/7] atm: replace del_timer by del_timer_sync
Date: Wed, 26 Mar 2014 15:22:25 -0700
Message-ID: <1395872545.12610.262.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395869625-15209-1-git-send-email-Julia.Lawall@lip6.fr>
	  <1395869625-15209-3-git-send-email-Julia.Lawall@lip6.fr>
	 <1395871015.12610.254.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1403262301171.31401@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1403262301171.31401@ionos.tec.linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-03-26 at 23:02 +0100, Thomas Gleixner wrote:

> That's why you need del_timer_sync() it waits for the timer handler to
> complete and then removes it.

Interesting... So maybe some comment is stale ?


diff --git a/kernel/timer.c b/kernel/timer.c
index accfd241b9e5..c948fa2fc065 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -1011,10 +1011,10 @@ EXPORT_SYMBOL(try_to_del_timer_sync);
  * the timer it also makes sure the handler has finished executing on other
  * CPUs.
  *
- * Synchronization rules: Callers must prevent restarting of the timer,
- * otherwise this function is meaningless. It must not be called from
- * interrupt contexts unless the timer is an irqsafe one. The caller must
- * not hold locks which would prevent completion of the timer's
+ * Synchronization rules:
+ * It must not be called from interrupt contexts unless the timer is an
+ * irqsafe one.
+ * The caller must not hold locks which would prevent completion of the timer's
  * handler. The timer's handler must not call add_timer_on(). Upon exit the
  * timer is not queued and the handler is not running on any CPU.
  *
