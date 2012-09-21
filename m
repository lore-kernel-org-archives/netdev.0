From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] stmmac: fix return value check in stmmac_open_ext_timer()
Date: Fri, 21 Sep 2012 15:06:10 +0800
Message-ID: <CAPgLHd87SqVa40-SGrgEfRAPWj1dr9aGPDD7b3aALCqka2ssuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:56230 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308Ab2IUHGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 03:06:11 -0400
Received: by qaas11 with SMTP id s11so1024257qaa.19
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 00:06:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function clk_get() returns ERR_PTR()
and never returns NULL pointer. The NULL test in the error
handling should be replaced with IS_ERR().

dpatch engine is used to auto generated this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c
index 2a0e1ab..197fb8c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c
@@ -109,7 +109,7 @@ int stmmac_open_ext_timer(struct net_device *dev, struct stmmac_timer *tm)
 {
 	timer_clock = clk_get(NULL, TMU_CHANNEL);
 
-	if (timer_clock == NULL)
+	if (IS_ERR(timer_clock))
 		return -1;
 
 	if (tmu2_register_user(stmmac_timer_handler, (void *)dev) < 0) {
