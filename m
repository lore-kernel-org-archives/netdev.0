From: Arthur Kepner <akepner@sgi.com>
Subject: [PATCH] preempt count regression w/ lockless loopback patch
Date: Tue, 22 Jun 2004 09:24:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SGI.4.56.0406220913010.1334066@neteng.engr.sgi.com>
References: <200406210510.i5L5A340018849@hera.kernel.org>
 <20040621035702.6114bdbe.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1072017398-2022891538-1087921245=:1334066"
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>,
        Chris Wright <chrisw@osdl.org>, Bob Gill <gillb4@telusplanet.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040621035702.6114bdbe.akpm@osdl.org>
Content-ID: <Pine.SGI.4.56.0406220920560.1334066@neteng.engr.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1072017398-2022891538-1087921245=:1334066
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.SGI.4.56.0406220920561.1334066@neteng.engr.sgi.com>


On Mon, 21 Jun 2004, Andrew Morton wrote:

> The loopback_stats handling looks wrong:
> .....
>
> each get_cpu_ptr() does get_cpu(), which increments preempt_count().  But
> there is only a single put_cpu_ptr() in there.

Correct. At least one person has tripped over this already. (See "Re:
[2.6.7-bk] NFS-related kernel panic" on lkml.)

> .....
>
> This compiles, but does need runtime testing.
>

I made one small change in get_stats() and tested with a preemptible
kernel on a 32p system. Looks good. The tested patch is attached.

--

Arthur
---1072017398-2022891538-1087921245=:1334066
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; NAME="patch.preempt_bug"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.SGI.4.56.0406220920450.1334066@neteng.engr.sgi.com>
Content-Description: patch for preempt count bug
Content-Disposition: ATTACHMENT; FILENAME="patch.preempt_bug"

LS0tIGxpbnV4LnRtcC9kcml2ZXJzL25ldC9sb29wYmFjay5jCTIwMDQtMDYt
MjIgMDk6MDA6NDEuMDAwMDAwMDAwIC0wNzAwDQorKysgbGludXgvZHJpdmVy
cy9uZXQvbG9vcGJhY2suYwkyMDA0LTA2LTIyIDA5OjA2OjQxLjAwMDAwMDAw
MCAtMDcwMA0KQEAgLTU1LDggKzU1LDkgQEANCiAjaW5jbHVkZSA8bGludXgv
aWZfYXJwLmg+CS8qIEZvciBBUlBIUkRfRVRIRVIgKi8NCiAjaW5jbHVkZSA8
bGludXgvaXAuaD4NCiAjaW5jbHVkZSA8bGludXgvdGNwLmg+DQorI2luY2x1
ZGUgPGxpbnV4L3BlcmNwdS5oPg0KIA0KLXN0YXRpYyBzdHJ1Y3QgbmV0X2Rl
dmljZV9zdGF0cyAqbG9vcGJhY2tfc3RhdHM7DQorc3RhdGljIERFRklORV9Q
RVJfQ1BVKHN0cnVjdCBuZXRfZGV2aWNlX3N0YXRzLCBsb29wYmFja19zdGF0
cyk7DQogDQogI2RlZmluZSBMT09QQkFDS19PVkVSSEVBRCAoMTI4ICsgTUFY
X0hFQURFUiArIDE2ICsgMTYpDQogDQpAQCAtMTI0LDYgKzEyNSw3IEBADQog
ICovDQogc3RhdGljIGludCBsb29wYmFja194bWl0KHN0cnVjdCBza19idWZm
ICpza2IsIHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpDQogew0KKwlzdHJ1Y3Qg
bmV0X2RldmljZV9zdGF0cyAqbGJfc3RhdHM7DQogDQogCXNrYl9vcnBoYW4o
c2tiKTsNCiANCkBAIC0xNDIsMTMgKzE0NCwxMiBAQA0KIAl9DQogDQogCWRl
di0+bGFzdF9yeCA9IGppZmZpZXM7DQotCWlmIChsaWtlbHkobG9vcGJhY2tf
c3RhdHMpKSB7DQotCQlnZXRfY3B1X3B0cihsb29wYmFja19zdGF0cyktPnJ4
X2J5dGVzICs9IHNrYi0+bGVuOw0KLQkJZ2V0X2NwdV9wdHIobG9vcGJhY2tf
c3RhdHMpLT50eF9ieXRlcyArPSBza2ItPmxlbjsNCi0JCWdldF9jcHVfcHRy
KGxvb3BiYWNrX3N0YXRzKS0+cnhfcGFja2V0cysrOw0KLQkJZ2V0X2NwdV9w
dHIobG9vcGJhY2tfc3RhdHMpLT50eF9wYWNrZXRzKys7DQotCQlwdXRfY3B1
X3B0cihsb29wYmFja19zdGF0cyk7DQotCX0NCisJbGJfc3RhdHMgPSAmcGVy
X2NwdShsb29wYmFja19zdGF0cywgZ2V0X2NwdSgpKTsNCisJbGJfc3RhdHMt
PnJ4X2J5dGVzICs9IHNrYi0+bGVuOw0KKwlsYl9zdGF0cy0+dHhfYnl0ZXMg
Kz0gc2tiLT5sZW47DQorCWxiX3N0YXRzLT5yeF9wYWNrZXRzKys7DQorCWxi
X3N0YXRzLT50eF9wYWNrZXRzKys7DQorCXB1dF9jcHUoKTsNCiANCiAJbmV0
aWZfcngoc2tiKTsNCiANCkBAIC0xNjUsMTkgKzE2NiwxOSBAQA0KIAl9DQog
DQogCW1lbXNldChzdGF0cywgMCwgc2l6ZW9mKHN0cnVjdCBuZXRfZGV2aWNl
X3N0YXRzKSk7DQotCWlmICghbG9vcGJhY2tfc3RhdHMpIHsNCi0JCXJldHVy
biBzdGF0czsNCi0JfQ0KIA0KIAlmb3IgKGk9MDsgaSA8IE5SX0NQVVM7IGkr
Kykgew0KKwkJc3RydWN0IG5ldF9kZXZpY2Vfc3RhdHMgKmxiX3N0YXRzOw0K
Kw0KIAkJaWYgKCFjcHVfcG9zc2libGUoaSkpIA0KIAkJCWNvbnRpbnVlOw0K
LQkJc3RhdHMtPnJ4X2J5dGVzICAgKz0gcGVyX2NwdV9wdHIobG9vcGJhY2tf
c3RhdHMsIGkpLT5yeF9ieXRlczsNCi0JCXN0YXRzLT50eF9ieXRlcyAgICs9
IHBlcl9jcHVfcHRyKGxvb3BiYWNrX3N0YXRzLCBpKS0+dHhfYnl0ZXM7DQot
CQlzdGF0cy0+cnhfcGFja2V0cyArPSBwZXJfY3B1X3B0cihsb29wYmFja19z
dGF0cywgaSktPnJ4X3BhY2tldHM7DQotCQlzdGF0cy0+dHhfcGFja2V0cyAr
PSBwZXJfY3B1X3B0cihsb29wYmFja19zdGF0cywgaSktPnR4X3BhY2tldHM7
DQorCQlsYl9zdGF0cyA9ICZwZXJfY3B1KGxvb3BiYWNrX3N0YXRzLCBpKTsN
CisJCXN0YXRzLT5yeF9ieXRlcyAgICs9IGxiX3N0YXRzLT5yeF9ieXRlczsN
CisJCXN0YXRzLT50eF9ieXRlcyAgICs9IGxiX3N0YXRzLT50eF9ieXRlczsN
CisJCXN0YXRzLT5yeF9wYWNrZXRzICs9IGxiX3N0YXRzLT5yeF9wYWNrZXRz
Ow0KKwkJc3RhdHMtPnR4X3BhY2tldHMgKz0gbGJfc3RhdHMtPnR4X3BhY2tl
dHM7DQogCX0NCi0JCQkJDQorDQogCXJldHVybiBzdGF0czsNCiB9DQogDQpA
QCAtMjEyLDggKzIxMyw2IEBADQogCQlsb29wYmFja19kZXYuZ2V0X3N0YXRz
ID0gJmdldF9zdGF0czsNCiAJfQ0KIA0KLQlsb29wYmFja19zdGF0cyA9IGFs
bG9jX3BlcmNwdShzdHJ1Y3QgbmV0X2RldmljZV9zdGF0cyk7DQotCQ0KIAly
ZXR1cm4gcmVnaXN0ZXJfbmV0ZGV2KCZsb29wYmFja19kZXYpOw0KIH07DQog
DQo=

---1072017398-2022891538-1087921245=:1334066--
