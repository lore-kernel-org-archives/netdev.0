From: Quentin RAMEAU <quentin.rameau@gmail.com>
Subject: [iputils][ping] ip address resolution bug
Date: Mon, 10 Jun 2013 00:52:45 +0200
Message-ID: <CAKO=Kk5SA=KbWnnfzuzLY5pW9UX16zPuV_+Sv1P7LE7nezQzEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf307ca0022d18bf04dec08823
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f173.google.com ([209.85.220.173]:56319 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311Ab3FIWx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jun 2013 18:53:27 -0400
Received: by mail-vc0-f173.google.com with SMTP id ht10so496665vcb.18
        for <netdev@vger.kernel.org>; Sun, 09 Jun 2013 15:53:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf307ca0022d18bf04dec08823
Content-Type: text/plain; charset=UTF-8

Ping does not ensure it is resolving a hostname to an IPv4 address.
i.e. when setting 'options inet6' in resolv.conf, gethostbyname(3)
returns an IPv6 address, but ping handles it as in IPv4 address.
I attached a simple patch which replaces gethostbyname() with
gethostbyname2(), I'm not sure that is the best way to do it, feel
free to comment.

Quentin Rameau

--20cf307ca0022d18bf04dec08823
Content-Type: application/octet-stream; name="ping-address-resolution.diff"
Content-Disposition: attachment; filename="ping-address-resolution.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hhqttfo40

ZGlmZiAtLWdpdCBhL3BpbmcuYyBiL3BpbmcuYwppbmRleCBjMDM2NmNkLi40OTg5NzYwIDEwMDY0
NAotLS0gYS9waW5nLmMKKysrIGIvcGluZy5jCkBAIC0yNzksNyArMjc5LDcgQEAgbWFpbihpbnQg
YXJnYywgY2hhciAqKmFyZ3YpCiAjZWxzZQogCQkJaWRuID0gdGFyZ2V0OwogI2VuZGlmCi0JCQlo
cCA9IGdldGhvc3RieW5hbWUoaWRuKTsKKwkJCWhwID0gZ2V0aG9zdGJ5bmFtZTIoaWRuLCBBRl9J
TkVUKTsKIAkJCWlmICghaHApIHsKIAkJCQlmcHJpbnRmKHN0ZGVyciwgInBpbmc6IHVua25vd24g
aG9zdCAlc1xuIiwgdGFyZ2V0KTsKIAkJCQlleGl0KDIpOwo=
--20cf307ca0022d18bf04dec08823--
