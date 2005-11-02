From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] pktgen: remove useless assignment
Date: Wed, 2 Nov 2005 10:11:08 +0100
Message-ID: <20051102091108.GG8009@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932685AbVKBJLP@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On main codepath pkt_dev is immediately rewritten. On error codepath it isn't
used.

Noticed by Coverity checker.

From: Alexey Dobriyan <adobriyan@gmail.com>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-vanilla/net/core/pktgen.c
+++ linux-coverity-1762/net/core/pktgen.c
@@ -2882,7 +2882,7 @@ static int pktgen_add_device(struct pktg
 	
 	/* We don't allow a device to be on several threads */
 
-	if( (pkt_dev = __pktgen_NN_threads(ifname, FIND)) == NULL) {
+	if(__pktgen_NN_threads(ifname, FIND) == NULL) {
 						   
 		pkt_dev = kmalloc(sizeof(struct pktgen_dev), GFP_KERNEL);
                 if (!pkt_dev) 
