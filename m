From: "Frantisek Rysanek" <Frantisek.Rysanek@post.cz>
Subject: [PATCH] CAN, sja1000, plx_pci.c : some device ID's for Advantech hardware
Date: Tue, 14 Jun 2011 17:01:15 +0200
Message-ID: <4DF793DB.6863.5434F06B@Frantisek.Rysanek.post.cz>
Mime-Version: 1.0
Content-Type: Multipart/Mixed; boundary=Message-Boundary-6963
Cc: P.B.Cheblakov@inp.nsk.su, urs@isnogud.escape.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.seznam.cz ([77.75.76.43]:60848 "EHLO smtp2.seznam.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181Ab1FNPBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 11:01:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Message-Boundary-6963
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body

Dear Everyone,

attached you'll find a patch that adds support for the following 
hardware by Advantech:
PCI-1680 = dual-port PCI card
UNO-2052 = fanless PC (Geode-based) with 2x SJA1000 onboard via PCI

The patch consists of just some added PCI ID's, plus a one-liner 
bugfix (?): an added delay in plx_pci_check_sja1000() between the PLX 
reset and the SJA reset, giving the SJA more time to become ready for 
the switch to Pelican mode.

Tested using cansend+candump in Debian 6.
I was amazed that all the necessary bits are included "out of the 
box" in Sarge: support for CAN in "ip", libc headers etc.

Thanks for your excellent work, and for including the CAN subsystem 
in the vanilla mainline :-) It's a relief to have an official CAN 
stack in the vanilla kernel - no need to work out of tree anymore.

Frank Rysanek

P.S.: A quick Google survey of PCI-based CAN hardware (boards) from 
various vendors has revealed that
1) Advantech has some new models (PCI-1682 and PCM-3680*I*) 
    that use a Xilinx FPGA instead of the trusty old PLX bridges,
    and for which there is no register-level documentation
2) similarly, I've found a neat dual-port MiniPCI board from 
   Peak System Technik, apparently using a Lattice chip for the 
   same purpose... (likely with an open-source "character device" 
   driver from Peak, along with an additional user-space SDK)
I assume these general-purpose FPGA-based bridge devices are cheaper 
than the dedicated PLX silicon, but the change sadly does away with a 
great deal of homogenity that used to come with the slave bridges by 
PLX. I haven't put my hands on either of that new hardware, but I 
expect that the two SJA chips will still be visible as BAR's on the 
PCI bus. Hopefully there isn't much to get wrong in this kind of 
design...


--Message-Boundary-6963
Content-type: text/plain; charset=US-ASCII
Content-disposition: inline
Content-description: Attachment information.

The following section of this message contains a file attachment
prepared for transmission using the Internet MIME message format.
If you are using Pegasus Mail, or any other MIME-compliant system,
you should be able to save it or view it from within your mailer.
If you cannot, please ask your system administrator for assistance.

   ---- File information -----------
     File:  2.6.39_adv-pci-can.patch
     Date:  14 Jun 2011, 11:39
     Size:  2703 bytes.
     Type:  Unknown

--Message-Boundary-6963
Content-type: Application/Octet-stream; name="2.6.39_adv-pci-can.patch"; type=Unknown
Content-disposition: attachment; filename="2.6.39_adv-pci-can.patch"
Content-transfer-encoding: BASE64

LS0tIGRyaXZlcnMvbmV0L2Nhbi9zamExMDAwL0tjb25maWcub2xkCTIwMTEtMDYtMTQgMDk6
MzE6MzguMDAwMDAwMDAwICswMDAwCisrKyBkcml2ZXJzL25ldC9jYW4vc2phMTAwMC9LY29u
ZmlnCTIwMTEtMDYtMTQgMDk6Mjg6MDguMDAwMDAwMDAwICswMDAwCkBAIC01OCw2ICs1OCw3
IEBACiAJICAgLSBlc2QgQ0FOLVBDSWUvMjAwMAogCSAgIC0gTWFyYXRob24gQ0FOLWJ1cy1Q
Q0kgY2FyZCAoaHR0cDovL3d3dy5tYXJhdGhvbi5ydS8pCiAJICAgLSBURVdTIFRFQ0hOT0xP
R0lFUyBUUE1DODEwIGNhcmQgKGh0dHA6Ly93d3cudGV3cy5jb20vKQorCSAgIC0gQWR2YW50
ZWNoIFBDSS0xNjgwIGFuZCBVTk8tMjA1MiAoaHR0cDovL3d3dy5hZHZhbnRlY2guY29tKQog
CiBjb25maWcgQ0FOX1RTQ0FOMQogCXRyaXN0YXRlICJUUy1DQU4xIFBDMTA0IGJvYXJkcyIK
LS0tIGRyaXZlcnMvbmV0L2Nhbi9zamExMDAwL3BseF9wY2kuYy5vbGQJMjAxMS0wNi0xMCAx
NToyMTo0MS4wMDAwMDAwMDAgKzAwMDAKKysrIGRyaXZlcnMvbmV0L2Nhbi9zamExMDAwL3Bs
eF9wY2kuYwkyMDExLTA2LTE0IDA5OjM2OjMwLjAwMDAwMDAwMCArMDAwMApAQCAtNDMsNyAr
NDMsOCBAQAogCQkJIlRFV1MgVEVDSE5PTE9HSUVTIFRQTUM4MTAsICIKIAkJCSJlc2QgQ0FO
LVBDSS9DUENJL1BDSTEwNC8yMDAsICIKIAkJCSJlc2QgQ0FOLVBDSS9QTUMvMjY2LCAiCi0J
CQkiZXNkIENBTi1QQ0llLzIwMDAiKQorCQkJImVzZCBDQU4tUENJZS8yMDAwLCIKKyAgICAg
ICAgICAgICAgICAgICAgICAgICJBZHZhbnRlY2ggUENJLTE2ODAgJiBVTk8tMjA1MiIpOwog
TU9EVUxFX0xJQ0VOU0UoIkdQTCB2MiIpOwogCiAjZGVmaW5lIFBMWF9QQ0lfTUFYX0NIQU4g
MgpAQCAtMTI2LDYgKzEyNywxMCBAQAogI2RlZmluZSBURVdTX1BDSV9WRU5ET1JfSUQJCTB4
MTQ5OAogI2RlZmluZSBURVdTX1BDSV9ERVZJQ0VfSURfVE1QQzgxMAkweDAzMkEKIAorI2Rl
ZmluZSBBRFZBTlRFQ0hfUENJX1ZFTkRPUl9JRAkJMHgxM0ZFCisjZGVmaW5lIEFEVkFOVEVD
SF9QQ0kxNjgwX0RFVklDRV9JRAkweDE2ODAKKyNkZWZpbmUgQURWQU5URUNIX1VOTzIwNTJf
REVWSUNFX0lECTB4MjA1MgorCiBzdGF0aWMgdm9pZCBwbHhfcGNpX3Jlc2V0X2NvbW1vbihz
dHJ1Y3QgcGNpX2RldiAqcGRldik7CiBzdGF0aWMgdm9pZCBwbHhfcGNpX3Jlc2V0X21hcmF0
aG9uKHN0cnVjdCBwY2lfZGV2ICpwZGV2KTsKIHN0YXRpYyB2b2lkIHBseDkwNTZfcGNpX3Jl
c2V0X2NvbW1vbihzdHJ1Y3QgcGNpX2RldiAqcGRldik7CkBAIC0yMDksNiArMjE0LDIyIEBA
CiAJLyogYmFzZWQgb24gUExYOTAzMCAqLwogfTsKIAorc3RhdGljIHN0cnVjdCBwbHhfcGNp
X2NhcmRfaW5mbyBwbHhfcGNpX2NhcmRfaW5mb19wY2kxNjgwIF9fZGV2aW5pdGRhdGEgPSB7
CisJIkFkdmFudGVjaCBQQ0ktMTY4MCIsIDIsCisJUExYX1BDSV9DQU5fQ0xPQ0ssIFBMWF9Q
Q0lfT0NSLCBQTFhfUENJX0NEUiwKKwl7MCwgMHgwMCwgMHgwMH0sIHsgezIsIDB4MDAsIDB4
ODB9LCB7MywgMHgwMCwgMHg4MH0gfSwKKwkmcGx4X3BjaV9yZXNldF9jb21tb24KKwkvKiBi
YXNlZCBvbiBQTFggUENJOTAzMCAqLworfTsKKworc3RhdGljIHN0cnVjdCBwbHhfcGNpX2Nh
cmRfaW5mbyBwbHhfcGNpX2NhcmRfaW5mb191bm8yMDUyIF9fZGV2aW5pdGRhdGEgPSB7CisJ
IkFkdmFudGVjaCBVTk8tMjA1MiIsIDIsCisJUExYX1BDSV9DQU5fQ0xPQ0ssIFBMWF9QQ0lf
T0NSLCBQTFhfUENJX0NEUiwKKwl7MCwgMHgwMCwgMHgwMH0sIHsgezIsIDB4MDAsIDB4ODB9
LCB7MywgMHgwMCwgMHg4MH0gfSwKKwkmcGx4X3BjaV9yZXNldF9jb21tb24KKwkvKiBiYXNl
ZCBvbiBQTFggUENJOTA1MiAqLworfTsKKwogc3RhdGljIERFRklORV9QQ0lfREVWSUNFX1RB
QkxFKHBseF9wY2lfdGJsKSA9IHsKIAl7CiAJCS8qIEFkbGluayBQQ0ktNzg0MS9jUENJLTc4
NDEgKi8KQEAgLTI4MCw2ICszMDEsMjAgQEAKIAkJMCwgMCwKIAkJKGtlcm5lbF91bG9uZ190
KSZwbHhfcGNpX2NhcmRfaW5mb190ZXdzCiAJfSwKKwl7CisJCS8qIEFkdmFudGVjaCBQQ0kt
MTY4MCAqLworCQlBRFZBTlRFQ0hfUENJX1ZFTkRPUl9JRCwgQURWQU5URUNIX1BDSTE2ODBf
REVWSUNFX0lELAorCQlBRFZBTlRFQ0hfUENJX1ZFTkRPUl9JRCwgUENJX0FOWV9JRCwKKwkJ
MCwgMCwKKwkJKGtlcm5lbF91bG9uZ190KSZwbHhfcGNpX2NhcmRfaW5mb19wY2kxNjgwCisJ
fSwKKwl7CisJCS8qIEFkdmFudGVjaCBVTk8tMjA1MiAqLworCQlBRFZBTlRFQ0hfUENJX1ZF
TkRPUl9JRCwgQURWQU5URUNIX1VOTzIwNTJfREVWSUNFX0lELAorCQlQQ0lfQU5ZX0lELCBQ
Q0lfQU5ZX0lELAorCQkwLCAwLAorCQkoa2VybmVsX3Vsb25nX3QpJnBseF9wY2lfY2FyZF9p
bmZvX3VubzIwNTIKKwl9LAogCXsgMCx9CiB9OwogTU9EVUxFX0RFVklDRV9UQUJMRShwY2ks
IHBseF9wY2lfdGJsKTsKQEAgLTMwMyw2ICszMzgsOSBAQAogewogCWludCBmbGFnID0gMDsK
IAorICAgICAgICAvKiBHaXZlIHRoZSBTSkEgY2hpcCBzb21lIHRpbWUgdG8gZmluaXNoIGl0
cyByZXNldCAoaW52b2tlZCB2aWEgUExYIGNoaXApICovCisgICAgICAgIG1kZWxheSgxMDAp
OworCiAJLyoKIAkgKiBDaGVjayByZWdpc3RlcnMgYWZ0ZXIgaGFyZHdhcmUgcmVzZXQgKHRo
ZSBCYXNpYyBtb2RlKQogCSAqIFNlZSBzdGF0ZXMgb24gcC4gMTAgb2YgdGhlIERhdGFzaGVl
dC4K

--Message-Boundary-6963--
