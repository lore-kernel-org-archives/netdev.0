From: Alexander Atanasov <alex@ssi.bg>
Subject: [PATCH] ipchains bugs in 2.2/2.4/2.5 related to netlink calls
Date: Fri, 24 May 2002 20:43:41 +0300 (EEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.21.0205241940510.208-400000@mars.z.ssi.bg>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1607778983-1170993050-1022262221=:208"
Cc: netfilter@lists.samba.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: rusty@rustcorp.com.au, kuznet@ms2.inr.ac.ru
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1607778983-1170993050-1022262221=:208
Content-Type: TEXT/PLAIN; charset=US-ASCII

	Hi there!

oom-loop fixes error handling after a netlink failure - it does not do a
cleanup and it makes every next call to ip_fw_check to detect a
loop and drop the packet.

nlma fixes a call to netlink_broadcast with GFP_KERNEL ( passed to
skb_clone ) while we are in_interrupt() ( catched by a BUG() in
slab.c:1109 ).


2.4 patches apply to 2.5 too , tested on 2.5.15.

-- 
Best Regards,
Alexander Atanasov

--1607778983-1170993050-1022262221=:208
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ipchains_core.c-oom-loop-2.4.18.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.21.0205242043410.208@mars.z.ssi.bg>
Content-Description: 
Content-Disposition: attachment; filename="ipchains_core.c-oom-loop-2.4.18.diff"

LS0tIG5ldC9pcHY0L25ldGZpbHRlci9pcGNoYWluc19jb3JlLmMub3JpZwlG
cmkgTWF5IDI0IDE5OjI3OjAxIDIwMDINCisrKyBuZXQvaXB2NC9uZXRmaWx0
ZXIvaXBjaGFpbnNfY29yZS5jCUZyaSBNYXkgMjQgMTk6MzE6MjQgMjAwMg0K
QEAgLTcyMyw2ICs3MjMsNyBAQA0KIAkJCQkJCSAgICAgIHNyY19wb3J0LCBk
c3RfcG9ydCwNCiAJCQkJCQkgICAgICBjb3VudCwgdGNwc3luKSkgew0KIAkJ
CQkJcmV0ID0gRldfQkxPQ0s7DQorCQkJCQljbGVhbnVwKGNoYWluLCAwLCBz
bG90KTsNCiAJCQkJCWdvdG8gb3V0Ow0KIAkJCQl9DQogCQkJCWJyZWFrOw0K

--1607778983-1170993050-1022262221=:208
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ipchains_core.c-nlma-2.4.18.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.21.0205242043411.208@mars.z.ssi.bg>
Content-Description: 
Content-Disposition: attachment; filename="ipchains_core.c-nlma-2.4.18.diff"

LS0tIG5ldC9pcHY0L25ldGZpbHRlci9pcGNoYWluc19jb3JlLmMub3JpZwlG
cmkgTWF5IDI0IDE5OjI3OjAxIDIwMDINCisrKyBuZXQvaXB2NC9uZXRmaWx0
ZXIvaXBjaGFpbnNfY29yZS5jCUZyaSBNYXkgMjQgMTk6Mjc6MzQgMjAwMg0K
QEAgLTU0OSw3ICs1NDksNyBAQA0KIAkJCXN0cmNweShvdXRza2ItPmRhdGEr
c2l6ZW9mKF9fdTMyKSoyLCByaWYpOw0KIAkJCW1lbWNweShvdXRza2ItPmRh
dGErc2l6ZW9mKF9fdTMyKSoyK0lGTkFNU0laLCBpcCwNCiAJCQkgICAgICAg
bGVuLShzaXplb2YoX191MzIpKjIrSUZOQU1TSVopKTsNCi0JCQluZXRsaW5r
X2Jyb2FkY2FzdChpcGZ3c2ssIG91dHNrYiwgMCwgfjAsIEdGUF9LRVJORUwp
Ow0KKwkJCW5ldGxpbmtfYnJvYWRjYXN0KGlwZndzaywgb3V0c2tiLCAwLCB+
MCwgR0ZQX0FUT01JQyk7DQogCQl9DQogCQllbHNlIHsNCiAjZW5kaWYNCg==
--1607778983-1170993050-1022262221=:208
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ip_fw.c-oom-loop-2.2.20.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.21.0205242043412.208@mars.z.ssi.bg>
Content-Description: 
Content-Disposition: attachment; filename="ip_fw.c-oom-loop-2.2.20.diff"

LS0tIG5ldC9pcHY0L2lwX2Z3LmMub3JpZwlGcmkgTWF5IDI0IDE5OjMzOjUy
IDIwMDINCisrKyBuZXQvaXB2NC9pcF9mdy5jCUZyaSBNYXkgMjQgMTk6MzQ6
MTggMjAwMg0KQEAgLTc0Nyw2ICs3NDcsNyBAQA0KIAkJCQkJCSAgICAgIHNy
Y19wb3J0LCBkc3RfcG9ydCwNCiAJCQkJCQkgICAgICBjb3VudCwgdGNwc3lu
KSkgew0KIAkJCQkJcmV0ID0gRldfQkxPQ0s7DQorCQkJCQljbGVhbnVwKGNo
YWluLCAwLCBzbG90KTsNCiAJCQkJCWdvdG8gb3V0Ow0KIAkJCQl9DQogCQkJ
CWJyZWFrOw0K
--1607778983-1170993050-1022262221=:208--
