From: "Satoru SATOH" <satoru.satoh@gmail.com>
Subject: [PATCH] [IPROUTE]: Avoid overflow for larger rto_min in print_route
Date: Thu, 13 Dec 2007 00:50:27 +0900
Message-ID: <d72b7ace0712120750k2deed0f6p50c1c556d3f7de80@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.177]:52041 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbXLLQBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 11:01:35 -0500
Received: by el-out-1112.google.com with SMTP id j27so44361elf.1
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 08:01:31 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This includes a workaround for overflow while conversion of larger
rto_min (e.g. 3s) unit.


Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

 ip/iproute.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index f4200ae..fa722c6 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -510,16 +510,16 @@ int print_route(const struct sockaddr_nl *who,
struct nlmsghdr *n, void *arg)
                                fprintf(fp, " %u",
*(unsigned*)RTA_DATA(mxrta[i]));
                        else {
                                unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
+                               unsigned hz1 = hz / 1000;

-                               val *= 1000;
                                if (i == RTAX_RTT)
                                        val /= 8;
                                else if (i == RTAX_RTTVAR)
                                        val /= 4;
-                               if (val >= hz)
-                                       fprintf(fp, " %ums", val/hz);
+                               if (val >= hz1)
+                                       fprintf(fp, " %ums", val/hz1);
                                else
-                                       fprintf(fp, " %.2fms", (float)val/hz);
+                                       fprintf(fp, " %.2fms", (float)val/hz1);
                        }
                }
        }
