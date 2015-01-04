From: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v1 0/7] net: extend ethtool link mode bitmaps to 48 bits
Date: Sun,  4 Jan 2015 12:56:50 -0800
Message-ID: <1420405017-23278-1-git-send-email-ddecotig@gmail.com>
Cc: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Masatake YAMATO <yamato-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Xi Wang <xii-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	WANG Cong <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>
To: Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>

This patch series increases the width of the supported/advertising
ethtool masks from 32 bits to 48. This should allow to breathe for a
couple more years (or... months?).

It should not cause any backward compatibility issues for now, as long
as non-updated drivers don't depend on link modes beyond bit 31. But
it is recommended we gradually adopt the new get/set API in order to
correctly support future link modes. See ethtool.h for details.

I updated a couple drivers (mlx4, veth, tun), and some shared code in
drivers/net (phy, mii, mdio). It might be overkill for phy/mii/mdio,
and I might have missed other shared code in drivers/net. Please let
me know.

I used the compiler on my private copy to 1/ track where the
ethtool_cmd/ethtool_eee link mode fields were used 2/ track where the
link mode bitmaps are used and updated. So I believe that there is
some sort of transitive closure for the code I updated. Maybe tools
like coccinelle or clang could allow to automate these processes (1/
would probably be easy-ish, but 2/ seems a bit more complex)? I
reverted these internal "tracking" tricks for this version to minimize
impact on uapi/ethtool.h. The main resulting visible artifact of those
tricks is the new ethtool_link_mode_mask_t typedef (aka. u64). I kept
this trivial typedef here to help future refactoring, but I'd be happy
to rename it as plain "u64" if you prefer.

I can send updates to other drivers, even though it's rather pointless
to update 1G drivers at this point for example. Please let me know,
but I'd prefer to do this in follow-up patches outside this first
patch series.

############################################
# Patch Set Summary:

David Decotigny (7):
  net: ethtool: extend link mode support to 48 bits
  net: phy: extend link mode support to 48 bits
  net: mii: extend link mode support to 48 bits
  net: mdio: extend link mode support to 48 bits
  net: veth: extend link mode support to 48 bits
  net: tun: extend link mode support to 48 bits
  net: mlx4_en: extend link mode support to 48 bits

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  67 +++++++-----
 drivers/net/mdio.c                              |  59 ++++++-----
 drivers/net/mii.c                               |  52 +++++-----
 drivers/net/phy/phy.c                           |  29 +++---
 drivers/net/phy/phy_device.c                    |   4 +-
 drivers/net/tun.c                               |   4 +-
 drivers/net/veth.c                              |   4 +-
 include/linux/mdio.h                            |  15 +--
 include/linux/mii.h                             |  31 +++---
 include/linux/phy.h                             |  10 +-
 include/uapi/linux/ethtool.h                    | 130 ++++++++++++++++++++----
 11 files changed, 262 insertions(+), 143 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
