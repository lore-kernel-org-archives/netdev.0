From: "Lucas C. Villa Real" <lucasvr@gobolinux.org>
Subject: [PATCH] iputils signal mask issue
Date: Fri, 5 Nov 2010 17:56:24 -0200
Message-ID: <AANLkTikuA-H23FH7-WzAu1nsVXb2SxR+tbQ8d8BNdoW+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001517511d3a59c763049453abe8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:39421 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327Ab0KET4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 15:56:25 -0400
Received: by qyk10 with SMTP id 10so2992824qyk.19
        for <netdev@vger.kernel.org>; Fri, 05 Nov 2010 12:56:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001517511d3a59c763049453abe8
Content-Type: text/plain; charset=ISO-8859-1

Hi,

Today we found an issue where arping would get stuck in an endless
loop. The problem was found to be related to the parent process (a
shell script) having had SIGALRM blocked, which is used by arping to
update "count" and to check the "timeout" global.

Since we cannot make assumptions on the signal masks of the
environment it's better to explicitly unblock the signals that the
utility needs before the main loop executes. It's worth noting that
although sigaction() is called to associate a handler to a given
signal, that function doesn't automatically unblock that signal.

A similar problem was noticed on rdisc, so the attached patch also
ensures to unblock the signals that it relies on.

Thanks,
Lucas

--001517511d3a59c763049453abe8
Content-Type: application/octet-stream; name="02-iputils-SIG_UNBLOCK.patch"
Content-Disposition: attachment; filename="02-iputils-SIG_UNBLOCK.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gg5hdw6m0

RG9uJ3QgcmVseSBvbiB0aGUgcGFyZW50IHNpZ25hbCBtYXNrLiBJZiB0aGF0IHByb2Nlc3MgaGFz
IGJsb2NrZWQgU0lHQUxSTSAKdGhlbiBjaGFuY2VzIGFyZSBoaWdoIHRoYXQgYXJwaW5nIGFuZCBy
ZGlzYyB3aWxsIGV4ZWN1dGUgZm9yZXZlciwgYXMgdGhhdApzaWduYWwgd2lsbCBuZXZlciBiZSBk
ZWxpdmVyZWQgYW5kIHRoZSBnbG9iYWxzLCBzdWNoIGFzICdjb3VudCcgYW5kICd0aW1lb3V0JywK
d29uJ3QgYmUgdXBkYXRlZCBvciBjaGVja2VkLgoKU2lnbmVkLW9mZi1ieTogTHVjYXMgQy4gVmls
bGEgUmVhbCA8bHVjYXN2ckB1cy5pYm0uY29tPgoKZGlmZiAtdXJwIGlwdXRpbHMtczIwMTAxMDA2
Lm9yaWcvYXJwaW5nLmMgaXB1dGlscy1zMjAxMDEwMDYvYXJwaW5nLmMKLS0tIGlwdXRpbHMtczIw
MTAxMDA2Lm9yaWcvYXJwaW5nLmMJMjAxMC0xMC0wNiAwODo1OToyMC4wMDAwMDAwMDAgLTAzMDAK
KysrIGlwdXRpbHMtczIwMTAxMDA2L2FycGluZy5jCTIwMTAtMTEtMDUgMTY6MTI6NDIuMDAwMDAw
MDAwIC0wMjAwCkBAIC0zNDYsNiArMzQ2LDcgQEAgbWFpbihpbnQgYXJnYywgY2hhciAqKmFyZ3Yp
CiB7CiAJaW50IHNvY2tldF9lcnJubzsKIAlpbnQgY2g7CisJc2lnc2V0X3Qgc3NldCwgb3NzZXQ7
CiAJdWlkX3QgdWlkID0gZ2V0dWlkKCk7CiAKIAlzID0gc29ja2V0KFBGX1BBQ0tFVCwgU09DS19E
R1JBTSwgMCk7CkBAIC01NDQsMTMgKzU0NSwxNyBAQCBtYWluKGludCBhcmdjLCBjaGFyICoqYXJn
dikKIAkJZXhpdCgyKTsKIAl9CiAKKwlzaWdlbXB0eXNldCgmc3NldCk7CisJc2lnYWRkc2V0KCZz
c2V0LCBTSUdBTFJNKTsKKwlzaWdhZGRzZXQoJnNzZXQsIFNJR0lOVCk7CisJc2lncHJvY21hc2so
U0lHX1VOQkxPQ0ssICZzc2V0LCBOVUxMKTsKKwogCXNldF9zaWduYWwoU0lHSU5ULCBmaW5pc2gp
OwogCXNldF9zaWduYWwoU0lHQUxSTSwgY2F0Y2hlcik7CiAKIAljYXRjaGVyKCk7CiAKIAl3aGls
ZSgxKSB7Ci0JCXNpZ3NldF90IHNzZXQsIG9zc2V0OwogCQl1bnNpZ25lZCBjaGFyIHBhY2tldFs0
MDk2XTsKIAkJc3RydWN0IHNvY2thZGRyX3N0b3JhZ2UgZnJvbTsKIAkJc29ja2xlbl90IGFsZW4g
PSBzaXplb2YoZnJvbSk7CmRpZmYgLXVycCBpcHV0aWxzLXMyMDEwMTAwNi5vcmlnL3JkaXNjLmMg
aXB1dGlscy1zMjAxMDEwMDYvcmRpc2MuYwotLS0gaXB1dGlscy1zMjAxMDEwMDYub3JpZy9yZGlz
Yy5jCTIwMTAtMTAtMDYgMDg6NTk6MjAuMDAwMDAwMDAwIC0wMzAwCisrKyBpcHV0aWxzLXMyMDEw
MTAwNi9yZGlzYy5jCTIwMTAtMTEtMDUgMTY6MTQ6MzMuMDAwMDAwMDAwIC0wMjAwCkBAIC00NDks
NiArNDQ5LDcgQEAgbmV4dDoKIAlzaWdhZGRzZXQoJnNzZXQsIFNJR0hVUCk7CiAJc2lnYWRkc2V0
KCZzc2V0LCBTSUdURVJNKTsKIAlzaWdhZGRzZXQoJnNzZXQsIFNJR0lOVCk7CisJc2lncHJvY21h
c2soU0lHX1VOQkxPQ0ssICZzc2V0LCBOVUxMKTsKIAogCWluaXQoKTsKIAlpZiAoam9pbihzLCAm
am9pbmFkZHIpIDwgMCkgewo=
--001517511d3a59c763049453abe8--
