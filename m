From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 00/10] set addr_assign_type when inheriting a dev_addr
Date: Fri, 23 Aug 2013 11:35:03 +0200
Message-ID: <1377250513-3662-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jouni Malinen <j@w1.fi>,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	Forest Bond <forest-B/PTSs0AgtP3p6jHtUh95NHuzzzSOjJt@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Copying the dev_addr from a parent device is an operation
common to a number of drivers. The addr_assign_type should
be updated accordingly, either by reusing the value from
the source device or explicitly indicating that the address
is stolen by setting addr_assign_type to NET_ADDR_STOLEN.

This patch set adds a helper copying both the dev_addr and
the addr_assign_type, and use this helper in drivers which
don't currently set the addr_assign_type. Using NET_ADDR_STOLEN
might be more appropriate in some of these cases.  Please
let me know, and I'll update the patch accordingly.


Bj=C3=B8rn Mork (10):
  net: etherdevice: add address inherit helper
  net: vlan: inherit addr_assign_type along with dev_addr
  net: dsa: inherit addr_assign_type along with dev_addr
  net: macvlan: inherit addr_assign_type along with dev_addr
  net: team: inherit addr_assign_type along with dev_addr
  net: airo: inherit addr_assign_type along with dev_addr
  net: hostap: inherit addr_assign_type along with dev_addr
  net: libertas: inherit addr_assign_type along with dev_addr
  staging: vt6655: inherit addr_assign_type along with dev_addr
  staging: vt6656: inherit addr_assign_type along with dev_addr

 drivers/net/macvlan.c                     |    2 +-
 drivers/net/team/team.c                   |    2 +-
 drivers/net/wireless/airo.c               |    2 +-
 drivers/net/wireless/hostap/hostap_hw.c   |    2 +-
 drivers/net/wireless/hostap/hostap_main.c |    2 +-
 drivers/net/wireless/libertas/mesh.c      |    2 +-
 drivers/staging/vt6655/hostap.c           |    2 +-
 drivers/staging/vt6655/ioctl.c            |    2 +-
 drivers/staging/vt6655/wpactl.c           |    2 +-
 drivers/staging/vt6656/hostap.c           |    2 +-
 include/linux/etherdevice.h               |   19 +++++++++++++++++++
 net/8021q/vlan_dev.c                      |    2 +-
 net/dsa/slave.c                           |    2 +-
 13 files changed, 31 insertions(+), 12 deletions(-)

--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
