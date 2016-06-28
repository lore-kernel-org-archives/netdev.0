From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the imx-mxs tree
Date: Tue, 28 Jun 2016 11:27:11 +1000
Message-ID: <20160628112711.5dc3b529@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Lucas Stach <l.stach@pengutronix.de>,
	Fugang Duan <fugang.duan@nxp.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Shawn Guo <shawn.guo@linaro.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/freescale/fec.h

between commit:

  293809055656 ("ARM: imx6: disable deeper idle states when FEC is active w/o HW workaround")

from the imx-mxs tree and commit:

  ff7566b8d71f ("net: fec: add interrupt coalesc quirk flag")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/freescale/fec.h
index dc71a88e9c55,92fd5c0bf4df..000000000000
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@@ -442,8 -442,8 +442,10 @@@ struct bufdesc_ex 
  #define FEC_QUIRK_SINGLE_MDIO		(1 << 11)
  /* Controller supports RACC register */
  #define FEC_QUIRK_HAS_RACC		(1 << 12)
 +/* Interrupt doesn't wake CPU from deep idle */
 +#define FEC_QUIRK_ERR006687		(1 << 13)
+ /* Controller supports interrupt coalesc */
 -#define FEC_QUIRK_HAS_COALESCE		(1 << 13)
++#define FEC_QUIRK_HAS_COALESCE		(1 << 14)
  
  struct bufdesc_prop {
  	int qid;
