From: Tom Gundersen <teg@jklm.no>
Subject: [BUG?] the first bind() of an AF_PACKET socket to an interface is slow
Date: Mon, 31 Mar 2014 20:43:04 +0200
Message-ID: <CAG-2HqXW+ULp_K-873+DG3T_4FxcxaSy5aGQ+wf6P9m=015zgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf3010e5b134a25f04f5eb6dd4
Cc: Kay Sievers <kay@vrfy.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:58537 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204AbaCaSnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 14:43:25 -0400
Received: by mail-yk0-f169.google.com with SMTP id 142so6607322ykq.0
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 11:43:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf3010e5b134a25f04f5eb6dd4
Content-Type: text/plain; charset=UTF-8

Hi,

I'm observing some strange behavior using bind().

For any given process, and any given interface, the first time I bind
a socket to the interface it takes a very long time. Subsequent binds
to the same interface in the same process are instantaneous.

The time it takes seems independent of the interface, so also affects
the loopback interface, but binding to all interfaces (ifindex=0) is
instantaneous.

It is also peculiar to note that the time it takes to bind is
seemingly randomly chosen on my machine from 9ms, 19ms, 29ms, 39ms,
49ms and 59 ms, but I never observed any other values.

The attached test program illustrates the problem, binding to
ifindex=0 (all) and ifindex=1 (loopback).

Sample run:
# strace -f -T -ebind ./bind
bind(3, {sa_family=AF_PACKET, proto=0x800, if0, pkttype=0x40 /* ? */,
addr(6)={1328, ffffffffffff}, 20) = 0 <0.000036>
bind(3, {sa_family=AF_PACKET, proto=0x800, if0, pkttype=0x40 /* ? */,
addr(6)={1328, ffffffffffff}, 20) = 0 <0.000033>
bind(3, {sa_family=AF_PACKET, proto=0x800, if1, pkttype=0x40 /* ? */,
addr(6)={1328, ffffffffffff}, 20) = 0 <0.059706>
bind(3, {sa_family=AF_PACKET, proto=0x800, if1, pkttype=0x40 /* ? */,
addr(6)={1328, ffffffffffff}, 20) = 0 <0.000111>


Can anyone enlighten me to what is going on? Is this expected behavior
or a bug? Any suggestions for a work-around?

Cheers,

Tom

--20cf3010e5b134a25f04f5eb6dd4
Content-Type: text/x-csrc; charset=US-ASCII; name="bind.c"
Content-Disposition: attachment; filename="bind.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_htg3t1690

I2luY2x1ZGUgPGVycm5vLmg+CiNpbmNsdWRlIDxzeXMvdHlwZXMuaD4KI2luY2x1ZGUgPHN5cy9z
b2NrZXQuaD4KI2luY2x1ZGUgPHN0cmluZy5oPgojaW5jbHVkZSA8bGludXgvaWZfcGFja2V0Lmg+
CiNpbmNsdWRlIDxuZXQvZXRoZXJuZXQuaD4KI2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDx1
bmlzdGQuaD4KI2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4KI2luY2x1ZGUgPHN5cy91bi5oPgojaW5j
bHVkZSA8YXJwYS9pbmV0Lmg+CgppbnQgbWFpbigpIHsKICAgICAgICBzdHJ1Y3Qgc29ja2FkZHJf
bGwgbGw7CiAgICAgICAgaW50IHM7CglpbnQgaTsKCglmb3IgKGkgPSAwOyBpIDwgMjsgaSsrKSB7
CgkJcyA9IHNvY2tldChBRl9QQUNLRVQsIFNPQ0tfREdSQU0sIGh0b25zKEVUSF9QX0lQKSk7CgoJ
ICAgICAgICBsbC5zbGxfZmFtaWx5ID0gQUZfUEFDS0VUOwoJICAgICAgICBsbC5zbGxfcHJvdG9j
b2wgPSBodG9ucyhFVEhfUF9JUCk7CgkgICAgICAgIGxsLnNsbF9pZmluZGV4ID0gaTsKCgkgICAg
ICAgIGJpbmQocywgKGNvbnN0IHN0cnVjdCBzb2NrYWRkciAqKSZsbCwgc2l6ZW9mKGxsKSk7Cgkg
ICAgICAgIGJpbmQocywgKGNvbnN0IHN0cnVjdCBzb2NrYWRkciAqKSZsbCwgc2l6ZW9mKGxsKSk7
CgkJY2xvc2Uocyk7Cgl9CgogICAgICAgIHJldHVybiAwOwp9Cg==
--20cf3010e5b134a25f04f5eb6dd4--
