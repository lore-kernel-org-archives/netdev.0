From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net: Initialize all members in skb_gro_remcsum_init()
Date: Wed, 18 Feb 2015 11:38:06 +0100
Message-ID: <1424255886-20330-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb_gro_remcsum_init() initializes the gro_remcsum.delta member only,
leading to compiler warnings about a possibly uninitialized
gro_remcsum.offset member:

drivers/net/vxlan.c: In function =E2=80=98vxlan_gro_receive=E2=80=99:
drivers/net/vxlan.c:602: warning: =E2=80=98grc.offset=E2=80=99 may be u=
sed uninitialized in this function
net/ipv4/fou.c: In function =E2=80=98gue_gro_receive=E2=80=99:
net/ipv4/fou.c:262: warning: =E2=80=98grc.offset=E2=80=99 may be used u=
ninitialized in this function

While these are harmless for now:
  - skb_gro_remcsum_process() sets offset before changing delta,
  - skb_gro_remcsum_cleanup() checks if delta is non-zero before
    accessing offset,
it's safer to let the initialization function initialize all members.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 include/linux/netdevice.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5897b4ea5a3f9e0f..429d1790a27e85f3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2342,6 +2342,7 @@ struct gro_remcsum {
=20
 static inline void skb_gro_remcsum_init(struct gro_remcsum *grc)
 {
+	grc->offset =3D 0;
 	grc->delta =3D 0;
 }
=20
--=20
1.9.1
