From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] [AX.25]: small cleanup in ax25_addr_parse()
Date: Thu, 5 Jul 2012 11:27:18 +0300
Message-ID: <20120705082718.GA14993@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The comments were wrong here because "AX25_MAX_DIGIS" is 8 but the
comments say 6.  Also I've changed the "7" to "AX25_ADDR_LEN".

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ax25/ax25_addr.c b/net/ax25/ax25_addr.c
index 9162409..e7c9b0e 100644
--- a/net/ax25/ax25_addr.c
+++ b/net/ax25/ax25_addr.c
@@ -189,8 +189,10 @@ const unsigned char *ax25_addr_parse(const unsigned char *buf, int len,
 	digi->ndigi      = 0;
 
 	while (!(buf[-1] & AX25_EBIT)) {
-		if (d >= AX25_MAX_DIGIS)  return NULL;	/* Max of 6 digis */
-		if (len < 7) return NULL;	/* Short packet */
+		if (d >= AX25_MAX_DIGIS)
+			return NULL;
+		if (len < AX25_ADDR_LEN)
+			return NULL;
 
 		memcpy(&digi->calls[d], buf, AX25_ADDR_LEN);
 		digi->ndigi = d + 1;
