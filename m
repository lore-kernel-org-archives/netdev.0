From: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v4 0/5] Bluetooth: 6LoWPAN: Fix lladdr length
Date: Tue, 21 Feb 2017 12:38:05 +0200
Message-ID: <20170221103811.1506-1-luiz.dentz@gmail.com>
Cc: patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
        linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

These patches fixes lladdr length to be 6 bytes long and not 8 which cause
neighbor advertisement to be sent with wrong lladdr including FF:FE filler
bytes for eui64/iid.

Note: This does not fix some of the existing crashes which I hope to address
in a different set.

v2: Make all code paths that generate a link-local from lladdr use the same
code.
v3: Use lowpan_iphc_uncompress_eui48_lladdr to generate the remote ip address.
v4: Handle comments from Stefan Schmidt.

Alexander Aring (2):
  6lowpan: iphc: override l2 packet information
  ipv6: addrconf: fix 48 bit 6lowpan autoconfiguration

Luiz Augusto von Dentz (1):
  6lowpan: Use netdev addr_len to determine lladdr len

Patrik Flykt (2):
  bluetooth: Set 6 byte device addresses
  6lowpan: Set MAC address lenght according to LOWPAN_LLTYPE

 include/net/6lowpan.h   | 19 +++++++++++++++++
 net/6lowpan/core.c      | 11 +++++++++-
 net/6lowpan/iphc.c      | 57 ++++++++++++++++++++++++++++++++++++++-----------
 net/bluetooth/6lowpan.c | 52 +++++++++++---------------------------------
 net/ipv6/addrconf.c     | 17 ++++++++++-----
 5 files changed, 99 insertions(+), 57 deletions(-)

-- 
2.9.3
