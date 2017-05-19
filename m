From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH v6 net-next 5/7] net: fix documentation of struct scm_timestamping
Date: Fri, 19 May 2017 17:52:39 +0200
Message-ID: <20170519155241.15817-6-mlichvar@redhat.com>
References: <20170519155241.15817-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50610 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755902AbdESPwt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 11:52:49 -0400
In-Reply-To: <20170519155241.15817-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The scm_timestamping struct may return multiple non-zero fields, e.g.
when both software and hardware RX timestamping is enabled, or when the
SO_TIMESTAMP(NS) option is combined with SCM_TIMESTAMPING and a false
software timestamp is generated in the recvmsg() call in order to always
return a SCM_TIMESTAMP(NS) message.

CC: Richard Cochran <richardcochran@gmail.com>
CC: Willem de Bruijn <willemb@google.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 Documentation/networking/timestamping.txt | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index ce11e3a..50eb0e5 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -322,7 +322,7 @@ struct scm_timestamping {
 };
 
 The structure can return up to three timestamps. This is a legacy
-feature. Only one field is non-zero at any time. Most timestamps
+feature. At least one field is non-zero at any time. Most timestamps
 are passed in ts[0]. Hardware timestamps are passed in ts[2].
 
 ts[1] used to hold hardware timestamps converted to system time.
@@ -331,6 +331,12 @@ a HW PTP clock source, to allow time conversion in userspace and
 optionally synchronize system time with a userspace PTP stack such
 as linuxptp. For the PTP clock API, see Documentation/ptp/ptp.txt.
 
+Note that if the SO_TIMESTAMP or SO_TIMESTAMPNS option is enabled
+together with SO_TIMESTAMPING using SOF_TIMESTAMPING_SOFTWARE, a false
+software timestamp will be generated in the recvmsg() call and passed
+in ts[0] when a real software timestamp is missing. This happens also
+on hardware transmit timestamps.
+
 2.1.1 Transmit timestamps with MSG_ERRQUEUE
 
 For transmit timestamps the outgoing packet is looped back to the
-- 
2.9.3
