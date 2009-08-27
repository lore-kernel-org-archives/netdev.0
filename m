From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: regression: Apparently missing err assignment in ipv6 bind
Date: Thu, 27 Aug 2009 08:16:40 -0700
Message-ID: <6897af6d0908270816w5ee81dd5j98bd11fe1d49479d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=000e0cd5c9eaee8e740472210da8
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:53668 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbZH0PQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 11:16:41 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id n7RFGgbo024416
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2009 16:16:42 +0100
Received: from ywh30 (ywh30.prod.google.com [10.192.8.30])
	by wpaz29.hot.corp.google.com with ESMTP id n7RFFZvF028146
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2009 08:16:40 -0700
Received: by ywh30 with SMTP id 30so1359457ywh.25
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2009 08:16:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--000e0cd5c9eaee8e740472210da8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

AFAICT, 2.6.30.5 and 2.6.31-rc7 both include a change in net/ipv6/af_inet6.c

http://lxr.linux.no/linux+v2.6.30.5/net/ipv6/af_inet6.c#L298

which results in a possible error return path with no err assignment.
I believe the error should be EADDRNOTAVAIL.

-- Maciej

--000e0cd5c9eaee8e740472210da8
Content-Type: text/x-patch; charset=US-ASCII; name="bindv6err-2.6.30.5.patch"
Content-Disposition: attachment; filename="bindv6err-2.6.30.5.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fyvmxvhl0

LS0tIGxpbnV4LTIuNi4zMC41L25ldC9pcHY2L2FmX2luZXQ2LmNfCTIwMDktMDYtMDkgMjA6MDU6
MjcuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMzAuNS9uZXQvaXB2Ni9hZl9pbmV0Ni5j
CTIwMDktMDgtMjcgMDg6MDU6MzcuMDAwMDAwMDAwIC0wNzAwCkBAIC0yOTQsOCArMjk0LDEwIEBA
CiAJCSAgICB2NGFkZHIgIT0gaHRvbmwoSU5BRERSX0FOWSkgJiYKIAkJICAgIGNoa19hZGRyX3Jl
dCAhPSBSVE5fTE9DQUwgJiYKIAkJICAgIGNoa19hZGRyX3JldCAhPSBSVE5fTVVMVElDQVNUICYm
Ci0JCSAgICBjaGtfYWRkcl9yZXQgIT0gUlROX0JST0FEQ0FTVCkKKwkJICAgIGNoa19hZGRyX3Jl
dCAhPSBSVE5fQlJPQURDQVNUKSB7CisJCQllcnIgPSAtRUFERFJOT1RBVkFJTDsKIAkJCWdvdG8g
b3V0OworCQl9CiAJfSBlbHNlIHsKIAkJaWYgKGFkZHJfdHlwZSAhPSBJUFY2X0FERFJfQU5ZKSB7
CiAJCQlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2ID0gTlVMTDsK
--000e0cd5c9eaee8e740472210da8
Content-Type: text/x-patch; charset=US-ASCII; name="bindv6err-2.6.31-rc7.patch"
Content-Disposition: attachment; filename="bindv6err-2.6.31-rc7.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fyvmy65t1

LS0tIGxpbnV4LTIuNi4zMS1yYzcvbmV0L2lwdjYvYWZfaW5ldDYuY18JMjAwOS0wOC0yNyAwODow
MjoyMi4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4zMS1yYzcvbmV0L2lwdjYvYWZfaW5l
dDYuYwkyMDA5LTA4LTI3IDA4OjA3OjE2LjAwMDAwMDAwMCAtMDcwMApAQCAtMzA2LDggKzMwNiwx
MCBAQAogCQkgICAgdjRhZGRyICE9IGh0b25sKElOQUREUl9BTlkpICYmCiAJCSAgICBjaGtfYWRk
cl9yZXQgIT0gUlROX0xPQ0FMICYmCiAJCSAgICBjaGtfYWRkcl9yZXQgIT0gUlROX01VTFRJQ0FT
VCAmJgotCQkgICAgY2hrX2FkZHJfcmV0ICE9IFJUTl9CUk9BRENBU1QpCisJCSAgICBjaGtfYWRk
cl9yZXQgIT0gUlROX0JST0FEQ0FTVCkgeworCQkJZXJyID0gLUVBRERSTk9UQVZBSUw7CiAJCQln
b3RvIG91dDsKKwkJfQogCX0gZWxzZSB7CiAJCWlmIChhZGRyX3R5cGUgIT0gSVBWNl9BRERSX0FO
WSkgewogCQkJc3RydWN0IG5ldF9kZXZpY2UgKmRldiA9IE5VTEw7Cg==
--000e0cd5c9eaee8e740472210da8--
