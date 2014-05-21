From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RESEND 0/9 net-next] net: of_phy_connect_fixed_link removal
Date: Wed, 21 May 2014 14:38:42 -0700
Message-ID: <1400708331-18088-1-git-send-email-f.fainelli@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Pantelis Antoniou <pantelis.antoniou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Vitaly Bordug <vbordug-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>,
	Li Yang <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Aida Mynzhasova <aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:OPEN FIRMWARE AND...),
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list),
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org (open list:LINUX FOR POWERPC...)
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

This patch set removes of_phy_connect_fixed_link() from the tree now that
we have a better solution for dealing with fixed PHY (emulated PHY) devices
for drivers that require them.

First two patches update the 'fixed-link' Device Tree binding and drivers to
refere to it.

Patches 3 to 7 update the in-tree network drivers that use
of_phy_connect_fixed_link()

Patch 8 removes of_phy_connect_fixed_link

Patch 9 removes the PowerPC code that parsed the 'fixed-link' property.

Patch 9 can be merged via the net-next tree if the PowerPC folks ack it,
but it really has to be merged after the first 8 patches in order to avoid
breakage.

Florian Fainelli (9):
  Documentation: devicetree: add old and deprecated 'fixed-link'
  Documentation: devicetree: net: refer to fixed-link.txt
  net: bcmgenet: use the new fixed PHY helpers
  net: systemport: use the new fixed PHY helpers
  fs_enet: use the new fixed PHY helpers
  gianfar: use the new fixed PHY helpers
  ucc_geth: use the new fixed PHY helpers
  of: mdio: remove of_phy_connect_fixed_link
  powerpc/fsl: fsl_soc: remove 'fixed-link' parsing code

 .../devicetree/bindings/net/broadcom-bcmgenet.txt  |  2 +-
 .../bindings/net/broadcom-systemport.txt           |  2 +-
 .../devicetree/bindings/net/fixed-link.txt         | 12 +++++++
 .../devicetree/bindings/net/fsl-tsec-phy.txt       |  5 +--
 arch/powerpc/sysdev/fsl_soc.c                      | 32 ------------------
 drivers/net/ethernet/broadcom/bcmsysport.c         | 17 ++++++++--
 drivers/net/ethernet/broadcom/bcmsysport.h         |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c       | 21 +++++++-----
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  | 16 +++++----
 drivers/net/ethernet/freescale/gianfar.c           | 14 ++++++--
 drivers/net/ethernet/freescale/ucc_geth.c          | 14 ++++++--
 drivers/of/of_mdio.c                               | 38 ----------------------
 include/linux/of_mdio.h                            | 10 ------
 13 files changed, 75 insertions(+), 109 deletions(-)

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
