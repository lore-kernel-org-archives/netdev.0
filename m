From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: dev->destructor
Date: Mon, 5 May 2003 13:00:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030505130050.4b9868bb.shemminger@osdl.org>
References: <20030502.134804.78707298.davem@redhat.com>
	<20030503040949.804182C003@lists.samba.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart_Mon__5_May_2003_13:00:50_-0700_086866c8"
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20030503040949.804182C003@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart_Mon__5_May_2003_13:00:50_-0700_086866c8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

As an experiment, tried acquiring module ref count every time network
device is ref counted.  The result is discovering that there are cases
in the Ethernet module init path where there is a call to dev_hold()
without a previous explicit ref count.

kernel BUG at include/linux/module.h:284!
invalid operand: 0000 [#1]
CPU:    0
EIP:    0060:[<c028fd02>]    Not tainted
EFLAGS: 00010246
EIP is at linkwatch_fire_event+0x170/0x1a3
eax: 00000000   ebx: c047fad0   ecx: 00000020   edx: f88c8100
esi: f88c7100   edi: f6fa7000   ebp: f6f15de4   esp: f6f15dc8
ds: 007b   es: 007b   ss: 0068
Process modprobe (pid: 408, threadinfo=f6f14000 task=f78f46a0)
Stack: f88c7100 c03f7008 00000246 f6f14000 f6fa7000 00000000 fffc829b f6f15df8 
       f88c0ab9 f6fa7000 f6fa71e0 033002a8 f6f15e24 f88c00e0 f6fa71e0 00007148 
       c03e2e80 f6fa7320 c011eb46 ffffffef f6f15e3e f6fa71e0 fffc829b f6f15e50 
Call Trace:
 [<f88c7100>] +0x0/0x1180 [e100]
 [<f88c0ab9>] e100_update_link_state+0x97/0xa2 [e100]
 [<f88c00e0>] e100_find_speed_duplex+0x20/0x26a [e100]
 [<c011eb46>] sys_sched_yield+0xc0/0xfe
 [<f88c07de>] e100_auto_neg+0x114/0x11c [e100]
 [<c01fa4f8>] __delay+0x14/0x18
 [<f88c081d>] e100_phy_set_speed_duplex+0x37/0xa4 [e100]
 [<f88c0997>] e100_phy_init+0x69/0x78 [e100]
 [<f88ba1dc>] e100_hw_init+0x14/0x11e [e100]
 [<f88bc432>] e100_rd_pwa_no+0x32/0x40 [e100]
 [<f88ba058>] e100_init+0xf6/0x126 [e100]
 [<f88b9273>] e100_found1+0x1a9/0x42e [e100]
 [<f88c5b25>] e100_driver_version+0x0/0xb [e100]
 [<f88c5e40>] e100_driver+0x0/0xa0 [e100]
 [<c01fe884>] pci_device_probe+0x5a/0x68
 [<f88c5b60>] e100_id_table+0x0/0x2e0 [e100]
 [<f88c5e68>] e100_driver+0x28/0xa0 [e100]
 [<c0241853>] bus_match+0x43/0x6e
 [<f88c5e68>] e100_driver+0x28/0xa0 [e100]
 [<f88c5e68>] e100_driver+0x28/0xa0 [e100]
 [<c0241956>] driver_attach+0x5c/0x60
 [<f88c5e68>] e100_driver+0x28/0xa0 [e100]
 [<f88c5e68>] e100_driver+0x28/0xa0 [e100]
 [<c0241c2a>] bus_add_driver+0xb2/0xc8
 [<f88c5e68>] e100_driver+0x28/0xa0 [e100]
 [<f88c7100>] +0x0/0x1180 [e100]
 [<c01fe99a>] pci_register_driver+0x46/0x56
 [<f88c5e68>] e100_driver+0x28/0xa0 [e100]
 [<f880c015>] +0x15/0x3e [e100]
 [<f88c5e40>] e100_driver+0x0/0xa0 [e100]
 [<c013b034>] sys_init_module+0x1b0/0x292
all_call+0x7/0xb

Code: 0f 0b 1c 01 97 5a 32 c0 e9 d9 fe ff ff c7 04 24 0c 00 00 00 
 ./ifup: line 91:   408 Segmentation fault      modprobe $1 >/dev/null 2>&1


--Multipart_Mon__5_May_2003_13:00:50_-0700_086866c8
Content-Type: application/octet-stream;
 name="netdev-module.diff"
Content-Disposition: attachment;
 filename="netdev-module.diff"
Content-Transfer-Encoding: base64

ZGlmZiAtdXJOcCAtWCBkb250ZGlmZiBsaW51eC0yLjUvaW5jbHVkZS9hc20taTM4Ni9hc21fb2Zm
c2V0cy5oIGxpbnV4LTIuNS1kZXYvaW5jbHVkZS9hc20taTM4Ni9hc21fb2Zmc2V0cy5oCi0tLSBs
aW51eC0yLjUvaW5jbHVkZS9hc20taTM4Ni9hc21fb2Zmc2V0cy5oCTE5NjktMTItMzEgMTY6MDA6
MDAuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjUtZGV2L2luY2x1ZGUvYXNtLWkzODYvYXNt
X29mZnNldHMuaAkyMDAzLTA1LTA1IDEwOjExOjUwLjAwMDAwMDAwMCAtMDcwMApAQCAtMCwwICsx
LDIyIEBACisjaWZuZGVmIF9fQVNNX09GRlNFVFNfSF9fCisjZGVmaW5lIF9fQVNNX09GRlNFVFNf
SF9fCisvKgorICogRE8gTk9UIE1PRElGWS4KKyAqCisgKiBUaGlzIGZpbGUgd2FzIGdlbmVyYXRl
ZCBieSBhcmNoL2kzODYvTWFrZWZpbGUKKyAqCisgKi8KKworI2RlZmluZSBTSUdDT05URVhUX2Vh
eCA0NCAvKiBvZmZzZXRvZiAoc3RydWN0IHNpZ2NvbnRleHQsIGVheCkgKi8KKyNkZWZpbmUgU0lH
Q09OVEVYVF9lYnggMzIgLyogb2Zmc2V0b2YgKHN0cnVjdCBzaWdjb250ZXh0LCBlYngpICovCisj
ZGVmaW5lIFNJR0NPTlRFWFRfZWN4IDQwIC8qIG9mZnNldG9mIChzdHJ1Y3Qgc2lnY29udGV4dCwg
ZWN4KSAqLworI2RlZmluZSBTSUdDT05URVhUX2VkeCAzNiAvKiBvZmZzZXRvZiAoc3RydWN0IHNp
Z2NvbnRleHQsIGVkeCkgKi8KKyNkZWZpbmUgU0lHQ09OVEVYVF9lc2kgMjAgLyogb2Zmc2V0b2Yg
KHN0cnVjdCBzaWdjb250ZXh0LCBlc2kpICovCisjZGVmaW5lIFNJR0NPTlRFWFRfZWRpIDE2IC8q
IG9mZnNldG9mIChzdHJ1Y3Qgc2lnY29udGV4dCwgZWRpKSAqLworI2RlZmluZSBTSUdDT05URVhU
X2VicCAyNCAvKiBvZmZzZXRvZiAoc3RydWN0IHNpZ2NvbnRleHQsIGVicCkgKi8KKyNkZWZpbmUg
U0lHQ09OVEVYVF9lc3AgMjggLyogb2Zmc2V0b2YgKHN0cnVjdCBzaWdjb250ZXh0LCBlc3ApICov
CisjZGVmaW5lIFNJR0NPTlRFWFRfZWlwIDU2IC8qIG9mZnNldG9mIChzdHJ1Y3Qgc2lnY29udGV4
dCwgZWlwKSAqLworCisjZGVmaW5lIFJUX1NJR0ZSQU1FX3NpZ2NvbnRleHQgMTY0IC8qIG9mZnNl
dG9mIChzdHJ1Y3QgcnRfc2lnZnJhbWUsIHVjLnVjX21jb250ZXh0KSAqLworCisjZW5kaWYKZGlm
ZiAtdXJOcCAtWCBkb250ZGlmZiBsaW51eC0yLjUvaW5jbHVkZS9saW51eC9uZXRkZXZpY2UuaCBs
aW51eC0yLjUtZGV2L2luY2x1ZGUvbGludXgvbmV0ZGV2aWNlLmgKLS0tIGxpbnV4LTIuNS9pbmNs
dWRlL2xpbnV4L25ldGRldmljZS5oCTIwMDMtMDQtMTQgMTM6MzI6MjEuMDAwMDAwMDAwIC0wNzAw
CisrKyBsaW51eC0yLjUtZGV2L2luY2x1ZGUvbGludXgvbmV0ZGV2aWNlLmgJMjAwMy0wNS0wNSAx
MDowNjoxOS4wMDAwMDAwMDAgLTA3MDAKQEAgLTI5LDYgKzI5LDcgQEAKICNpbmNsdWRlIDxsaW51
eC9pZl9ldGhlci5oPgogI2luY2x1ZGUgPGxpbnV4L2lmX3BhY2tldC5oPgogI2luY2x1ZGUgPGxp
bnV4L2tvYmplY3QuaD4KKyNpbmNsdWRlIDxsaW51eC9tb2R1bGUuaD4KIAogI2luY2x1ZGUgPGFz
bS9hdG9taWMuaD4KICNpbmNsdWRlIDxhc20vY2FjaGUuaD4KQEAgLTYyOSwxMiArNjMwLDMyIEBA
IGV4dGVybiBpbnQgbmV0ZGV2X2ZpbmlzaF91bnJlZ2lzdGVyKHN0cnUKIAogc3RhdGljIGlubGlu
ZSB2b2lkIGRldl9wdXQoc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIHsKKwltb2R1bGVfcHV0KGRl
di0+b3duZXIpOwogCWlmIChhdG9taWNfZGVjX2FuZF90ZXN0KCZkZXYtPnJlZmNudCkpCiAJCW5l
dGRldl9maW5pc2hfdW5yZWdpc3RlcihkZXYpOwogfQogCi0jZGVmaW5lIF9fZGV2X3B1dChkZXYp
IGF0b21pY19kZWMoJihkZXYpLT5yZWZjbnQpCi0jZGVmaW5lIGRldl9ob2xkKGRldikgYXRvbWlj
X2luYygmKGRldiktPnJlZmNudCkKK3N0YXRpYyBpbmxpbmUgdm9pZCBfX2Rldl9wdXQoc3RydWN0
IG5ldF9kZXZpY2UgKmRldikKK3sKKwltb2R1bGVfcHV0KGRldi0+b3duZXIpOworCWF0b21pY19k
ZWMoJmRldi0+cmVmY250KTsKK30KKworc3RhdGljIGlubGluZSB2b2lkIGRldl9ob2xkKHN0cnVj
dCBuZXRfZGV2aWNlICpkZXYpCit7CisJX19tb2R1bGVfZ2V0KGRldi0+b3duZXIpOworCWF0b21p
Y19pbmMoJmRldi0+cmVmY250KTsKK30KKworc3RhdGljIGlubGluZSBpbnQgZGV2X3RyeV9ob2xk
KHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpCit7CisJaW50IHJldCA9IDA7CisJaWYgKHRyeV9tb2R1
bGVfZ2V0KGRldi0+b3duZXIpKXsKKwkJYXRvbWljX2luYygmZGV2LT5yZWZjbnQpOworCQlyZXQg
PSAxOworCX0KKwlyZXR1cm4gcmV0OworfQogCiAvKiBDYXJyaWVyIGxvc3MgZGV0ZWN0aW9uLCBk
aWFsIG9uIGRlbWFuZC4gVGhlIGZ1bmN0aW9ucyBuZXRpZl9jYXJyaWVyX29uCiAgKiBhbmQgX29m
ZiBtYXkgYmUgY2FsbGVkIGZyb20gSVJRIGNvbnRleHQsIGJ1dCBpdCBpcyBjYWxsZXIKZGlmZiAt
dXJOcCAtWCBkb250ZGlmZiBsaW51eC0yLjUvbmV0L2NvcmUvZGV2LmMgbGludXgtMi41LWRldi9u
ZXQvY29yZS9kZXYuYwotLS0gbGludXgtMi41L25ldC9jb3JlL2Rldi5jCTIwMDMtMDUtMDUgMDk6
NDE6MDMuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjUtZGV2L25ldC9jb3JlL2Rldi5jCTIw
MDMtMDUtMDUgMTA6MDY6MjAuMDAwMDAwMDAwIC0wNzAwCkBAIC0xLDMgKzEsNCBAQAorI2RlZmlu
ZSBORVRfUkVGQ05UX0RFQlVHCTEKIC8qCiAgKiAJTkVUMwlQcm90b2NvbCBpbmRlcGVuZGVudCBk
ZXZpY2Ugc3VwcG9ydCByb3V0aW5lcy4KICAqCkBAIC00NDAsOCArNDQxLDggQEAgc3RydWN0IG5l
dF9kZXZpY2UgKmRldl9nZXRfYnlfbmFtZShjb25zdAogCiAJcmVhZF9sb2NrKCZkZXZfYmFzZV9s
b2NrKTsKIAlkZXYgPSBfX2Rldl9nZXRfYnlfbmFtZShuYW1lKTsKLQlpZiAoZGV2KQotCQlkZXZf
aG9sZChkZXYpOworCWlmIChkZXYgJiYgIWRldl90cnlfaG9sZChkZXYpKQorCQlkZXYgPSBOVUxM
OwogCXJlYWRfdW5sb2NrKCZkZXZfYmFzZV9sb2NrKTsKIAlyZXR1cm4gZGV2OwogfQpAQCAtNTEz
LDggKzUxNCw4IEBAIHN0cnVjdCBuZXRfZGV2aWNlICpkZXZfZ2V0X2J5X2luZGV4KGludCAKIAog
CXJlYWRfbG9jaygmZGV2X2Jhc2VfbG9jayk7CiAJZGV2ID0gX19kZXZfZ2V0X2J5X2luZGV4KGlm
aW5kZXgpOwotCWlmIChkZXYpCi0JCWRldl9ob2xkKGRldik7CisJaWYgKGRldiAmJiAhZGV2X3Ry
eV9ob2xkKGRldikpCisJCWRldiA9IE5VTEw7CiAJcmVhZF91bmxvY2soJmRldl9iYXNlX2xvY2sp
OwogCXJldHVybiBkZXY7CiB9CkBAIC01NjMsOCArNTY0LDggQEAgc3RydWN0IG5ldF9kZXZpY2Ug
KiBkZXZfZ2V0X2J5X2ZsYWdzKHVucwogCiAJcmVhZF9sb2NrKCZkZXZfYmFzZV9sb2NrKTsKIAlk
ZXYgPSBfX2Rldl9nZXRfYnlfZmxhZ3MoaWZfZmxhZ3MsIG1hc2spOwotCWlmIChkZXYpCi0JCWRl
dl9ob2xkKGRldik7CisJaWYgKGRldiAmJiAhZGV2X3RyeV9ob2xkKGRldikpCisJICAgIGRldiA9
IE5VTEw7CiAJcmVhZF91bmxvY2soJmRldl9iYXNlX2xvY2spOwogCXJldHVybiBkZXY7CiB9CkBA
IC0yNjA5LDEwICsyNjEwLDExIEBAIGludCByZWdpc3Rlcl9uZXRkZXZpY2Uoc3RydWN0IG5ldF9k
ZXZpY2UKIAlzZXRfYml0KF9fTElOS19TVEFURV9QUkVTRU5ULCAmZGV2LT5zdGF0ZSk7CiAKIAlk
ZXYtPm5leHQgPSBOVUxMOworCWF0b21pY19pbmMoJmRldi0+cmVmY250KTsKIAlkZXZfaW5pdF9z
Y2hlZHVsZXIoZGV2KTsKIAl3cml0ZV9sb2NrX2JoKCZkZXZfYmFzZV9sb2NrKTsKIAkqZHAgPSBk
ZXY7Ci0JZGV2X2hvbGQoZGV2KTsKKwogCWRldi0+ZGVhZGJlYWYgPSAwOwogCXdyaXRlX3VubG9j
a19iaCgmZGV2X2Jhc2VfbG9jayk7CiAK

--Multipart_Mon__5_May_2003_13:00:50_-0700_086866c8--
