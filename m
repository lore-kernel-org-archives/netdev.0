From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] ptp: increase the maximum number of clocks
Date: Thu, 21 Mar 2013 20:24:19 +0100
Message-ID: <d219aa87bd5b3e2fa42449720d845a7110f642f0.1363893841.git.jbenc@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1567 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265Ab3CUTYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 15:24:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As network adapters supporting PTP are becoming more common, machines with
many NICs suddenly have many PHCs, too. Although the PHCs are not used in
such cases, they produce error messages like this:

igb 0000:07:00.0: ptp_clock_register failed

Currently, the maximum number of devices accepted by ptp_clock_register
is 8 which is pretty low. We could silence the error messages but this would
hurt in case somebody wants to use one of the interfaces to actually run
PTP, as the /dev/ptp%d device for the desired interface may or may not be
available after each boot.

Let's increase the maximum to 128. This shouldn't be a problem, as for the
char devices, the whole major number is reserved anyway, and 128bit bitmap
isn't a big deal, either.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/ptp/ptp_clock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 79f4bce..381d557 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -32,7 +32,7 @@
 #include "ptp_private.h"
 
 #define PTP_MAX_ALARMS 4
-#define PTP_MAX_CLOCKS 8
+#define PTP_MAX_CLOCKS 128
 #define PTP_PPS_DEFAULTS (PPS_CAPTUREASSERT | PPS_OFFSETASSERT)
 #define PTP_PPS_EVENT PPS_CAPTUREASSERT
 #define PTP_PPS_MODE (PTP_PPS_DEFAULTS | PPS_CANWAIT | PPS_TSFMT_TSPEC)
-- 
1.7.6.5
