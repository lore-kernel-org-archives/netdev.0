From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] fix IGMPV3_EXP() normalization bit shift value
Date: Thu, 16 Nov 2006 18:49:30 -0700
Message-ID: <OF53C62317.D1729E3A-ON88257229.0008EA38-88257229.000A067D@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 000A067B88257229_="
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:174 "EHLO e36.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1424892AbWKQBth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 20:49:37 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAH1nVUL013725
	for <netdev@vger.kernel.org>; Thu, 16 Nov 2006 20:49:31 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAH1nVng363444
	for <netdev@vger.kernel.org>; Thu, 16 Nov 2006 18:49:31 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAH1nVvW016040
	for <netdev@vger.kernel.org>; Thu, 16 Nov 2006 18:49:31 -0700
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=_mixed 000A067B88257229_=
Content-Type: text/plain; charset="US-ASCII"

The IGMPV3_EXP() macro doesn't correctly shift the normalization bit, so
time-out values are longer than they should be. Patch below for viewing
and attached for applying.

Thanks to Dirk Ooms for finding the problem in IGMPv3 - MLDv2 had a
similar problem that was already fixed a year ago. :-(

                                                +-DLS

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

--- linux-2.6.19-rc5/include/linux/igmp.h       2006-11-16 
16:11:53.000000000 -0800
+++ linux-2.6.19-rc5T1/include/linux/igmp.h     2006-11-16 
16:15:46.000000000 -0800
@@ -191,7 +191,7 @@ struct ip_mc_list
 #define IGMPV3_MASK(value, nb) ((nb)>=32 ? (value) : ((1<<(nb))-1) & 
(value))
 #define IGMPV3_EXP(thresh, nbmant, nbexp, value) \
        ((value) < (thresh) ? (value) : \
-        ((IGMPV3_MASK(value, nbmant) | (1<<(nbmant+nbexp))) << \
+        ((IGMPV3_MASK(value, nbmant) | (1<<(nbmant))) << \
          (IGMPV3_MASK((value) >> (nbmant), nbexp) + (nbexp))))
 
 #define IGMPV3_QQIC(value) IGMPV3_EXP(0x80, 4, 3, value)


--=_mixed 000A067B88257229_=
Content-Type: application/octet-stream; name="mc.patch"
Content-Disposition: attachment; filename="mc.patch"
Content-Transfer-Encoding: base64

LS0tIGxpbnV4LTIuNi4xOS1yYzUvaW5jbHVkZS9saW51eC9pZ21wLmgJMjAwNi0xMS0xNiAxNjox
MTo1My4wMDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi4xOS1yYzVUMS9pbmNsdWRlL2xpbnV4
L2lnbXAuaAkyMDA2LTExLTE2IDE2OjE1OjQ2LjAwMDAwMDAwMCAtMDgwMApAQCAtMTkxLDcgKzE5
MSw3IEBAIHN0cnVjdCBpcF9tY19saXN0CiAjZGVmaW5lIElHTVBWM19NQVNLKHZhbHVlLCBuYikg
KChuYik+PTMyID8gKHZhbHVlKSA6ICgoMTw8KG5iKSktMSkgJiAodmFsdWUpKQogI2RlZmluZSBJ
R01QVjNfRVhQKHRocmVzaCwgbmJtYW50LCBuYmV4cCwgdmFsdWUpIFwKIAkoKHZhbHVlKSA8ICh0
aHJlc2gpID8gKHZhbHVlKSA6IFwKLSAgICAgICAgKChJR01QVjNfTUFTSyh2YWx1ZSwgbmJtYW50
KSB8ICgxPDwobmJtYW50K25iZXhwKSkpIDw8IFwKKyAgICAgICAgKChJR01QVjNfTUFTSyh2YWx1
ZSwgbmJtYW50KSB8ICgxPDwobmJtYW50KSkpIDw8IFwKICAgICAgICAgIChJR01QVjNfTUFTSygo
dmFsdWUpID4+IChuYm1hbnQpLCBuYmV4cCkgKyAobmJleHApKSkpCiAKICNkZWZpbmUgSUdNUFYz
X1FRSUModmFsdWUpIElHTVBWM19FWFAoMHg4MCwgNCwgMywgdmFsdWUpCg==

--=_mixed 000A067B88257229_=--
