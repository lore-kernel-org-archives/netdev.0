From: mpb <mpb.mail@gmail.com>
Subject: Fwd: Cross thread shutdown of connected UDP socket, unexpected
 recvfrom behavior
Date: Wed, 13 Nov 2013 12:07:20 -0800
Message-ID: <CAApbN=K8j+XQG+pQF2fxBSrDEPcjD242e9uP72azD9XWBzHcGQ@mail.gmail.com>
References: <CAApbN=Jm=zuDaVYALmGg5z_QfJJ3q13e9tshb7OpAtPQ8Ema1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b5d41a645f75504eb148309
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:43103 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756278Ab3KMUHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 15:07:21 -0500
Received: by mail-ob0-f179.google.com with SMTP id wn1so1055726obc.10
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 12:07:21 -0800 (PST)
In-Reply-To: <CAApbN=Jm=zuDaVYALmGg5z_QfJJ3q13e9tshb7OpAtPQ8Ema1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b5d41a645f75504eb148309
Content-Type: text/plain; charset=ISO-8859-1

Hi netdev@vger.kernel.org,

Someone on LKML suggested that I forward this issue to the netdev list.

In a nutshell, recvfrom returns ambiguous results, and it is
impossible to distinguish between these two situations:

a) calling recvfrom and receiving a zero length UDP message
b) calling recvfrom and blocking until the socket is shutdown (locally)

More details below.

Thanks!

-mpb


---------- Forwarded message ----------
From: mpb <mpb.mail@gmail.com>
Date: Sat, Nov 9, 2013 at 5:32 PM
Subject: Cross thread shutdown of connected UDP socket, unexpected
recvfrom behavior
To: linux-kernel@vger.kernel.org


Hi LKML,

I have a C/pthreads program with two threads ("main" and "thread").
"thread" calls recvfrom on a connected UDP socket and blocks, waiting
for input.  "main" then calls shutdown SHUT_RD on the socket.  In
"thread", recvfrom returns, apparently successfully, returning a zero
length string, and setting src_addr to a bogus(?) address family,
port, and source address.

Is the above the correct behavior for recvfrom?

Here is output from my program.  "main" sends "hello\0", then "" (the
empty string), then calls shutdown.  "thread" receives "hello\0", "",
and then finally receives an empty string that was never sent!

thread  recvfrom: Success
  rv 6  addrlen 16  fam 2  port 8000  addr 100007f

thread  recvfrom: Success
  rv 0  addrlen 16  fam 2  port 8000  addr 100007f

main    shutdown: Success
  rv 0

thread  recvfrom: Success
  rv 0  addrlen 16  fam 59060  port 44237  addr deaadef0

The source code (2k) for the porgram is attached.  I'm running Ubuntu
13.04, kernel 3.8.0-19-generic #30-Ubuntu, on 32-bit i686.

For reference, this June 2000 LKML thread discusses calling close in a
similar situation.
http://www.gossamer-threads.com/lists/linux/kernel/144379

Please CC me if you have questions, otherwise I'll try to watch for
answers in the list archives.

Thanks!

-mpb

--047d7b5d41a645f75504eb148309
Content-Type: text/x-csrc; charset=US-ASCII; name="test.c"
Content-Disposition: attachment; filename="test.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hntl84y30

CgojaW5jbHVkZSA8bmV0aW5ldC9pbi5oPgojaW5jbHVkZSA8cHRocmVhZC5oPgojaW5jbHVkZSA8
c3RkaW8uaD4KI2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4KI2luY2x1ZGUgPHN5cy90eXBlcy5oPgoK
CnN0cnVjdCBzb2NrYWRkcl9pbiAgYWRkcl8wLCBhZGRyXzEsIGFkZHJfMiA7CmludCAgICAgICAg
ICAgICAgICAgZmQwLCBmZDEsIHJ2MCwgcnYxLCBhZGRybGVuOwpjaGFyICAgICAgICAgICAgICAg
IGJ1Zl8wWzEwMjRdLCBidWZfMVsxMDI0XTsKcHRocmVhZF90ICAgICAgICAgICB0aHJlYWQ7CnZv
aWQqICAgICAgICAgICAgICAgdGhyZWFkX3J2OwoKCnZvaWQqIHRocmVhZF9tYWluICh2b2lkKiBh
cmcpIHsKCiAgaW50IGk7ICBmb3IgKCBpPTA7ICBpPDM7ICBpKysgKSB7CgogICAgYWRkcl8yLnNp
bl9mYW1pbHkgICAgICAgPSAgMDsKICAgIGFkZHJfMi5zaW5fcG9ydCAgICAgICAgID0gIDA7CiAg
ICBhZGRyXzIuc2luX2FkZHIuc19hZGRyICA9ICAwOwoKICAgIGFkZHJsZW4gPSBzaXplb2YgYWRk
cl8yOwogICAgcnYxID0gcmVjdmZyb20gKCBmZDEsIGJ1Zl8wLCBzaXplb2YgYnVmXzAsIDAsCgkJ
ICAgICAoc3RydWN0IHNvY2thZGRyKikgJmFkZHJfMiwgJmFkZHJsZW4gKTsKCiAgICBpbnQgZmFt
ICAgPSAgYWRkcl8yLnNpbl9mYW1pbHk7CiAgICBpbnQgcG9ydCAgPSAgYWRkcl8yLnNpbl9wb3J0
OwogICAgaW50IGFkZHIgID0gIGFkZHJfMi5zaW5fYWRkci5zX2FkZHI7CgogICAgcHJpbnRmICgi
XG4iKTsKICAgIHBlcnJvciAoInRocmVhZCAgcmVjdmZyb20iKTsKICAgIHByaW50ZiAoICIgIHJ2
ICVkICBhZGRybGVuICVkICBmYW0gJWQgIHBvcnQgJWQgIGFkZHIgJXhcbiIsCgkgICAgIHJ2MSwg
YWRkcmxlbiwgZmFtLCBudG9ocyAocG9ydCksIGFkZHIgKTsKICAgIDs7OyB9CgogIHJldHVybiBO
VUxMOyB9CgoKdm9pZCBtYWluX21haW4gKCkgewoKICBzZW5kICggZmQwLCAiaGVsbG8iLCA2LCAw
KTsKICBzZW5kICggZmQwLCAiIiwgICAgICAwLCAwKTsKICB1c2xlZXAgKDEwMDAwMCk7CgogIHJ2
MCA9IHNodXRkb3duICggZmQxLCBTSFVUX1JEICk7CiAgcHJpbnRmICgiXG4iKTsKICBwZXJyb3Ig
KCJtYWluICAgIHNodXRkb3duIik7CiAgcHJpbnRmICgiICAlZFxuIiwgcnYwKQoKICA7OzsgfQoK
CmludCBtYWluICgpIHsKCiAgYWRkcl8wLnNpbl9mYW1pbHkgPSBBRl9JTkVUOwogIGFkZHJfMC5z
aW5fcG9ydCA9IGh0b25zICg4MDAwKTsKICBpbmV0X3B0b24gKCBBRl9JTkVULCAiMTI3LjAuMC4x
IiwgJmFkZHJfMC5zaW5fYWRkciApOwoKICBhZGRyXzEuc2luX2ZhbWlseSA9IEFGX0lORVQ7CiAg
YWRkcl8xLnNpbl9wb3J0ID0gaHRvbnMgKDgwMDEpOwogIGluZXRfcHRvbiAoIEFGX0lORVQsICIx
MjcuMC4wLjEiLCAmYWRkcl8xLnNpbl9hZGRyICk7CgogIGZkMCA9IHNvY2tldCAoIEFGX0lORVQs
IFNPQ0tfREdSQU0sIDAgKTsKICBiaW5kICAgICggZmQwLCAoc3RydWN0IHNvY2thZGRyKikgJmFk
ZHJfMCwgc2l6ZW9mIGFkZHJfMCApOwogIGNvbm5lY3QgKCBmZDAsIChzdHJ1Y3Qgc29ja2FkZHIq
KSAmYWRkcl8xLCBzaXplb2YgYWRkcl8xICk7CgogIGZkMSA9IHNvY2tldCAoIEFGX0lORVQsIFNP
Q0tfREdSQU0sIDAgKTsKICBiaW5kICAgICggZmQxLCAoc3RydWN0IHNvY2thZGRyKikgJmFkZHJf
MSwgc2l6ZW9mIGFkZHJfMSApOwogIGNvbm5lY3QgKCBmZDEsIChzdHJ1Y3Qgc29ja2FkZHIqKSAm
YWRkcl8wLCBzaXplb2YgYWRkcl8wICk7CgogIHB0aHJlYWRfY3JlYXRlICggJnRocmVhZCwgTlVM
TCwgdGhyZWFkX21haW4sIE5VTEwgKTsKICBtYWluX21haW4gKCk7CiAgcHRocmVhZF9qb2luICgg
dGhyZWFkLCAmdGhyZWFkX3J2ICk7CgogIHJldHVybiAwOyB9Cg==
--047d7b5d41a645f75504eb148309--
