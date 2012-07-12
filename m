From: <Narendra_K@Dell.com>
Subject: [PATCH] ixgbevf - Prevent RX/TX statistics getting reset to zero
Date: Thu, 12 Jul 2012 06:55:21 -0700
Message-ID: <E31FB011129F30488D5861F38390491520D00B9F01@BLRX7MCDC201.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_E31FB011129F30488D5861F38390491520D00B9F01BLRX7MCDC201A_"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:47235 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932387Ab2GLN4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 09:56:37 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_E31FB011129F30488D5861F38390491520D00B9F01BLRX7MCDC201A_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello,

[Apologies if you are receiving this message twice. I am resending the mess=
age, as I got message delivery failure note].

While exploring SR-IOV on Intel 82599EB 10-Gigabit SFP+ adapter, I had the =
following observation.  I enabled two VFs by passing 'max_vfs=3D2' to ixgbe=
 driver. One of the VFs was assigned to a guest.
In the guest, the ifconfig and ip tools reported 'RX packets' and 'TX packe=
ts' as zero, after pinging to a remote host. Looking into it further, the c=
ommit 4197aa7bb81877ebb06e4f2cc1b5fea2da23a7bd implements 64 bit per ring s=
tatistics. It seemed like the 'total_bytes' and 'total_packets' of RX and T=
X ring were being reset to zero by the RX and TX interrupt handlers, result=
ing in the user space tools reporting zero RX and TX bytes.=20

The attached patch addresses the issue by preventing the resetting of RX an=
d TX ring statistics to zero. The patch was taken against latest mainline 3=
.5-rc6 kernel.

I tested the patch by pinging  from the guest OS to a remote host.

ping -f <remote host> -c 10000

The ip and ifcofig showed the statistics increased by 10000 packets. =20

# lspci | grep 82599
04:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFP+ Netw=
ork Connection (rev 01)
04:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFP+ Netw=
ork Connection (rev 01)
04:10.0 Ethernet controller: Intel Corporation 82599 Ethernet Controller Vi=
rtual Function (rev 01)
04:10.1 Ethernet controller: Intel Corporation 82599 Ethernet Controller Vi=
rtual Function (rev 01)
04:10.2 Ethernet controller: Intel Corporation 82599 Ethernet Controller Vi=
rtual Function (rev 01)
04:10.3 Ethernet controller: Intel Corporation 82599 Ethernet Controller Vi=
rtual Function (rev 01)

# lspci -s 04:00.0 -n
04:00.0 0200: 8086:154d (rev 01)
# lspci -s 04:10.0 -n
04:10.0 0200: 8086:10ed (rev 01)=20

Please let me know if additional details and logs are required.=20

With regards,
Narendra K




--_002_E31FB011129F30488D5861F38390491520D00B9F01BLRX7MCDC201A_
Content-Type: application/octet-stream;
	name="0001-ixgbevf-Prevent-RX-TX-statistics-getting-reset-to-ze.patch"
Content-Description: 0001-ixgbevf-Prevent-RX-TX-statistics-getting-reset-to-ze.patch
Content-Disposition: attachment;
	filename="0001-ixgbevf-Prevent-RX-TX-statistics-getting-reset-to-ze.patch";
	size=2033; creation-date="Thu, 12 Jul 2012 13:08:19 GMT";
	modification-date="Thu, 12 Jul 2012 13:05:41 GMT"
Content-Transfer-Encoding: base64

RnJvbSAzN2IzYzJkMWI3YTFmNWQ0NTU2NmIyMmZiYWEwMzhiM2U1ZWQzMjE4IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBOYXJlbmRyYSBLIDxuYXJlbmRyYV9rQGRlbGwuY29tPgpEYXRl
OiBUaHUsIDEyIEp1bCAyMDEyIDE4OjIwOjU1ICswNTMwClN1YmplY3Q6IFtQQVRDSF0gaXhnYmV2
ZiAtIFByZXZlbnQgUlgvVFggc3RhdGlzdGljcyBnZXR0aW5nIHJlc2V0IHRvIHplcm8KClRoZSBj
b21taXQgNDE5N2FhN2JiODE4NzdlYmIwNmU0ZjJjYzFiNWZlYTJkYTIzYTdiZCBpbXBsZW1lbnRz
IDY0IGJpdApwZXIgcmluZyBzdGF0aXN0aWNzLiBCdXQgdGhlIGRyaXZlciByZXNldHMgdGhlICd0
b3RhbF9ieXRlcycgYW5kCid0b3RhbF9wYWNrZXRzJyBmcm9tIFJYIGFuZCBUWCByaW5ncyBpbiB0
aGUgUlggYW5kIFRYIGludGVycnVwdApoYW5kbGVycyB0byB6ZXJvLiBUaGlzIHJlc3VsdHMgaW4g
c3RhdGlzdGljcyBiZWluZyBsb3N0IGFuZCB1c2VyIHNwYWNlCnJlcG9ydGluZyBSWCBhbmQgVFgg
c3RhdGlzdGljcyBhcyB6ZXJvLiBUaGlzIHBhdGNoIGFkZHJlc3NlcyB0aGUKaXNzdWUgYnkgcHJl
dmVudGluZyB0aGUgcmVzZXR0aW5nIG9mIFJYIGFuZCBUWCByaW5nIHN0YXRpc3RpY3MgdG8KemVy
by4KClNpZ25lZC1vZmYtYnk6IE5hcmVuZHJhIEsgPG5hcmVuZHJhX2tAZGVsbC5jb20+Ci0tLQog
ZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmV2Zi9peGdiZXZmX21haW4uYyB8ICAgMTIg
LS0tLS0tLS0tLS0tCiAxIGZpbGUgY2hhbmdlZCwgMTIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0
IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmV2Zi9peGdiZXZmX21haW4uYyBiL2Ry
aXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JldmYvaXhnYmV2Zl9tYWluLmMKaW5kZXggZjY5
ZWM0Mi4uOGIzMDRhNCAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhn
YmV2Zi9peGdiZXZmX21haW4uYworKysgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9peGdi
ZXZmL2l4Z2JldmZfbWFpbi5jCkBAIC05NjksOCArOTY5LDYgQEAgc3RhdGljIGlycXJldHVybl90
IGl4Z2JldmZfbXNpeF9jbGVhbl90eChpbnQgaXJxLCB2b2lkICpkYXRhKQogCXJfaWR4ID0gZmlu
ZF9maXJzdF9iaXQocV92ZWN0b3ItPnR4cl9pZHgsIGFkYXB0ZXItPm51bV90eF9xdWV1ZXMpOwog
CWZvciAoaSA9IDA7IGkgPCBxX3ZlY3Rvci0+dHhyX2NvdW50OyBpKyspIHsKIAkJdHhfcmluZyA9
ICYoYWRhcHRlci0+dHhfcmluZ1tyX2lkeF0pOwotCQl0eF9yaW5nLT50b3RhbF9ieXRlcyA9IDA7
Ci0JCXR4X3JpbmctPnRvdGFsX3BhY2tldHMgPSAwOwogCQlpeGdiZXZmX2NsZWFuX3R4X2lycShh
ZGFwdGVyLCB0eF9yaW5nKTsKIAkJcl9pZHggPSBmaW5kX25leHRfYml0KHFfdmVjdG9yLT50eHJf
aWR4LCBhZGFwdGVyLT5udW1fdHhfcXVldWVzLAogCQkJCSAgICAgIHJfaWR4ICsgMSk7CkBAIC05
OTQsMTYgKzk5Miw2IEBAIHN0YXRpYyBpcnFyZXR1cm5fdCBpeGdiZXZmX21zaXhfY2xlYW5fcngo
aW50IGlycSwgdm9pZCAqZGF0YSkKIAlzdHJ1Y3QgaXhnYmVfaHcgKmh3ID0gJmFkYXB0ZXItPmh3
OwogCXN0cnVjdCBpeGdiZXZmX3JpbmcgICpyeF9yaW5nOwogCWludCByX2lkeDsKLQlpbnQgaTsK
LQotCXJfaWR4ID0gZmluZF9maXJzdF9iaXQocV92ZWN0b3ItPnJ4cl9pZHgsIGFkYXB0ZXItPm51
bV9yeF9xdWV1ZXMpOwotCWZvciAoaSA9IDA7IGkgPCBxX3ZlY3Rvci0+cnhyX2NvdW50OyBpKysp
IHsKLQkJcnhfcmluZyA9ICYoYWRhcHRlci0+cnhfcmluZ1tyX2lkeF0pOwotCQlyeF9yaW5nLT50
b3RhbF9ieXRlcyA9IDA7Ci0JCXJ4X3JpbmctPnRvdGFsX3BhY2tldHMgPSAwOwotCQlyX2lkeCA9
IGZpbmRfbmV4dF9iaXQocV92ZWN0b3ItPnJ4cl9pZHgsIGFkYXB0ZXItPm51bV9yeF9xdWV1ZXMs
Ci0JCQkJICAgICAgcl9pZHggKyAxKTsKLQl9CiAKIAlpZiAoIXFfdmVjdG9yLT5yeHJfY291bnQp
CiAJCXJldHVybiBJUlFfSEFORExFRDsKLS0gCjEuNy4xMC4xCgo=

--_002_E31FB011129F30488D5861F38390491520D00B9F01BLRX7MCDC201A_--
