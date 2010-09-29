From: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
Subject: [PATCH 4/7] net: emaclite: Add support for little-endian platforms
Date: Wed, 29 Sep 2010 15:52:15 +1000
Message-ID: <1285739538-29058-5-git-send-email-monstr@monstr.eu>
References: <1285739538-29058-1-git-send-email-monstr@monstr.eu>
	<1285739538-29058-2-git-send-email-monstr@monstr.eu>
	<1285739538-29058-3-git-send-email-monstr@monstr.eu>
	<1285739538-29058-4-git-send-email-monstr@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, microblaze-uclinux-rVRm/Wmeqae7NGdpmJTKYQ@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, duyl-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linnj-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, edgar.iglesias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, john.williams-g5w7nrANp4BDPfheJLI6IQ@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1285739538-29058-4-git-send-email-monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Upcomming Microblaze is little endian that's why is necessary
to fix protocol and length loading.

Signed-off-by: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
CC: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
CC: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
CC: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
---
 drivers/net/xilinx_emaclite.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 71122ee..533ebb1 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -430,8 +430,8 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 	}
 
 	/* Get the protocol type of the ethernet frame that arrived */
-	proto_type = ((in_be32(addr + XEL_HEADER_OFFSET +
-			XEL_RXBUFF_OFFSET) >> XEL_HEADER_SHIFT) &
+	proto_type = ((ntohl(in_be32(addr + XEL_HEADER_OFFSET +
+			XEL_RXBUFF_OFFSET)) >> XEL_HEADER_SHIFT) &
 			XEL_RPLR_LENGTH_MASK);
 
 	/* Check if received ethernet frame is a raw ethernet frame
@@ -439,9 +439,9 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 	if (proto_type > (ETH_FRAME_LEN + ETH_FCS_LEN)) {
 
 		if (proto_type == ETH_P_IP) {
-			length = ((in_be32(addr +
+			length = ((ntohl(in_be32(addr +
 					XEL_HEADER_IP_LENGTH_OFFSET +
-					XEL_RXBUFF_OFFSET) >>
+					XEL_RXBUFF_OFFSET)) >>
 					XEL_HEADER_SHIFT) &
 					XEL_RPLR_LENGTH_MASK);
 			length += ETH_HLEN + ETH_FCS_LEN;
-- 
1.5.5.1
