From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net v5 0/4] net: enable inband link state negotiation only when explicitly requested
Date: Mon, 20 Jul 2015 17:49:54 -0700
Message-ID: <1437439798-12622-1-git-send-email-f.fainelli@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mxs-i6rsG8ix9II@public.gmane.org,
	arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org, stsp-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

Changes in v5:

- removed an invalid use of the link_update callback in the SF2 driver
  was appeared after merging "net: phy: fixed_phy: handle link-down case"

- reworded the commit message for patch 2 to make it clear what it fixes and
  why this is required

Initial cover letter from Stas:

Hello.

Currently the link status auto-negotiation is enabled
for any SGMII link with fixed-link DT binding.
The regression was reported:
https://lkml.org/lkml/2015/7/8/865
Apparently not all HW that implements SGMII protocol, generates the
inband status for the auto-negotiation to work.
More details here:
https://lkml.org/lkml/2015/7/10/206

The following patches reverts to the old behavior by default,
which is to not enable the auto-negotiation for fixed-link.
The new DT property is added that allows to explicitly request
the auto-negotiation.

Florian Fainelli (1):
  net: dsa: bcm_sf2: Do not override speed settings

Stas Sergeev (3):
  net: phy: fixed_phy: handle link-down case
  of_mdio: add new DT property 'managed' to specify the PHY management
    type
  mvneta: use inband status only when explicitly enabled

 Documentation/devicetree/bindings/net/ethernet.txt |  4 ++++
 drivers/net/dsa/bcm_sf2.c                          | 18 +-----------------
 drivers/net/ethernet/marvell/mvneta.c              |  9 +++++----
 drivers/net/phy/fixed_phy.c                        |  8 +++++---
 drivers/of/of_mdio.c                               | 19 +++++++++++++++++--
 5 files changed, 32 insertions(+), 26 deletions(-)

-- 
2.1.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
