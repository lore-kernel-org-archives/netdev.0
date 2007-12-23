From: "David Shwatrz" <dshwatrz@gmail.com>
Subject: [PATCH net-2.6] [NEIGH] [resend] Updating affected neighbours when about MAC address change in arp_netdev_event()
Date: Sun, 23 Dec 2007 15:51:57 +0200
Message-ID: <31436f4a0712230551g4b394e13k87a9320fad4ae9b0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5269_17581614.1198417917482"
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:42428 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbXLWNv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 08:51:57 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1966729wah.23
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2007 05:51:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_5269_17581614.1198417917482
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

This is a resend of the patch according to Yoshifuji comment. I will
send a patch for IPv6 later.

 We know that changes in MAC addresses are not frequent but
we are working on a special, highly advanced networking Linux based project
in our LABs, where we do change MAC addresses of an interface quite frequently.
(We do not go totally wild; the MAC addresses we are changing into are
from a set of given MAC addresses).

Normally, when we change a MAC address of some interface, the
relevant neighbours in the LAN which have entries with the previous MAC
address are not sent any update notification; instead, it is there
regular timers mechanisms which update the MAC address to the new
one in their ARP tables.

I had written a small patch to neigh_changeaddr() in net/ipv4/arp.c
against the 2.6 git net tree, which sends a gratuitous ARP to update
the list of
all the involved neighbours with the change of MAC address.
The patch is for arp_netdev_event() only.

This patch was tested and it does work in my LAB; if such a patch is
not needed,
I wonder why ?
It seems to me that it could not cause any troubles.
BTW, I had noticed that in irlan driver, there is such a mechanism
of sending a gratuitous ARP to update all the
neighbours when a MAC address is changed.

Signed-off-by: David Shwartz <dshwatrz@gmail.com>

------=_Part_5269_17581614.1198417917482
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fajn1iv40
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L2FycC5jIGIvbmV0L2lwdjQvYXJwLmMKaW5kZXggMDgxNzRh
Mi4uN2IxMTYyYiAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvYXJwLmMKKysrIGIvbmV0L2lwdjQvYXJw
LmMKQEAgLTExODUsNiArMTE4NSw4IEBAIG91dDoKIAogc3RhdGljIGludCBhcnBfbmV0ZGV2X2V2
ZW50KHN0cnVjdCBub3RpZmllcl9ibG9jayAqdGhpcywgdW5zaWduZWQgbG9uZyBldmVudCwgdm9p
ZCAqcHRyKQogeworCXN0cnVjdCBpbl9kZXZpY2UgKmluX2RldjsKKwlzdHJ1Y3QgaW5faWZhZGRy
ICppZmE7CiAJc3RydWN0IG5ldF9kZXZpY2UgKmRldiA9IHB0cjsKIAogCWlmIChkZXYtPm5kX25l
dCAhPSAmaW5pdF9uZXQpCkBAIC0xMTk0LDYgKzExOTYsMjIgQEAgc3RhdGljIGludCBhcnBfbmV0
ZGV2X2V2ZW50KHN0cnVjdCBub3RpZmllcl9ibG9jayAqdGhpcywgdW5zaWduZWQgbG9uZyBldmVu
dCwgdm8KIAljYXNlIE5FVERFVl9DSEFOR0VBRERSOgogCQluZWlnaF9jaGFuZ2VhZGRyKCZhcnBf
dGJsLCBkZXYpOwogCQlydF9jYWNoZV9mbHVzaCgwKTsKKwkJCisJCS8qIFNlbmQgZ3JhdHVpdG91
cyBBUlAgdG8gdGhlIG5laWdoYm91cnMgdG8gdXBkYXRlIHRoZWlyIGFycCB0YWJsZXMgKi8KKwkK
KwkJcmN1X3JlYWRfbG9jaygpOworCQlpbl9kZXYgPSBfX2luX2Rldl9nZXRfcmN1KGRldik7CisJ
CWlmIChpbl9kZXYgPT0gTlVMTCkKKwkJCWdvdG8gb3V0OworCQlmb3IgKGlmYSA9IGluX2Rldi0+
aWZhX2xpc3Q7IGlmYTsgaWZhID0gaWZhLT5pZmFfbmV4dCkKKwkJCWFycF9zZW5kKEFSUE9QX1JF
UVVFU1QsIEVUSF9QX0FSUCwgCisJCQkJaWZhLT5pZmFfYWRkcmVzcywKKwkJCQlkZXYsIAorCQkJ
CWlmYS0+aWZhX2FkZHJlc3MsCisJCQkJTlVMTCwgZGV2LT5kZXZfYWRkciwgTlVMTCk7CitvdXQ6
CisJcmN1X3JlYWRfdW5sb2NrKCk7CisKIAkJYnJlYWs7CiAJZGVmYXVsdDoKIAkJYnJlYWs7Cg==

------=_Part_5269_17581614.1198417917482--
