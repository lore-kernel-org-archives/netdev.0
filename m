From: Doug Berger <opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 00/12] net: bcmgenet: add support for GENETv5
Date: Mon, 13 Mar 2017 17:41:30 -0700
Message-ID: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org, xow-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, joel-U3u1mxZcP9KHXe+LvDLADg@public.gmane.org,
        jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pgynther-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jaedon.shin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Doug Berger <opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This collection of patches contains changes related to adding
support for the BCM7260, BCM7268, and BCM7271 devices that
contain a new version of the GENET MAC IP block (v5) and a new
fast ethernet (10/100BASE-T) internal PHY.

These patches were originally developed on top of the bug fixes
of the "[PATCH v2 net 0/8] net: bcmgenet: minor bug fixes" patch
set previously accepted into the net repository, but this
submission is designed to be applied to the current net-next
that does not yet include them. As a result there will be some
merge conflicts that I would be happy to help resolve if desired.

Specifically, conflicts should occur with these patches from the
minor bug fixes set:
[PATCH v2 net 3/8] net: bcmgenet: reserved phy revisions must be checked first
[PATCH v2 net 5/8] net: bcmgenet: synchronize irq0 status between the isr and task
[PATCH v2 net 8/8] net: bcmgenet: decouple flow control from bcmgenet_tx_reclaim

Doug Berger (12):
  net: phy: bcm-phylib: replace obsolete EEE macro references
  net: phy: bcm7xxx: add support for 28nm EPHY
  net: bcmgenet: simplify circular pointer arithmetic
  net: bcmgenet: remove meaningless lines
  net: bcmgenet: manage dma interrupts in napi code
  net: bcmgenet: remove handling of wol interrupts from isr0
  net: bcmgenet: clear status to reduce spurious interrupts
  net: bcmgenet: correct return value of __bcmgenet_tx_reclaim
  net: bcmgenet: return EOPNOTSUPP for unknown ioctl commands
  dt-bindings: net: document bcmgenet WoL interrupt
  dt-bindings: net: update bcmgenet binding for GENETv5
  net: bcmgenet: add support for the GENETv5 hardware

 .../devicetree/bindings/net/brcm,bcmgenet.txt      |  19 +-
 .../devicetree/bindings/net/brcm,unimac-mdio.txt   |   5 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     | 214 +++++++++++---------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h     |  10 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c |  13 --
 drivers/net/ethernet/broadcom/genet/bcmmii.c       |  62 +++---
 drivers/net/phy/bcm-phy-lib.c                      |   6 +-
 drivers/net/phy/bcm7xxx.c                          | 215 ++++++++++++++++++++-
 include/linux/brcmphy.h                            |   3 +
 9 files changed, 403 insertions(+), 144 deletions(-)

-- 
2.11.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
