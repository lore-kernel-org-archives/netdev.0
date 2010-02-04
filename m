From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: linux-next: manual merge of the trivial tree with the net tree
Date: Thu, 04 Feb 2010 14:52:29 +0100
Message-ID: <4B6AD11D.6050402@st.com>
References: <20100203133011.75aef1d3.sfr@canb.auug.org.au> <alpine.LNX.2.00.1002031136560.15395@pobox.suse.cz> <20100203.200402.17600564.davem@davemloft.net> <alpine.LNX.2.00.1002041052020.15395@pobox.suse.cz> <4B6AC28D.6090204@st.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030308050900040700080508"
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	lsorense@csclub.uwaterloo.ca, netdev@vger.kernel.org,
	daniel@caiaq.de
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4B6AC28D.6090204@st.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030308050900040700080508
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Giuseppe CAVALLARO wrote:
> Hi Jiri,
> 
> The stmmac driver included in net-next has been restructured: for this
> reason both gmac.c and mac100.c files do not exist any more.
> 
> Let me know if I can help on this; I mean I'm happy to apply this latest
> changes to the stmmac in net-next and send a new patch.

patch attached
I hope it could be useful.

Regards,
Peppe

> 
> Peppe
> 
>> Daniel, could you please refresh the drivers/net/ and net/ bits of your 
>> patch and resent it to netdev/Dave?
> 
>> I have already dropped it from my queue.
> 
>> Thanks,
> 
> 
- --
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAktq0R0ACgkQ2Xo3j31MSSKeIgCggHG4aixy7SxkSuaVd/hH3fo/
WZcAoK52FTpJLt/JJqJY2NopN0rFK3G1
=Ur+x
-----END PGP SIGNATURE-----

--------------030308050900040700080508
Content-Type: text/x-patch;
 name="0001-stmmac-fix-lenght-typo-in-comments-and-code.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-stmmac-fix-lenght-typo-in-comments-and-code.patch"

>From f7c63a1378d30d89a6b1a168b0450afb344e7d6d Mon Sep 17 00:00:00 2001
From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Thu, 4 Feb 2010 13:58:58 +0100
Subject: [linux-next] stmmac: fix 'lenght' typo in comments and code

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/common.h         |    2 +-
 drivers/net/stmmac/dwmac100.c       |    2 +-
 drivers/net/stmmac/dwmac1000_dma.c  |    4 ++--
 drivers/net/stmmac/stmmac_ethtool.c |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 7267bcd..2a58172 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -44,7 +44,7 @@ struct stmmac_extra_stats {
 	unsigned long rx_toolong;
 	unsigned long rx_collision;
 	unsigned long rx_crc;
-	unsigned long rx_lenght;
+	unsigned long rx_length;
 	unsigned long rx_mii;
 	unsigned long rx_multicast;
 	unsigned long rx_gmac_overflow;
diff --git a/drivers/net/stmmac/dwmac100.c b/drivers/net/stmmac/dwmac100.c
index 82dde77..ac48ed7 100644
--- a/drivers/net/stmmac/dwmac100.c
+++ b/drivers/net/stmmac/dwmac100.c
@@ -265,7 +265,7 @@ static int dwmac100_get_rx_frame_status(void *data,
 		ret = discard_frame;
 
 	if (unlikely(p->des01.rx.length_error)) {
-		x->rx_lenght++;
+		x->rx_length++;
 		ret = discard_frame;
 	}
 	if (unlikely(p->des01.rx.mii_error)) {
diff --git a/drivers/net/stmmac/dwmac1000_dma.c b/drivers/net/stmmac/dwmac1000_dma.c
index 6824550..39d436a 100644
--- a/drivers/net/stmmac/dwmac1000_dma.c
+++ b/drivers/net/stmmac/dwmac1000_dma.c
@@ -230,7 +230,7 @@ static int dwmac1000_coe_rdes0(int ipc_err, int type, int payload_err)
 
 	/* bits 5 7 0 | Frame status
 	 * ----------------------------------------------------------
-	 *      0 0 0 | IEEE 802.3 Type frame (lenght < 1536 octects)
+	 *      0 0 0 | IEEE 802.3 Type frame (length < 1536 octects)
 	 *      1 0 0 | IPv4/6 No CSUM errorS.
 	 *      1 0 1 | IPv4/6 CSUM PAYLOAD error
 	 *      1 1 0 | IPv4/6 CSUM IP HR error
@@ -331,7 +331,7 @@ static int dwmac1000_get_rx_frame_status(void *data,
 	}
 	if (unlikely(p->des01.erx.length_error)) {
 		DBG(KERN_ERR "GMAC RX: length_error error\n");
-		x->rx_lenght++;
+		x->rx_length++;
 		ret = discard_frame;
 	}
 #ifdef STMMAC_VLAN_TAG_USED
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 0abeff6..c021eaa 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -62,7 +62,7 @@ static const struct  stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(rx_toolong),
 	STMMAC_STAT(rx_collision),
 	STMMAC_STAT(rx_crc),
-	STMMAC_STAT(rx_lenght),
+	STMMAC_STAT(rx_length),
 	STMMAC_STAT(rx_mii),
 	STMMAC_STAT(rx_multicast),
 	STMMAC_STAT(rx_gmac_overflow),
-- 
1.6.0.4


--------------030308050900040700080508--
