From: "Stam, Michel [FINT]" <M.Stam@fugro.nl>
Subject: ASIX 88772
Date: Mon, 29 Sep 2014 15:45:56 +0200
Message-ID: <C89EFD3CD56F64468D3D206D683A8D2203863DD8@ldam-msx2.fugro-nl.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01CFDBEB.B2162D08"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu2.fugro.com ([46.34.88.152]:38023 "EHLO
	smtp.eu2.fugro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403AbaI2Np7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 09:45:59 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01CFDBEB.B2162D08
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Dear list,

A while back we did an upgrade of the firmware running on our embedded
devices. These devices, amongst others, use an ASIX chip, model 88772A.

What we noticed, was that ethtool settings would be negated when the
interface was set to 'up'. This, effectively voided any control we tried
to exercise over the autonegotiation process (it always returns back to
100 Mbps/Full duplex). After comparing with the kernel we used before
(we used 2.6.22 before, now 3.10.34), I discovered that the difference
was the .link_reset function pointer defined in the driver_info struct
in drivers/net/usb/asix_devices.c:888. By setting it back to its
previous value, ax88772_link_reset, the functionality is restored and
ethtool behaves as expected.

Apparently this change to drivers/net/usb/asix_devices.c happened at
line 888 as part of commit 2e55cc721, which moved the driver into its
own file with that commit. It apparently also addresses some link reset
problems.

Would anyone have any idea what kind of link reset problems these were?

I have attached a git format-patch which works for us, but I would like
to make sure it does not break other devices instead. I've attached it
to this email because the mail client seems to corrupt the patches
occasionally.

Best regards,

Michel Stam

------_=_NextPart_001_01CFDBEB.B2162D08
Content-Type: application/octet-stream;
	name="0001-Don-t-reset-PHY-on-if_up-for-ASIX-88772.patch"
Content-Transfer-Encoding: base64
Content-Description: 0001-Don-t-reset-PHY-on-if_up-for-ASIX-88772.patch
Content-Disposition: attachment;
	filename="0001-Don-t-reset-PHY-on-if_up-for-ASIX-88772.patch"

RnJvbSBmZWIyOThlYTBiNTczM2JjYmMzMTcxYzZjNDc3ZjU1ZDZmZTljZGNmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBNaWNoZWwgU3RhbSA8bS5zdGFtQGZ1Z3JvLm5sPgpEYXRlOiBU
dWUsIDIzIFNlcCAyMDE0IDE3OjIwOjIzICswMjAwClN1YmplY3Q6IFtQQVRDSF0gRG9uJ3QgcmVz
ZXQgUEhZIG9uIGlmX3VwIGZvciBBU0lYIDg4NzcyCgpJJ3ZlIG5vdGljZWQgZXZlcnkgdGltZSB0
aGUgaW50ZXJmYWNlIGlzIHNldCB0byAndXAsJywgdGhlIGtlcm5lbApyZXBvcnRzIHRoYXQgdGhl
IGxpbmsgc3BlZWQgaXMgc2V0IHRvIDEwMCBNYnBzL0Z1bGwgRHVwbGV4LCBldmVuCndoZW4gZXRo
dG9vbCBpcyB1c2VkIHRvIHNldCBhdXRvbmVnb3RpYXRpb24gdG8gJ29mZicsIGhhbGYKZHVwbGV4
LCAxMCBNYnBzLgpJdCBjYW4gYmUgdGVzdGVkIGJ5OgogaWZjb25maWcgZXRoMCBkb3duCiBldGh0
b29sIC1zIGV0aDAgYXV0b25lZyBvZmYgc3BlZWQgMTAgZHVwbGV4IGhhbGYKIGlmY29uZmlnIGV0
aDAgdXAKClRoZW4gY2hlY2tpbmcgJ2RtZXNnJyBmb3IgdGhlIGxpbmsgc3BlZWQuCgpTaWduZWQt
b2ZmLWJ5OiBNaWNoZWwgU3RhbSA8bS5zdGFtQGZ1Z3JvLm5sPgotLS0KIGRyaXZlcnMvbmV0L3Vz
Yi9hc2l4X2RldmljZXMuYyB8IDIgKy0KIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwg
MSBkZWxldGlvbigtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3VzYi9hc2l4X2RldmljZXMu
YyBiL2RyaXZlcnMvbmV0L3VzYi9hc2l4X2RldmljZXMuYwppbmRleCA1ZDE5NDA5Li4yYzA1ZjZj
IDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC91c2IvYXNpeF9kZXZpY2VzLmMKKysrIGIvZHJpdmVy
cy9uZXQvdXNiL2FzaXhfZGV2aWNlcy5jCkBAIC04OTAsNyArODkwLDcgQEAgc3RhdGljIGNvbnN0
IHN0cnVjdCBkcml2ZXJfaW5mbyBheDg4NzcyX2luZm8gPSB7CiAJLnVuYmluZCA9IGF4ODg3NzJf
dW5iaW5kLAogCS5zdGF0dXMgPSBhc2l4X3N0YXR1cywKIAkubGlua19yZXNldCA9IGF4ODg3NzJf
bGlua19yZXNldCwKLQkucmVzZXQgPSBheDg4NzcyX3Jlc2V0LAorCS5yZXNldCA9IGF4ODg3NzJf
bGlua19yZXNldCwKIAkuZmxhZ3MgPSBGTEFHX0VUSEVSIHwgRkxBR19GUkFNSU5HX0FYIHwgRkxB
R19MSU5LX0lOVFIgfCBGTEFHX01VTFRJX1BBQ0tFVCwKIAkucnhfZml4dXAgPSBhc2l4X3J4X2Zp
eHVwX2NvbW1vbiwKIAkudHhfZml4dXAgPSBhc2l4X3R4X2ZpeHVwLAotLSAKMS43LjEyLjEKCg==

------_=_NextPart_001_01CFDBEB.B2162D08--
