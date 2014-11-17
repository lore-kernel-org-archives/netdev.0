From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Mon, 17 Nov 2014 13:34:04 +1100
Message-ID: <20141117133404.525229b4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Cv9hVhKNDupdKAOq1R5oc+R"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jarno Rajahalme <jrajahalme@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/Cv9hVhKNDupdKAOq1R5oc+R
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (x86_64 allmodcon=
fig)
failed like this:

In file included from include/linux/printk.h:6:0,
                 from include/linux/kernel.h:13,
                 from net/openvswitch/flow.h:23,
                 from net/openvswitch/flow_netlink.c:21:
net/openvswitch/flow_netlink.c: In function 'ovs_key_from_nlattrs':
include/linux/kern_levels.h:4:18: error: called object is not a function or=
 function pointer
 #define KERN_SOH "\001"  /* ASCII Start Of Header */
                  ^
include/linux/kern_levels.h:13:19: note: in expansion of macro 'KERN_SOH'
 #define KERN_INFO KERN_SOH "6" /* informational */
                   ^
include/linux/printk.h:247:9: note: in expansion of macro 'KERN_INFO'
  printk(KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
         ^
net/openvswitch/datapath.h:205:3: note: in expansion of macro 'pr_info'
   pr_info("netlink: " fmt "\n", ##__VA_ARGS__); \
   ^
net/openvswitch/flow_netlink.c:777:4: note: in expansion of macro 'OVS_NLER=
R'
    OVS_NLERR("IPv6 flow label %x is out of range (max=3D%x).\n",
    ^
net/openvswitch/datapath.h:205:27: error: expected ')' before string consta=
nt
   pr_info("netlink: " fmt "\n", ##__VA_ARGS__); \
                           ^
net/openvswitch/flow_netlink.c:19:41: note: in definition of macro 'pr_fmt'
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
                                         ^
net/openvswitch/datapath.h:205:3: note: in expansion of macro 'pr_info'
   pr_info("netlink: " fmt "\n", ##__VA_ARGS__); \
   ^
net/openvswitch/flow_netlink.c:777:4: note: in expansion of macro 'OVS_NLER=
R'
    OVS_NLERR("IPv6 flow label %x is out of range (max=3D%x).\n",
    ^

Caused by commit 05da5898a96c ("openvswitch: Add support for
OVS_FLOW_ATTR_PROBE") interacting with commit fecaef85f718
("openvswitch: Validate IPv6 flow key and mask values") from the net
tree.

I applied the following merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 17 Nov 2014 13:31:33 +1100
Subject: [PATCH] openvswitch: fix up for OVS_NLERR API change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/openvswitch/flow_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 259b2f1ebd0d..45bdcf596414 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -774,7 +774,7 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *m=
atch, u64 attrs,
 		}
=20
 		if (ipv6_key->ipv6_label & htonl(0xFFF00000)) {
-			OVS_NLERR("IPv6 flow label %x is out of range (max=3D%x).\n",
+			OVS_NLERR(log, "IPv6 flow label %x is out of range (max=3D%x).\n",
 				  ntohl(ipv6_key->ipv6_label), (1 << 20) - 1);
 			return -EINVAL;
 		}
--=20
2.1.3

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/Cv9hVhKNDupdKAOq1R5oc+R
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUaV6hAAoJEMDTa8Ir7ZwVedYP/jqX0WKGoLujm6BbB07nV9+r
fjiB29xTdPWdCNsFok2XAd6Iv/ut8mkhYZlk0NwXmRgyudZ8lxX2vi87unNB6PSE
3NSi79kEQ5o/P67XB9zip7GYE4kEzIr044OdMdazUHe19A3KoH14keSG4l4tJoK3
IpkUoT7F8OU6Dg7rOJIE9i6h4fs7nvMNBwa8Wd1WDLfccxQiYUJ82r+1RmdQKXGN
banXQzKuCijfbFhH+4jDOW4PIdiVWPFB9+d9aHOEOBxVK85uu+wnV74RUfONFlhD
chiFrxPSf9vsp12cRVKl8QnMifuiUt+biwLGHo4VaAHy1N7It8bofoAczd0x99cQ
51dsaMzj5F+zIWqtnCY0wjPUGy0qYVmwKshs4+ny/pHw0Vrz40+MGsg11B81HdJy
1MESNphzQZUENYPwZT6nIHj2/Yb1A4CsRtlMdXsfW8Fvpl7SM5qpVtpCUu3nAbvL
hBl1y7mQo0TOguFI1sDV5uexHpOlA75pYUoi8ZaP/Wf9tbGKGyct1iTxh+JmLa/d
M+SUYVsmRX5ckbg7VriakLAtss/ml59L/l56KV+nrr0I8scd3FivHCA3I17Iz26T
Lnjcqjoooc6IHjySdxO3v1NUKDCrIzoePw9aunKIxi+j/S6sG6KLA1vdJtCWh1BO
xk1sQtX0zIHvvBIADYb3
=8pf0
-----END PGP SIGNATURE-----

--Sig_/Cv9hVhKNDupdKAOq1R5oc+R--
