From: Louis JANG <louis@mizi.com>
Subject: Re: [Bluez-devel] forcing SCO connection patch
Date: Tue, 26 Feb 2008 12:53:36 +0900
Message-ID: <47C38D40.3040809@mizi.com>
References: <47666E1F.2000902@mizi.com>	 <a8e1da0802242330l765b8b1ava62b857baf8a5568@mail.gmail.com>	 <47C28A33.4070102@mizi.com> <a8e1da0802250155u1b7af481va203849f68d9106b@mail.gmail.com> <47C2A7FA.2060902@mizi.com> <70692DDF-93B7-447E-ABEE-3CDBD94F15F1@holtmann.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030006020202090909070106"
Cc: Dave Young <hidave.darkstar@gmail.com>,
	linux-bluetooth@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	bmidgley@gmail.com, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mizi.com ([61.107.31.33]:41303 "EHLO mail.mizi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009AbYBZDxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 22:53:49 -0500
In-Reply-To: <70692DDF-93B7-447E-ABEE-3CDBD94F15F1@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030006020202090909070106
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 7bit

Hi Marcel


>> --- linux-2.6.23/net/bluetooth/hci_event.c.orig 2008-02-25
>> 17:17:11.000000000 +0900
>> +++ linux-2.6.23/net/bluetooth/hci_event.c 2008-02-25
>> 17:30:23.000000000 +0900
>> @@ -1313,8 +1313,17 @@
>> hci_dev_lock(hdev);
>>
>> conn = hci_conn_hash_lookup_ba(hdev, ev->link_type, &ev->bdaddr);
>> - if (!conn)
>> - goto unlock;
>> + if (!conn) {
>> + if (ev->link_type != ACL_LINK) {
>> + __u8 link_type = (ev->link_type == ESCO_LINK) ? SCO_LINK : ESCO_LINK;
>> +
>> + conn = hci_conn_hash_lookup_ba(hdev, link_type, &ev->bdaddr);
>> + if (conn)
>> + conn->type = ev->link_type;
>> + }
>> + if (!conn)
>> + goto unlock;
>> + }
>
> NAK. There is no need to check for ACL_LINK. The sync_complete will
> only be called for SCO or eSCO connections.
I see. I removed this check line in the patch.

Thanks.
Louis JANG

--------------030006020202090909070106
Content-Type: text/plain;
 name="patch_hci_event.c4"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="patch_hci_event.c4"

U2lnbmVkLW9mZi1ieTogTG91aXMgSkFORyA8bG91aXNAbWl6aS5jb20+Ci0tLSBsaW51eC0y
LjYuMjMvbmV0L2JsdWV0b290aC9oY2lfZXZlbnQuYy5vcmlnCTIwMDgtMDItMjYgMTI6NDY6
MzYuMDAwMDAwMDAwICswOTAwCisrKyBsaW51eC0yLjYuMjMvbmV0L2JsdWV0b290aC9oY2lf
ZXZlbnQuYwkyMDA4LTAyLTI2IDEyOjQ3OjIzLjAwMDAwMDAwMCArMDkwMApAQCAtMTMxMyw4
ICsxMzEzLDE1IEBACiAJaGNpX2Rldl9sb2NrKGhkZXYpOwogCiAJY29ubiA9IGhjaV9jb25u
X2hhc2hfbG9va3VwX2JhKGhkZXYsIGV2LT5saW5rX3R5cGUsICZldi0+YmRhZGRyKTsKLQlp
ZiAoIWNvbm4pCi0JCWdvdG8gdW5sb2NrOworCWlmICghY29ubikgeworCQlfX3U4IGxpbmtf
dHlwZSA9IChldi0+bGlua190eXBlID09IEVTQ09fTElOSykgPyBTQ09fTElOSyA6IEVTQ09f
TElOSzsKKworCQljb25uID0gaGNpX2Nvbm5faGFzaF9sb29rdXBfYmEoaGRldiwgbGlua190
eXBlLCAmZXYtPmJkYWRkcik7CisJCWlmIChjb25uKQorCQkJY29ubi0+dHlwZSA9IGV2LT5s
aW5rX3R5cGU7CisJCWVsc2UKKwkJCWdvdG8gdW5sb2NrOworCX0KIAogCWlmICghZXYtPnN0
YXR1cykgewogCQljb25uLT5oYW5kbGUgPSBfX2xlMTZfdG9fY3B1KGV2LT5oYW5kbGUpOwo=
--------------030006020202090909070106--
