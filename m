From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netns: fix net.ipv6.route.gc_min_interval_ms in netns
Date: Fri, 18 Dec 2009 16:16:40 +0200
Message-ID: <b6fcc0a0912180616m54c0d25dn56f008c9d736e505@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0015174c37407313cf047b016307
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:50685 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572AbZLROQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 09:16:42 -0500
Received: by bwz27 with SMTP id 27so2174079bwz.21
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 06:16:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0015174c37407313cf047b016307
Content-Type: text/plain; charset=ISO-8859-1

Sorry for attachment, my patch sending facility is defunct right now.
Copying inline for review.

commit ee0270199605e58c76294f62ba8fbc0f583ccd3e
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Fri Dec 18 16:08:04 2009 +0200

    netns: fix net.ipv6.route.gc_min_interval_ms in netns

    sysctl table was copied, all right, but ->data for
net.ipv6.route.gc_min_interval_ms
    was not reinitialized for "!= &init_net" case.

    In init_net everthing works by accident due to correct ->data initialization
    in source table.

    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index db3b273..c2bd74c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2630,6 +2630,7 @@ struct ctl_table *ipv6_route_sysctl_init(struct net *net)
 		table[6].data = &net->ipv6.sysctl.ip6_rt_gc_elasticity;
 		table[7].data = &net->ipv6.sysctl.ip6_rt_mtu_expires;
 		table[8].data = &net->ipv6.sysctl.ip6_rt_min_advmss;
+		table[9].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;
 	}

 	return table;

--0015174c37407313cf047b016307
Content-Type: text/x-diff; charset=US-ASCII; name="gc-min-interval.patch"
Content-Disposition: attachment; filename="gc-min-interval.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g3d1kvog0

Y29tbWl0IGVlMDI3MDE5OTYwNWU1OGM3NjI5NGY2MmJhOGZiYzBmNTgzY2NkM2UKQXV0aG9yOiBB
bGV4ZXkgRG9icml5YW4gPGFkb2JyaXlhbkBnbWFpbC5jb20+CkRhdGU6ICAgRnJpIERlYyAxOCAx
NjowODowNCAyMDA5ICswMjAwCgogICAgbmV0bnM6IGZpeCBuZXQuaXB2Ni5yb3V0ZS5nY19taW5f
aW50ZXJ2YWxfbXMgaW4gbmV0bnMKICAgIAogICAgc3lzY3RsIHRhYmxlIHdhcyBjb3BpZWQsIGFs
bCByaWdodCwgYnV0IC0+ZGF0YSBmb3IgbmV0LmlwdjYucm91dGUuZ2NfbWluX2ludGVydmFsX21z
CiAgICB3YXMgbm90IHJlaW5pdGlhbGl6ZWQgZm9yICIhPSAmaW5pdF9uZXQiIGNhc2UuCiAgICAK
ICAgIEluIGluaXRfbmV0IGV2ZXJ0aGluZyB3b3JrcyBieSBhY2NpZGVudCBkdWUgdG8gY29ycmVj
dCAtPmRhdGEgaW5pdGlhbGl6YXRpb24KICAgIGluIHNvdXJjZSB0YWJsZS4KCiAgICBTaWduZWQt
b2ZmLWJ5OiBBbGV4ZXkgRG9icml5YW4gPGFkb2JyaXlhbkBnbWFpbC5jb20+CgpkaWZmIC0tZ2l0
IGEvbmV0L2lwdjYvcm91dGUuYyBiL25ldC9pcHY2L3JvdXRlLmMKaW5kZXggZGIzYjI3My4uYzJi
ZDc0YyAxMDA2NDQKLS0tIGEvbmV0L2lwdjYvcm91dGUuYworKysgYi9uZXQvaXB2Ni9yb3V0ZS5j
CkBAIC0yNjMwLDYgKzI2MzAsNyBAQCBzdHJ1Y3QgY3RsX3RhYmxlICppcHY2X3JvdXRlX3N5c2N0
bF9pbml0KHN0cnVjdCBuZXQgKm5ldCkKIAkJdGFibGVbNl0uZGF0YSA9ICZuZXQtPmlwdjYuc3lz
Y3RsLmlwNl9ydF9nY19lbGFzdGljaXR5OwogCQl0YWJsZVs3XS5kYXRhID0gJm5ldC0+aXB2Ni5z
eXNjdGwuaXA2X3J0X210dV9leHBpcmVzOwogCQl0YWJsZVs4XS5kYXRhID0gJm5ldC0+aXB2Ni5z
eXNjdGwuaXA2X3J0X21pbl9hZHZtc3M7CisJCXRhYmxlWzldLmRhdGEgPSAmbmV0LT5pcHY2LnN5
c2N0bC5pcDZfcnRfZ2NfbWluX2ludGVydmFsOwogCX0KIAogCXJldHVybiB0YWJsZTsK
--0015174c37407313cf047b016307--
