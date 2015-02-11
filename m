From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] openvswitch: Add missing initialization in validate_and_copy_set_tun()
Date: Wed, 11 Feb 2015 11:23:38 +0100
Message-ID: <1423650218-24666-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/openvswitch/flow_netlink.c: In function =E2=80=98validate_and_copy_=
set_tun=E2=80=99:
net/openvswitch/flow_netlink.c:1749: warning: =E2=80=98err=E2=80=99 may=
 be used uninitialized in this function

If ipv4_tun_from_nlattr() returns a different positive value than
OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS, err will be uninitialized, and
validate_and_copy_set_tun() may return an undefined value instead of a
zero success indicator. Initialize err to zero to fix this.

=46ixes: 1dd144cf5b4b47e1 ("openvswitch: Support VXLAN Group Policy ext=
ension")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 net/openvswitch/flow_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netl=
ink.c
index 993281e6278dc829..3829328c5a7648bf 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1746,7 +1746,7 @@ static int validate_and_copy_set_tun(const struct=
 nlattr *attr,
 	struct sw_flow_key key;
 	struct ovs_tunnel_info *tun_info;
 	struct nlattr *a;
-	int err, start, opts_type;
+	int err =3D 0, start, opts_type;
=20
 	ovs_match_init(&match, &key, NULL);
 	opts_type =3D ipv4_tun_from_nlattr(nla_data(attr), &match, false, log=
);
--=20
1.9.1
