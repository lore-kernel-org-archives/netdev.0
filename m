From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 4/6] net: mvneta: Handle per-cpu interrupts
Date: Sun, 5 Jul 2015 14:37:08 +0200
Message-ID: <20150705123708.GA24162@1wt.eu>
References: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com> <1435933551-28696-5-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:33921 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734AbbGEMhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jul 2015 08:37:23 -0400
Content-Disposition: inline
In-Reply-To: <1435933551-28696-5-git-send-email-maxime.ripard@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Maxime,

On Fri, Jul 03, 2015 at 04:25:49PM +0200, Maxime Ripard wrote:
> Now that our interrupt controller is allowing us to use per-CPU interrupts,
> actually use it in the mvneta driver.
> 
> This involves obviously reworking the driver to have a CPU-local NAPI
> structure, and report for incoming packet using that structure.
> 
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>

This patch breaks module build of mvneta unless you export request_percpu_irq :

diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index ec31697..1440a92 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -1799,6 +1799,7 @@ int request_percpu_irq(unsigned int irq, irq_handler_t handler,
 
	return retval;
 }
+EXPORT_SYMBOL_GPL(request_percpu_irq);
 
Regards,
Willy
