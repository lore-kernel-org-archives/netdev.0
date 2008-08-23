From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Sat, 23 Aug 2008 10:51:29 -0700
Message-ID: <86802c440808231051j54bbebd3j7cb1943ef1af3e45@mail.gmail.com>
References: <825188.80277.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_33971_17542914.1219513889637"
Cc: "Ingo Molnar" <mingo@elte.hu>, "Vivek Goyal" <vgoyal@redhat.com>,
	"Bill Fink" <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754044AbYHWRvo@vger.kernel.org>
In-Reply-To: <825188.80277.qm@web82105.mail.mud.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_33971_17542914.1219513889637
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sat, Aug 23, 2008 at 4:58 AM, David Witbrodt <dawitbro@sbcglobal.net> wrote:
>
>
>> please send out after booting with hpet=disable
>> lspci -tv
>> lspci -vvxxx
>
> Info attached:

00:14.0 SMBus: ATI Technologies Inc SBx00 SMBus Controller (rev 13)
	Subsystem: Elitegroup Computer Systems Device 2621
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Region 0: I/O ports at fa00 [size=16]
	Region 1: Memory at 80000000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [b0] HyperTransport: MSI Mapping Enable- Fixed+
	Kernel driver in use: piix4_smbus
00: 02 10 85 43 03 04 30 02 13 00 05 0c 00 00 80 00
10: 01 fa 00 00 00 00 00 80 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 19 10 21 26
30: 00 00 00 00 b0 00 00 00 00 00 00 00 00 00 00 00
40: d4 3b 00 05 00 00 00 00 0f ff 00 00 00 00 00 00
50: f0 01 f0 0e f0 0f f0 07 11 0b f0 0f 00 00 00 00
60: 01 00 24 00 bf fd de 8f 3f 90 00 00 20 00 00 00
70: 00 01 00 00 08 00 c0 fe ff 6e 00 00 00 00 f0 0f
80: f0 0a f0 0f 00 00 00 00 00 00 00 00 8c 00 00 80
90: 01 fa 00 00 fa de ff 00 00 00 00 00 00 00 00 00
a0: 00 00 ff ff ff ff f0 08 ff fd 12 02 16 7b 20 00
b0: 08 00 02 a8 00 00 00 00 00 00 00 00 f0 0f 08 1a
c0: ff ff ff ff 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: d8 0c 00 00 00 00 44 00 00 00 00 00 aa 00 10 01

it seems kernel update BAR1 from 0xfed00000 to 0x80000000 after it can
not give 0xfed00000 to that device.

please try attached patch, and send out lspci -vvxxxx again.

YH

------=_Part_33971_17542914.1219513889637
Content-Type: text/x-patch; name=hpet_in_bar1.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fk8j033r1
Content-Disposition: attachment; filename=hpet_in_bar1.patch

W1BBVENIXSB4ODY6IHByb3RlY3QgaHBldCBpbiBCQVIgZm9yIG9uZSBBVEkgY2hpcHNldAoKc28g
YXZvaWQga2VybmVsIGRvbid0IGFsbG9jYXRlIG5yZSByZXNvdXJjZSBmb3IgaXQgYmVjYXVzZSBp
dCBjYW4gbm90IGFsbG9jYXRlIHRoZSBvbGQKYWRkcmVzcyBmcm9tIEJJT1MuCgp0aGUgc2FtZSB3
YXkgbGlrZSBzb21lIElPIEFQSUMgYWRkcmVzcyBpbiBCQVIgaGFuZGxpbmcKClNpZ25lZC1vZmYt
Ynk6IFlpbmdoYWkgTHUgPHlobHUua2VucmVsQGdtYWlsLmNvbT4KCi0tLQogZHJpdmVycy9wY2kv
cXVpcmtzLmMgfCAgIDE2ICsrKysrKysrKysrKysrKysKIDEgZmlsZSBjaGFuZ2VkLCAxNiBpbnNl
cnRpb25zKCspCgpJbmRleDogbGludXgtMi42L2RyaXZlcnMvcGNpL3F1aXJrcy5jCj09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT0KLS0tIGxpbnV4LTIuNi5vcmlnL2RyaXZlcnMvcGNpL3F1aXJrcy5jCisrKyBsaW51eC0yLjYv
ZHJpdmVycy9wY2kvcXVpcmtzLmMKQEAgLTE5MTgsNiArMTkxOCwyMiBAQCBERUNMQVJFX1BDSV9G
SVhVUF9IRUFERVIoUENJX1ZFTkRPUl9JRF9CCiAJCQkgUENJX0RFVklDRV9JRF9OWDJfNTcwOVMs
CiAJCQkgcXVpcmtfYnJjbV81NzB4X2xpbWl0X3ZwZCk7CiAKK3N0YXRpYyB2b2lkIF9faW5pdCBx
dWlya19ocGV0X2luX2JhcihzdHJ1Y3QgcGNpX2RldiAqcGRldikKK3sKKwlpbnQgaTsKKwl1bnNp
Z25lZCBpbnQgYmFzZSwgc2l6ZTsKKworCS8qIHRoZSBCQVIxIGlzIHRoZSBsb2NhdGlvbiBvZiB0
aGUgSFBFVC4uLndlIG11c3QKKwkgKiBub3QgdG91Y2ggdGhpcywgc28gZm9yY2libHkgaW5zZXJ0
IGl0IGludG8gdGhlIHJlc291cmNlIHRyZWUgKi8KKwliYXNlID0gcGNpX3Jlc291cmNlX3N0YXJ0
KHBkZXYsIDEpOworCXNpemUgPSBwY2lfcmVzb3VyY2VfbGVuKHBkZXYsIDEpOworCWlmIChiYXNl
ICYmIHNpemUpIHsKKwkJaW5zZXJ0X3Jlc291cmNlKCZpb21lbV9yZXNvdXJjZSwgJnBkZXYtPnJl
c291cmNlWzFdKTsKKwkJZGV2X2luZm8oJmRldi0+ZGV2LCAiSFBFVCBhdCAlMDR4LSUwNHhcbiIs
IG5hbWUsIGJhc2UsIGJhc2UgKyBzaXplIC0gMSk7CisJfQorfQorREVDTEFSRV9QQ0lfRklYVVBf
SEVBREVSKFBDSV9WRU5ET1JfSURfQVRJLCAweDM0ODUsIHF1aXJrX2hwZXRfaW5fYmFyKTsKKwog
I2lmZGVmIENPTkZJR19QQ0lfTVNJCiAvKiBTb21lIGNoaXBzZXRzIGRvIG5vdCBzdXBwb3J0IE1T
SS4gV2UgY2Fubm90IGVhc2lseSByZWx5IG9uIHNldHRpbmcKICAqIFBDSV9CVVNfRkxBR1NfTk9f
TVNJIGluIGl0cyBidXMgZmxhZ3MgYmVjYXVzZSB0aGVyZSBhcmUgYWN0dWFsbHkK
------=_Part_33971_17542914.1219513889637--
