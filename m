From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] drivers/net/wireless/ath/wil6210: Makefile, only -Werror
 when no -W* in EXTRA_CFLAGS
Date: Wed, 27 Feb 2013 14:55:06 +0800
Message-ID: <512DADCA.9040609@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: qca_vkondrat@qca.qualcomm.com,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
	"netdev@vger.kernel.org >> netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:56641 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410Ab3B0Gz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 01:55:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  When make with EXTRA_CFLAGS=-W, it will report error.
  so give a check in Makefile.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 drivers/net/wireless/ath/wil6210/Makefile |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath/wil6210/Makefile b/drivers/net/wireless/ath/wil6210/Makefile
index 9396dc9..d288eea 100644
--- a/drivers/net/wireless/ath/wil6210/Makefile
+++ b/drivers/net/wireless/ath/wil6210/Makefile
@@ -9,5 +9,7 @@ wil6210-objs += wmi.o
 wil6210-objs += interrupt.o
 wil6210-objs += txrx.o
 
-subdir-ccflags-y += -Werror
+ifeq (, $(findstring -W,$(EXTRA_CFLAGS)))
+	subdir-ccflags-y += -Werror
+endif
 subdir-ccflags-y += -D__CHECK_ENDIAN__
-- 
1.7.7.6
