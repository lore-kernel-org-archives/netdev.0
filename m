From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 00/12] Fix net header dependencies
Date: Mon, 08 Aug 2011 14:15:02 +0100
Message-ID: <1312809302.2591.1139.camel@deadeye>
References: <20110807.224829.233892140193944735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-kBd4i3LBKk4mkSAf4HUD"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55877 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751318Ab1HHNPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 09:15:11 -0400
In-Reply-To: <20110807.224829.233892140193944735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kBd4i3LBKk4mkSAf4HUD
Content-Type: multipart/mixed; boundary="=-LRRZCr3Gn7U1JduE2AIQ"


--=-LRRZCr3Gn7U1JduE2AIQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Various networking headers depend on definitions from others which they
don't include.  We can't fix all of these, because some definitions are
duplicated between kernel headers and glibc headers and we cannot tell
which is the right one to include.  We also have to be wary of
introducing a dependency cycle.

The attached test program tests whether various header inclusion
sequences work, in the sense that compilation is successful.  I used gcc
4.6.1, eglibc 2.13, and kernel headers from Linux 3.0 initially  This
resulted in 120 failures.  After the following changes, there are 65
failures and no regressions.

Ben.

Ben Hutchings (12):
  headers, pppox: Add missing #include to <linux/if_pppox.h>
  headers, ax25: Add missing #include to <linux/netrom.h>,
    <linux/rose.h>
  headers, pppol2tp: Use __kernel_pid_t in <linux/pppol2tp.h>
  headers, net: Use __kernel_sa_family_t in more definitions shared
    with userland
  headers, net: Define struct __kernel_sockaddr, replacing struct
    sockaddr
  headers, netfilter: Use kernel type names __u8, __u16, __u32
  headers, tipc: Add missing #include to <linux/tipc_config.h> for
    userland
  headers, netfilter: Add missing #include <limits.h> for userland
  headers, xtables: Add missing #include <linux/netfilter.h>
  headers, can: Add missing #include to <linux/can/bcm.h>
  headers, scc: Add missing #include to <linux/scc.h>
  headers, ppp: Add missing #include to <linux/if_ppp.h>

 include/linux/atalk.h                     |    3 ++-
 include/linux/ax25.h                      |    2 +-
 include/linux/caif/caif_socket.h          |    7 +------
 include/linux/can.h                       |    2 +-
 include/linux/can/bcm.h                   |    1 +
 include/linux/if.h                        |   12 ++++++------
 include/linux/if_ppp.h                    |    1 +
 include/linux/if_pppol2tp.h               |    2 +-
 include/linux/if_pppox.h                  |    9 +++++----
 include/linux/in.h                        |    2 +-
 include/linux/ipx.h                       |    2 +-
 include/linux/irda.h                      |    9 +++------
 include/linux/l2tp.h                      |    7 ++++---
 include/linux/llc.h                       |   10 +++++++---
 include/linux/netfilter/xt_connlimit.h    |    1 +
 include/linux/netfilter/xt_conntrack.h    |    1 +
 include/linux/netfilter/xt_iprange.h      |    1 +
 include/linux/netfilter_arp/arp_tables.h  |   14 +++++++-------
 include/linux/netfilter_decnet.h          |    3 +++
 include/linux/netfilter_ipv4.h            |    3 +++
 include/linux/netfilter_ipv4/ip_tables.h  |   20 ++++++++++----------
 include/linux/netfilter_ipv6.h            |    3 +++
 include/linux/netfilter_ipv6/ip6_tables.h |   22 +++++++++++-----------
 include/linux/netlink.h                   |    2 +-
 include/linux/netrom.h                    |    2 ++
 include/linux/phonet.h                    |    6 ++++--
 include/linux/rose.h                      |    7 +++++--
 include/linux/scc.h                       |    1 +
 include/linux/socket.h                    |   17 +++++++++--------
 include/linux/tipc_config.h               |    4 ++++
 include/linux/un.h                        |    4 +++-
 include/linux/x25.h                       |    3 ++-
 32 files changed, 106 insertions(+), 77 deletions(-)

--=20
1.7.5.4



--=-LRRZCr3Gn7U1JduE2AIQ
Content-Type: application/x-shellscript; name="net-header-test.sh"
Content-Disposition: attachment; filename="net-header-test.sh"
Content-Transfer-Encoding: base64

IyEvYmluL2Jhc2gKCiMgR2VuZXJhdGVkIHdpdGg6CiMgICAgIG1ha2UgaGVhZGVyc19pbnN0YWxs
CiMgICAgIGZpbmQgdXNyL2luY2x1ZGUvbGludXggLW5hbWUgJyouaCcgfCB4YXJncyBlZ3JlcCAt
bCAnc29ja2V0fHNvY2thZGRyfGlmcmVxfFNJT0N8aW5ldCcgfCBzZWQgJ3MsXnVzci9pbmNsdWRl
LywsJwojIGFuZCBzb21lIG1hbnVhbCBzYW5pdHktY2hlY2tpbmcuCmhlYWRlcnM9JwpsaW51eC9p
bmV0X2RpYWcuaApsaW51eC9uZXRmaWx0ZXJfaXB2NC9pcF90YWJsZXMuaApsaW51eC9uZXRmaWx0
ZXJfaXB2NC9pcHRfTE9HLmgKbGludXgvbmZzX21vdW50LmgKbGludXgvaWZfYm9uZGluZy5oCmxp
bnV4L2lmX2ZyYWQuaApsaW51eC9pcF92cy5oCmxpbnV4L3BrdF9jbHMuaApsaW51eC94MjUuaAps
aW51eC9uZXRmaWx0ZXIveHRfY29ubnRyYWNrLmgKbGludXgvbmV0ZmlsdGVyL3h0X2Nvbm5saW1p
dC5oCmxpbnV4L25ldGZpbHRlci94dF9pcHJhbmdlLmgKbGludXgvbmV0ZmlsdGVyL25mbmV0bGlu
a19sb2cuaApsaW51eC9uZXRmaWx0ZXIvbmZuZXRsaW5rX2NvbXBhdC5oCmxpbnV4L2lmX3BwcC5o
CmxpbnV4L3Jvc2UuaApsaW51eC9hdG1icjI2ODQuaApsaW51eC9pZl9zbGlwLmgKbGludXgvbWlp
LmgKbGludXgvY2FuLmgKbGludXgvYXRtLmgKbGludXgvY2FpZi9pZl9jYWlmLmgKbGludXgvY2Fp
Zi9jYWlmX3NvY2tldC5oCmxpbnV4L3NjYy5oCmxpbnV4L2RjY3AuaApsaW51eC9pcHY2LmgKbGlu
dXgvYXRtbGVjLmgKbGludXgvbmV0bGluay5oCmxpbnV4L2lmX3BhY2tldC5oCmxpbnV4L3VkcC5o
CmxpbnV4L2lzZG4uaApsaW51eC9pZl9lYy5oCmxpbnV4L3dhbnJvdXRlci5oCmxpbnV4L25ldGZp
bHRlci5oCmxpbnV4L2lmX3R1bm5lbC5oCmxpbnV4L2lyZGEuaApsaW51eC9pZl9wcHBvbDJ0cC5o
CmxpbnV4L21yb3V0ZTYuaApsaW51eC9hdG1wcHAuaApsaW51eC9kbi5oCmxpbnV4L25ldHJvbS5o
CmxpbnV4L25ldC5oCmxpbnV4L25mczRfbW91bnQuaApsaW51eC9hdG1jbGlwLmgKbGludXgvaWZf
cHBwb3guaApsaW51eC9tcm91dGUuaApsaW51eC93aXJlbGVzcy5oCmxpbnV4L3NvY2tpb3MuaAps
aW51eC9uY3BfZnMuaApsaW51eC9pZl9wbGlwLmgKbGludXgvaWZfZXFsLmgKbGludXgvdGlwYy5o
CmxpbnV4L3NvY2tldC5oCmxpbnV4L2lmLmgKbGludXgveGZybS5oCmxpbnV4L2F0bWRldi5oCmxp
bnV4L2lmX2NhYmxlbW9kZW0uaApsaW51eC9icHFldGhlci5oCmxpbnV4L2VycnF1ZXVlLmgKbGlu
dXgvaW42LmgKbGludXgvbmNwX21vdW50LmgKbGludXgvYXRhbGsuaApsaW51eC9uZXRmaWx0ZXJf
YXJwL2FycF90YWJsZXMuaApsaW51eC9uZnNkL3N5c2NhbGwuaApsaW51eC9pbi5oCmxpbnV4L2lm
X2FycC5oCmxpbnV4L2Nhbi9iY20uaApsaW51eC9jYW4vcmF3LmgKbGludXgvY2FuL25ldGxpbmsu
aApsaW51eC9jYW4vZXJyb3IuaApsaW51eC9tcXVldWUuaApsaW51eC9heDI1LmgKbGludXgvbGxj
LmgKbGludXgvdGNwLmgKbGludXgvYXVkaXQuaApsaW51eC91bi5oCmxpbnV4L2F0bWFycC5oCmxp
bnV4L3Bob25ldC5oCmxpbnV4L25ldGZpbHRlcl9pcHY2L2lwNnRfTE9HLmgKbGludXgvbmV0Zmls
dGVyX2lwdjYvaXA2X3RhYmxlcy5oCmxpbnV4L3JvdXRlLmgKbGludXgvcGt0X3NjaGVkLmgKbGlu
dXgvYXRtc3ZjLmgKbGludXgvcnRuZXRsaW5rLmgKbGludXgvaXB4LmgKbGludXgvdGlwY19jb25m
aWcuaApsaW51eC9hdG1fdGNwLmgKJwoKQ0M9JHtDQzotY2N9CkNGTEFHUz0iLURfX1NUUklDVF9L
RVJORUxfTkFNRVMgLVdhbGwgJENGTEFHUyIKCmZvciBoZWFkZXIgaW4gJGhlYWRlcnM7IGRvCiAg
ICBlY2hvICctLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLScKICAgIGVjaG8gIkluY2x1ZGUgPCRoZWFkZXI+IGFsb25lOiIK
ICAgIGVjaG8gPiB0ZXN0LmMgIiNpbmNsdWRlIDwkaGVhZGVyPiIKICAgIGVjaG8gPj50ZXN0LmMg
ImludCBtYWluKHZvaWQpIHsgcmV0dXJuIDA7IH0iCiAgICAkQ0MgJENGTEFHUyB0ZXN0LmMgJiYg
ZWNobyBQQVNTIHx8IGVjaG8gRkFJTApkb25lCgpmb3IgaGVhZGVyIGluICRoZWFkZXJzOyBkbwog
ICAgZWNobyAnLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0nCiAgICBlY2hvICJJbmNsdWRlIDwkaGVhZGVyPiB0aGVuIDxz
eXMvc29ja2V0Lmg+OiIKICAgIGVjaG8gPiB0ZXN0LmMgIiNpbmNsdWRlIDwkaGVhZGVyPiIKICAg
IGVjaG8gPj50ZXN0LmMgIiNpbmNsdWRlIDxzeXMvc29ja2V0Lmg+IgogICAgZWNobyA+PnRlc3Qu
YyAiaW50IG1haW4odm9pZCkgeyByZXR1cm4gMDsgfSIKICAgICRDQyAkQ0ZMQUdTIHRlc3QuYyAm
JiBlY2hvIFBBU1MgfHwgZWNobyBGQUlMCmRvbmUKCmZvciBoZWFkZXIgaW4gJGhlYWRlcnM7IGRv
CiAgICBlY2hvICctLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLScKICAgIGVjaG8gIkluY2x1ZGUgPHN5cy9zb2NrZXQuaD4g
dGhlbiA8JGhlYWRlcj46IgogICAgZWNobyA+IHRlc3QuYyAiI2luY2x1ZGUgPHN5cy9zb2NrZXQu
aD4iCiAgICBlY2hvID4+dGVzdC5jICIjaW5jbHVkZSA8JGhlYWRlcj4iCiAgICBlY2hvID4+dGVz
dC5jICJpbnQgbWFpbih2b2lkKSB7IHJldHVybiAwOyB9IgogICAgJENDICRDRkxBR1MgdGVzdC5j
ICYmIGVjaG8gUEFTUyB8fCBlY2hvIEZBSUwKZG9uZQoKZm9yIGhlYWRlciBpbiAkaGVhZGVyczsg
ZG8KICAgIGVjaG8gJy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tJwogICAgZWNobyAiSW5jbHVkZSA8bmV0aW5ldC9pbi5o
PiwgPG5ldC9pZi5oPiB0aGVuIDwkaGVhZGVyPjoiCiAgICBjYXNlICRoZWFkZXIgaW4KICAgICAg
ICAjIFdlIGFzc3VtZSB0aGVzZSBhcmUgaW5jb21wYXRpYmxlIGFuZCByZWR1bmRhbnQgd2l0aCB0
aGUgYWJvdmUKCWxpbnV4L2lmLmggfCBsaW51eC9pbi5oIHwgbGludXgvaW42LmggfCBsaW51eC9y
b3V0ZS5oKQoJICAgIGVjaG8gU0tJUAoJICAgIGNvbnRpbnVlCgkgICAgOzsKCSopCgkgICAgOzsK
ICAgIGVzYWMKICAgIGVjaG8gPiB0ZXN0LmMgIiNpbmNsdWRlIDxuZXRpbmV0L2luLmg+IgogICAg
ZWNobyA+PnRlc3QuYyAiI2luY2x1ZGUgPG5ldC9pZi5oPiIKICAgIGVjaG8gPj50ZXN0LmMgIiNp
bmNsdWRlIDwkaGVhZGVyPiIKICAgIGVjaG8gPj50ZXN0LmMgImludCBtYWluKHZvaWQpIHsgcmV0
dXJuIDA7IH0iCiAgICAkQ0MgJENGTEFHUyB0ZXN0LmMgJiYgZWNobyBQQVNTIHx8IGVjaG8gRkFJ
TApkb25lCgpybSAtZiB0ZXN0LmMgYS5vdXQK


--=-LRRZCr3Gn7U1JduE2AIQ--

--=-kBd4i3LBKk4mkSAf4HUD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATj/hVee/yOyVhhEJAQpAMRAAia9mtIvjLAicBJGLdkbNZ7MpBWiaTfDc
5afK37FHfc/O1to1EnshrzJ3ke+7unO+2a1Fw9IFk3/B0qTZr5QNBnD+4QhL/hRF
Ac/uk6AQZsrxKXx1sUN3LHQQbuNgpCxLCD0pxWJ2FXRWG8XL9+lajB6u3BCtV0kz
S639i1X7k2PGwka3xbdf+ZarxQBS1H7jS5fp5wzbrhNCNpVJ8uvSGcpeKtSsdCBR
85v0vp4/kOIPJfDftL5oVrym75u4Ldozlm4jCL+Qi5NU6nE9GEXiXG6YKS+J/JsM
ycxSbDuPrOAyDo1v9CIXVl8MYBh/eL54mdYKDTWobegBOjcqV8U7aaYcjNsdjiWe
+r5z5mZ8CGTuw/2dE30FllDBz2WOdenl2wIyxvkWkFKMR+ZQYcD4q5PzZgSTnLfN
9zP6QswKCU+8YtbxUzPHJSau8IQ3DTyuiLdAoahYpbEUHsKwAP5xl9GqCVVvn5sP
XH2SqSp3Ub52H+xHIQ8EF6vNsKe9+fpUy3yjV6fIpf0gZpG9459jExXrajvxva1W
1xP0n/XBsloFpv1XDMiTm4+w3wg4QOs7jzrRbhQg430MPShdJmGmsdZMOAdJLLNi
MijoEfFyNuL6qJ1sp0UsXgx7oVaiyLlmH+ASNjbJtwJr09dM+HzpQMIRJ4VtTNo4
NgRpOKgvN0s=
=rFCn
-----END PGP SIGNATURE-----

--=-kBd4i3LBKk4mkSAf4HUD--
