From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: [PATCH net-next 0/2] break include loop and dsa devlink support
Date: Tue, 28 Mar 2017 23:45:05 +0200
Message-ID: <1490737507-7864-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
        linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These two patches add very basic support for devlink to DSA, in
preparation for playing with dpipe.

The first patch is needed to break an include loop between
netdevice.h, dsa.h and devlink.h. We need to remove dsa.h from
netdevice.h. As a result, some files fail to compile, because they
require includes pulled in via dsa.h. So this patch adds a number of
includes in various places. The majority is within the network
subsystem, but cifs also needs a few fixes.

0-day has been chewing on this for over a day now, and not found any
breakage. But Arnd's randconfig might uncover something.

Andrew Lunn (2):
  net: break include loop netdevice.h, dsa.h, devlink.h
  net: dsa: dsa2: Add basic support of devlink

 drivers/net/dsa/bcm_sf2_cfp.c                    |  3 +-
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h            |  1 +
 drivers/net/ethernet/broadcom/bcmsysport.c       |  1 +
 drivers/net/ethernet/freescale/fman/fman_memac.h |  1 +
 drivers/net/ethernet/hisilicon/hns/hnae.c        |  2 +-
 drivers/net/ieee802154/mrf24j40.c                |  1 +
 drivers/net/phy/smsc.c                           |  1 +
 drivers/net/usb/lan78xx.c                        |  1 +
 fs/cifs/cifsfs.c                                 |  1 +
 fs/cifs/connect.c                                |  1 +
 fs/cifs/smb2pdu.c                                |  1 +
 include/linux/netdevice.h                        | 12 +-----
 include/net/dsa.h                                | 14 +++++++
 net/bridge/br_if.c                               |  1 +
 net/core/netprio_cgroup.c                        |  1 +
 net/dsa/dsa.c                                    |  3 +-
 net/dsa/dsa2.c                                   | 50 ++++++++++++++++++++++--
 net/dsa/slave.c                                  |  1 +
 net/dsa/tag_brcm.c                               |  1 +
 net/dsa/tag_dsa.c                                |  1 +
 net/dsa/tag_edsa.c                               |  1 +
 net/dsa/tag_qca.c                                |  1 +
 net/dsa/tag_trailer.c                            |  1 +
 net/ipv4/ipconfig.c                              |  1 +
 24 files changed, 86 insertions(+), 16 deletions(-)

-- 
2.11.0
