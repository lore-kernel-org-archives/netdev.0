From: "Syed Khader" <Syed.Khader@conexant.com>
Subject: [PATCH]: Fix for disabling rx when fifo overruns and potential dma deadlock in smc911x.c
Date: Mon, 10 Mar 2008 19:33:05 +0530
Message-ID: <02C837E0D6BC6741BD574EB1E35D900F022D235B@hyd-mail2.bbnet.ad>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="----_=_NextPart_001_01C882B7.7692734C"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnxtsmtp4.conexant.com ([198.62.9.251]:32942 "EHLO
	cnxtsmtp4.conexant.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbYCJODN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 10:03:13 -0400
Received: from CPS (wsmx1.nb.conexant.com [157.152.185.16]) (using TLSv1 with cipher RC4-MD5 (
 128/128 bits)) (No client certificate requested) by cnxtsmtp4.conexant.com (Tumbleweed MailGate
 3.5.1) with ESMTP id 2D13A2C6B6 for <netdev@vger.kernel.org>; Mon, 10 Mar 2008 07:03:13 -0700 (PDT)
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


------_=_NextPart_001_01C882B7.7692734C
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: quoted-printable

Hi
  This patch fixes following bugs in smc911x.c
1. Whenever there is rx overrun the driver simply disabling receiver.
Changes done to reenable it after dma for the last packet gets
completed.
2. When there is RX receive error, dma doesn't get scheduled, so
rxdma_active flag will not be reset, resulting in dma deadlock.

Thanks
Syed

Conexant E-mail Firewall (Conexant.Com) made the following annotations
---------------------------------------------------------------------
********************** Legal Disclaimer ****************************=20

"This email may contain confidential and privileged material for the sole =
=
use of the intended recipient. Any unauthorized review, use or distribution=
 =
by others is strictly prohibited. If you have received the message in error=
,=
 please advise the sender by reply email and delete the message. Thank you.=
"=
=20

**********************************************************************=20

---------------------------------------------------------------------


------_=_NextPart_001_01C882B7.7692734C
Content-Type: application/octet-stream;
 name=smc.patch
Content-Transfer-Encoding: base64
Content-Description: smc.patch
Content-Disposition: attachment;
 filename=smc.patch

LS0tIHNtYzkxMXguYy5vcmlnCTIwMDgtMDMtMTAgMTk6MTE6MzEuMDAwMDAwMDAwICswNTMwCisr
KyBzbWM5MTF4LmMJMjAwOC0wMy0xMCAxOToxMzoyMy4wMDAwMDAwMDAgKzA1MzAKQEAgLTQzNCw3
ICs0MzQsNyBAQAogICogdGhlIFJYIHN0YXR1cyBGSUZPLgkgSXQgbXVzdCBiZSBjYWxsZWQgd2l0
aCB0aGUgc3BpbiBsb2NrCiAgKiBhbHJlYWR5IGhlbGQuCiAgKi8KLXN0YXRpYyBpbmxpbmUgdm9p
ZAkgc21jOTExeF9yY3Yoc3RydWN0IG5ldF9kZXZpY2UgKmRldikKK3N0YXRpYyBpbmxpbmUgaW50
CSBzbWM5MTF4X3JjdihzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQogewogCXN0cnVjdCBzbWM5MTF4
X2xvY2FsICpscCA9IG5ldGRldl9wcml2KGRldik7CiAJdW5zaWduZWQgbG9uZyBpb2FkZHIgPSBk
ZXYtPmJhc2VfYWRkcjsKQEAgLTQ2MSw2ICs0NjEsNyBAQAogCQl9CiAJCS8qIFJlbW92ZSB0aGUg
YmFkIHBhY2tldCBkYXRhIGZyb20gdGhlIFJYIEZJRk8gKi8KIAkJc21jOTExeF9kcm9wX3BrdChk
ZXYpOworCQlyZXR1cm4gLTE7CiAJfSBlbHNlIHsKIAkJLyogUmVjZWl2ZSBhIHZhbGlkIHBhY2tl
dCAqLwogCQkvKiBBbGxvYyBhIGJ1ZmZlciB3aXRoIGV4dHJhIHJvb20gZm9yIERNQSBhbGlnbm1l
bnQgKi8KQEAgLTQ3MCw3ICs0NzEsNyBAQAogCQkJCWRldi0+bmFtZSk7CiAJCQlscC0+c3RhdHMu
cnhfZHJvcHBlZCsrOwogCQkJc21jOTExeF9kcm9wX3BrdChkZXYpOwotCQkJcmV0dXJuOworCQkJ
cmV0dXJuIC0xOwogCQl9CiAJCS8qIEFsaWduIElQIGhlYWRlciB0byAzMiBiaXRzCiAJCSAqIE5v
dGUgdGhhdCB0aGUgZGV2aWNlIGlzIGNvbmZpZ3VyZWQgdG8gYWRkIGEgMgpAQCAtNDk0LDYgKzQ5
NSw3IEBACiAJCWxwLT5jdXJyZW50X3J4X3NrYiA9IHNrYjsKIAkJU01DX1BVTExfREFUQShkYXRh
LCAocGt0X2xlbisyKzE1KSAmIH4xNSk7CiAJCS8qIFBhY2tldCBwcm9jZXNzaW5nIGRlZmVycmVk
IHRvIERNQSBSWCBpbnRlcnJ1cHQgKi8KKwkJcmV0dXJuIDA7CiAJCX0KICNlbHNlCiAJCVNNQ19T
RVRfUlhfQ0ZHKFJYX0NGR19SWF9FTkRfQUxHTjRfIHwgKCgyPDw4KSAmIFJYX0NGR19SWERPRkZf
KSk7CkBAIC01MDcsNiArNTA5LDcgQEAKIAkJbmV0aWZfcngoc2tiKTsKIAkJbHAtPnN0YXRzLnJ4
X3BhY2tldHMrKzsKIAkJbHAtPnN0YXRzLnJ4X2J5dGVzICs9IHBrdF9sZW4tNDsKKwkJcmV0dXJu
IDA7CiAjZW5kaWYKIAl9CiB9CkBAIC0xMzEyLDEwICsxMzE1LDI0IEBACiAJbHAtPnN0YXRzLnJ4
X2J5dGVzICs9IHNrYi0+bGVuOwogCiAJc3Bpbl9sb2NrX2lycXNhdmUoJmxwLT5sb2NrLCBmbGFn
cyk7CityZWFkX2ZpZm86CiAJcGt0cyA9IChTTUNfR0VUX1JYX0ZJRk9fSU5GKCkgJiBSWF9GSUZP
X0lORl9SWFNVU0VEXykgPj4gMTY7CiAJaWYgKHBrdHMgIT0gMCkgewotCQlzbWM5MTF4X3Jjdihk
ZXYpOworCQkvKiBDaGVjayBpZiBzbWM5MTF4X3JjdiBzY2hlZHVsZWQgRE1BIAorCQkgKiBJZiBu
b3Qgd2Ugc2hvdWxkIGFnYWluIGNoZWNrIHRoZSBmaWZvCisJCSAqIGZvciBuZXh0IHBhY2tldCBh
bmQgc3RhcnQgRE1BIG9uIGl0CisJCSAqLworCQlpZiAoc21jOTExeF9yY3YoZGV2KSA8IDApIAor
CQkJZ290byByZWFkX2ZpZm87CiAJfWVsc2UgeworCQlTTUNfR0VUX01BQ19DUihjcik7CisJCS8q
IENoZWNrIGlmIHRoZXJlIHdhcyBhIFJ4IE92ZXJydW4KKwkJICogVHVybiBvbiByZWNlaXZlciBh
bmQgZW5hYmxlIFJYICovCisJCWlmICh1bmxpa2VseSghKGNyICYgTUFDX0NSX1JYRU5fKSkpCisJ
CXsKKwkJICAgIERCRyhTTUNfREVCVUdfUlgsICIlczogRW5hYmxpbmcgUmVjZWl2ZXIgXG4iLCBk
ZXYtPm5hbWUpOworCQkgICAgU01DX1NFVF9NQUNfQ1IoIGNyIHwgTUFDX0NSX1JYRU5fICk7CisJ
CX0KIAkJbHAtPnJ4ZG1hX2FjdGl2ZSA9IDA7CiAJfQogCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUo
JmxwLT5sb2NrLCBmbGFncyk7Cg==

------_=_NextPart_001_01C882B7.7692734C--
