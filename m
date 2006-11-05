From: "Boris Sukholitko" <bobatonhu@gmail.com>
Subject: [RFC, PATCH] Purging local routes on NETDEV_DOWN event
Date: Sun, 5 Nov 2006 16:00:20 +0200
Message-ID: <589170c50611050600r3d4bfaafvb2acd513ae695a96@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_36453_20353469.1162735220015"
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:39228 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932689AbWKEOAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 09:00:22 -0500
Received: by nf-out-0910.google.com with SMTP id c2so384506nfe
        for <netdev@vger.kernel.org>; Sun, 05 Nov 2006 06:00:20 -0800 (PST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_36453_20353469.1162735220015
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

We've noticed that when taking network interface down the local route
for its address is preserved. The following console session
illustrates it:

# ip addr add 5.5.5.5 dev eth4
# ip route list table all | grep eth4
local 5.5.5.5 dev eth4  table 255  vrf 0  proto kernel  scope host  src 5.5.5.5
# ip link set eth4 down
local 5.5.5.5 dev eth4  table 255  vrf 0  proto kernel  scope host  src 5.5.5.5

There seems to be an asymmetry between NETDEV_UP and NETDEV_DOWN events
in fib_netdev_event at net/ipv4/fib_frontend.c. On NETDEV_UP we are adding
routes for interface addresses. However on NETDEV_DOWN we do not delete them.

The attached (for a fear of GMail tab munging :)) patch tries to change it.

What do you think?

Thanks,
Boris.

------=_Part_36453_20353469.1162735220015
Content-Type: text/x-patch; name=netdev-down.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_eu5igqku
Content-Disposition: attachment; filename="netdev-down.patch"

U2lnbmVkLW9mZi1ieTogQm9yaXMgU3VraG9saXRrbyAoYm9iYXRvbmh1QGdtYWlsLmNvbSkKLS0t
CkluZGV4OiBsaW51eC0yLjYuMTgvbmV0L2lwdjQvZmliX2Zyb250ZW5kLmMKPT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQot
LS0gbGludXgtMi42LjE4Lm9yaWcvbmV0L2lwdjQvZmliX2Zyb250ZW5kLmMJMjAwNi0xMS0wMSAx
ODoxNTozMS4wMDAwMDAwMDAgKzAyMDAKKysrIGxpbnV4LTIuNi4xOC9uZXQvaXB2NC9maWJfZnJv
bnRlbmQuYwkyMDA2LTExLTA1IDE1OjMyOjU2LjAwMDAwMDAwMCArMDIwMApAQCAtNzI3LDYgKzcy
Nyw4IEBACiAJICovCiAKIAlmb3IgKGlmYTEgPSBpbl9kZXYtPmlmYV9saXN0OyBpZmExOyBpZmEx
ID0gaWZhMS0+aWZhX25leHQpIHsKKwkJaWYgKGlmYSA9PSBpZmExKQorCQkJY29udGludWU7CiAJ
CWlmIChpZmEtPmlmYV9sb2NhbCA9PSBpZmExLT5pZmFfbG9jYWwpCiAJCQlvayB8PSBMT0NBTF9P
SzsKIAkJaWYgKGlmYS0+aWZhX2Jyb2FkY2FzdCA9PSBpZmExLT5pZmFfYnJvYWRjYXN0KQpAQCAt
ODgwLDYgKzg4Miw5IEBACiAJCXJ0X2NhY2hlX2ZsdXNoKC0xKTsKIAkJYnJlYWs7CiAJY2FzZSBO
RVRERVZfRE9XTjoKKwkJZm9yX2lmYShpbl9kZXYpIHsKKwkJCWZpYl9kZWxfaWZhZGRyKGlmYSk7
CisJCX0gZW5kZm9yX2lmYShpbl9kZXYpOwogCQlmaWJfZGlzYWJsZV9pcChkZXYsIDApOwogCQli
cmVhazsKIAljYXNlIE5FVERFVl9DSEFOR0VNVFU6Cg==
------=_Part_36453_20353469.1162735220015--
