From: "Adit Ranadive" <adit.262@gmail.com>
Subject: PATCH - Pktgen srcmac fix - Kernel 2.6.22.6
Date: Sat, 1 Sep 2007 21:18:35 -0400
Message-ID: <d2ad857f0709011818o7954b40csfc9d5267f9fb3f8b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.190]:4795 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933379AbXIBBSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 21:18:35 -0400
Received: by rv-out-0910.google.com with SMTP id k20so679133rvb
        for <netdev@vger.kernel.org>; Sat, 01 Sep 2007 18:18:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -urNp linux-orig/net/core/pktgen.c linux-mod/net/core/pktgen.c
--- linux-orig/net/core/pktgen.c        2007-08-31 02:21:01.000000000 -0400
+++ linux-mod/net/core/pktgen.c 2007-09-01 20:51:22.000000000 -0400
@@ -111,6 +111,9 @@
  *
  * 802.1Q/Q-in-Q support by Francesco Fondelli (FF)
<francesco.fondelli@gmail.com>
  *
+ * Fixed src_mac command to set source mac of packet to value specified in
+ * command by Adit Ranadive <adit.262@gmail.com>
+ *
  */
 #include <linux/sys.h>
 #include <linux/types.h>
@@ -1415,7 +1418,9 @@ static ssize_t pktgen_if_write(struct fi
        }
        if (!strcmp(name, "src_mac")) {
                char *v = valstr;
+               unsigned char old_smac[ETH_ALEN];
                unsigned char *m = pkt_dev->src_mac;
+               memcpy(old_smac, pkt_dev->src_mac, ETH_ALEN);

                len = strn_len(&user_buffer[i], sizeof(valstr) - 1);
                if (len < 0) {
@@ -1445,6 +1450,10 @@ static ssize_t pktgen_if_write(struct fi
                        }
                }

+               /* Set up Src MAC */
+               if (compare_ether_addr(old_smac, pkt_dev->src_mac))
+                       memcpy(&(pkt_dev->hh[6]), pkt_dev->src_mac, ETH_ALEN);
+
                sprintf(pg_result, "OK: srcmac");
                return count;
        }


-- 
Adit Ranadive
MS CS Candidate
Georgia Institute of Technology,
Atlanta, GA
