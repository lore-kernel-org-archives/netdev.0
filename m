From: Mikhail Zolotaryov <lebon@lebon.org.ua>
Subject: [PATCH] powerpc 4xx EMAC driver: device name reported on timeout
 is not correct
Date: Fri, 20 Mar 2009 10:28:02 +0200
Message-ID: <49C35392.7030906@lebon.org.ua>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010805060807060707040208"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from b-mail.com.ua ([195.68.202.242]:62166 "EHLO b-mail.com.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752188AbZCTIpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 04:45:32 -0400
Received: from CUSTOMER.local
	by b-mail.com.ua with ESMTP (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	id 1Lka93-00080a-9i
	for netdev@vger.kernel.org; Fri, 20 Mar 2009 10:32:01 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010805060807060707040208
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

IBM EMAC driver performs device reset (drivers/net/ibm_newemac/core.c:
emac_probe() -> emac_init_phy() -> emac_reset()) before registering
appropriate net_device (emac_probe() -> register_netdev()), so
net_device name contains raw format string during EMAC reset ("eth%d").

If the case of reset timeout, emac_report_timeout_error() function is
called to report an error. The problem is this function uses net_device
name to report device related, which is not correct, as a result in the
kernel log buffer we see:

eth%d: reset timeout

The solution is to print device_node full_name instead. After applying
the patch proposed, error string is like the following:

/plb/opb/ethernet@ef600e00: reset timeout

Signed-off-by: Mikhail Zolotaryov <lebon@lebon.org.ua>
Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>




--------------010805060807060707040208
Content-Type: text/plain;
 name="emac_report_timeout_error.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="emac_report_timeout_error.patch"

LS0tIGxpbnV4LTIuNi9kcml2ZXJzL25ldC9pYm1fbmV3ZW1hYy9jb3JlLmMub3JpZwkyMDA5
LTAzLTEwIDIwOjI0OjEyLjAwMDAwMDAwMCArMDIwMAorKysgbGludXgtMi42L2RyaXZlcnMv
bmV0L2libV9uZXdlbWFjL2NvcmUuYwkJMjAwOS0wMy0xMCAyMDoyOToxMi4wMDAwMDAwMDAg
KzAyMDAKQEAgLTEzNCw3ICsxMzQsNyBAQAogCQkJCSAgRU1BQ19GVFJfNDQwRVBfUEhZX0NM
S19GSVgpKQogCQlEQkcoZGV2LCAiJXMiIE5MLCBlcnJvcik7CiAJZWxzZSBpZiAobmV0X3Jh
dGVsaW1pdCgpKQotCQlwcmludGsoS0VSTl9FUlIgIiVzOiAlc1xuIiwgZGV2LT5uZGV2LT5u
YW1lLCBlcnJvcik7CisJCXByaW50ayhLRVJOX0VSUiAiJXM6ICVzXG4iLCBkZXYtPm9mZGV2
LT5ub2RlLT5mdWxsX25hbWUsIGVycm9yKTsKIH0KIAogLyogRU1BQyBQSFkgY2xvY2sgd29y
a2Fyb3VuZDoK
--------------010805060807060707040208--
