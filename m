From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next]alx: Atheros AR8131/AR8151/AR8152/AR8161
 Ethernet driver
Date: Thu, 20 Oct 2011 04:45:41 -0400 (EDT)
Message-ID: <20111020.044541.970282389722164761.davem@davemloft.net>
References: <1319093184-19696-1-git-send-email-cloud.ren@Atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Luis.Rodriguez@Atheros.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: cloud.ren@Atheros.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319093184-19696-1-git-send-email-cloud.ren@Atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <cloud.ren@Atheros.com>
Date: Thu, 20 Oct 2011 14:46:24 +0800

> +#define __far

So much unused crap left in these header files, get rid of this stuff.

+#define ALX_HW_WARN(_fmt, _args...) \
+		ALX_HW_PRINTA(WARNING, _fmt, ## _args)
+
+#define ALX_HW_INFO(_fmt, _args...) \
+		ALX_HW_PRINTA(INFO, _fmt, ## _args)
+
+#define ALX_HW_DBG(_fmt, _args...) \
+		ALX_HW_PRINTA(DEBUG, _fmt, ## _args)
+

We told you to get rid of your customized debug logging interfaces,
yet all of this stuff is still there.

+/* delay function */
+#define US_DELAY(_hw, _n)	__US_DELAY(_n)
+#define MS_DELAY(_hw, _n)	__MS_DELAY(_n)
+#define __US_DELAY(_n)		udelay(_n)
+#define __MS_DELAY(_n)		mdelay(_n)

Useless wrappers for standard kernel interfaces, kill this.

+#define DEBUG_INFO(_a, _b)
+#define DEBUG_INFOS(_a, _b)

Again we told you to get rid of this stuff.

I suspect it's going to take may rounds of feedback before this driver
is anywhere near ready for inclusion.

Please just submit it to staging and let it cook there for a couple
weeks in the interests of our sanity.
