From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: 3.14-mw regression: rtl8169 WARNING: DMA-API: exceeded 7
 overlapping mappings of pfn 55ebe
Date: Thu, 6 Feb 2014 11:12:15 -0800
Message-ID: <CAPcyv4j44ZHmaqUBj3rXv-C7Hr72Z15g=2nFBD=1iYLnhSQQ4g@mail.gmail.com>
References: <1859471893.20140126115521@eikelenboom.it>
	<20140127000305.GA14236@electric-eye.fr.zoreil.com>
	<CAA9_cme2hgJ=jCDkPh5n5RP8fiJE-dVwbFr-apKv1=mNGPHYZg@mail.gmail.com>
	<84816226.20140206123631@eikelenboom.it>
	<942972114.20140206140909@eikelenboom.it>
	<CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com>
	<932118392.20140206152722@eikelenboom.it>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7bd6bb56c944d104f1c1a648
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:61282 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbaBFTMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 14:12:17 -0500
Received: by mail-ve0-f177.google.com with SMTP id jz11so1838533veb.8
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 11:12:16 -0800 (PST)
In-Reply-To: <932118392.20140206152722@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7bd6bb56c944d104f1c1a648
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Feb 6, 2014 at 6:27 AM, Sander Eikelenboom <linux@eikelenboom.it> wrote:
>>>> Not using it seems to prevent the warning, but before 3.14 i have never seen this (with r8169.use_dac=1)
>
>> If you are still hitting this with the patch:
>
>>   59f2e7df574c dma-debug: fix overlap detection
>
>> ...then I'm more inclined to think it is an actual positive report.
>
>> If you don't mind I'll send some debug patches to narrow this down.
>
> Please do .. sounds better than bisecting :-)
>

Hi, attached is a patch that should give some insight whether the
driver is triggering many overlapping mappings.  Try it on top of
3.14-rc1.

Thank you for the debug help!

--047d7bd6bb56c944d104f1c1a648
Content-Type: application/octet-stream; name=debug-overlap
Content-Disposition: attachment; filename=debug-overlap
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hrcefdvf0

ZGVidWcgb3ZlcmxhcCBvdmVyZmxvdwoKRnJvbTogRGFuIFdpbGxpYW1zIDxkYW4uai53aWxsaWFt
c0BpbnRlbC5jb20+CgoKLS0tCiBkcml2ZXJzL25ldC9ldGhlcm5ldC9yZWFsdGVrL3I4MTY5LmMg
fCAgICA2ICsrKysrKwogbGliL2RtYS1kZWJ1Zy5jICAgICAgICAgICAgICAgICAgICAgIHwgICAg
NyArKysrLS0tCiAyIGZpbGVzIGNoYW5nZWQsIDEwIGluc2VydGlvbnMoKyksIDMgZGVsZXRpb25z
KC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvcmVhbHRlay9yODE2OS5jIGIv
ZHJpdmVycy9uZXQvZXRoZXJuZXQvcmVhbHRlay9yODE2OS5jCmluZGV4IDkxYTY3YWU4ZjE3Yi4u
M2JiMmMxZTAwMGJlIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9yZWFsdGVrL3I4
MTY5LmMKKysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvcmVhbHRlay9yODE2OS5jCkBAIC01ODA5
LDYgKzU4MDksOSBAQCBzdGF0aWMgdm9pZCBydGw4MTY5X3VubWFwX3R4X3NrYihzdHJ1Y3QgZGV2
aWNlICpkLCBzdHJ1Y3QgcmluZ19pbmZvICp0eF9za2IsCiB7CiAJdW5zaWduZWQgaW50IGxlbiA9
IHR4X3NrYi0+bGVuOwogCisJdHJhY2VfcHJpbnRrKCIlcyAlczogdW5tYXAgYWRkcjogJSNsbHgg
bGVuOiAldVxuIiwKKwkJICAgICBkZXZfZHJpdmVyX3N0cmluZyhkKSwgZGV2X25hbWUoZCksCisJ
CSAgICAgKHVuc2lnbmVkIGxvbmcgbG9uZykgbGU2NF90b19jcHUoZGVzYy0+YWRkciksIGxlbik7
CiAJZG1hX3VubWFwX3NpbmdsZShkLCBsZTY0X3RvX2NwdShkZXNjLT5hZGRyKSwgbGVuLCBETUFf
VE9fREVWSUNFKTsKIAogCWRlc2MtPm9wdHMxID0gMHgwMDsKQEAgLTU5OTksNiArNjAwMiw5IEBA
IHN0YXRpYyBuZXRkZXZfdHhfdCBydGw4MTY5X3N0YXJ0X3htaXQoc3RydWN0IHNrX2J1ZmYgKnNr
YiwKIAogCWxlbiA9IHNrYl9oZWFkbGVuKHNrYik7CiAJbWFwcGluZyA9IGRtYV9tYXBfc2luZ2xl
KGQsIHNrYi0+ZGF0YSwgbGVuLCBETUFfVE9fREVWSUNFKTsKKwl0cmFjZV9wcmludGsoIiVzICVz
OiBtYXAgYWRkcjogJXAgZG1hOiAlI2xseCBsZW46ICVkXG4iLAorCQkgICAgIGRldl9kcml2ZXJf
c3RyaW5nKGQpLCBkZXZfbmFtZShkKSwKKwkJICAgICBza2ItPmRhdGEsICh1bnNpZ25lZCBsb25n
IGxvbmcpIG1hcHBpbmcsIGxlbik7CiAJaWYgKHVubGlrZWx5KGRtYV9tYXBwaW5nX2Vycm9yKGQs
IG1hcHBpbmcpKSkgewogCQlpZiAobmV0X3JhdGVsaW1pdCgpKQogCQkJbmV0aWZfZXJyKHRwLCBk
cnYsIGRldiwgIkZhaWxlZCB0byBtYXAgVFggRE1BIVxuIik7CmRpZmYgLS1naXQgYS9saWIvZG1h
LWRlYnVnLmMgYi9saWIvZG1hLWRlYnVnLmMKaW5kZXggMmRlZmQxMzA4YjA0Li43YjIyYzhmNTky
OGUgMTAwNjQ0Ci0tLSBhL2xpYi9kbWEtZGVidWcuYworKysgYi9saWIvZG1hLWRlYnVnLmMKQEAg
LTQ4Niw5ICs0ODYsMTAgQEAgc3RhdGljIHZvaWQgYWN0aXZlX3Bmbl9pbmNfb3ZlcmxhcCh1bnNp
Z25lZCBsb25nIHBmbikKIAkgKiBkZWJ1Z19kbWFfYXNzZXJ0X2lkbGUoKSBhcyB0aGUgcGZuIG1h
eSBiZSBtYXJrZWQgaWRsZQogCSAqIHByZW1hdHVyZWx5LgogCSAqLwotCVdBUk5fT05DRShvdmVy
bGFwID4gQUNUSVZFX1BGTl9NQVhfT1ZFUkxBUCwKLQkJICAiRE1BLUFQSTogZXhjZWVkZWQgJWQg
b3ZlcmxhcHBpbmcgbWFwcGluZ3Mgb2YgcGZuICVseFxuIiwKLQkJICBBQ1RJVkVfUEZOX01BWF9P
VkVSTEFQLCBwZm4pOworCWlmIChXQVJOX09OQ0Uob3ZlcmxhcCA+IEFDVElWRV9QRk5fTUFYX09W
RVJMQVAsCisJCSAgICAgICJETUEtQVBJOiBleGNlZWRlZCAlZCBvdmVybGFwcGluZyBtYXBwaW5n
cyBvZiBwZm4gJWx4XG4iLAorCQkgICAgICBBQ1RJVkVfUEZOX01BWF9PVkVSTEFQLCBwZm4pKQor
CQlmdHJhY2VfZHVtcChEVU1QX0FMTCk7CiB9CiAKIHN0YXRpYyBpbnQgYWN0aXZlX3Bmbl9kZWNf
b3ZlcmxhcCh1bnNpZ25lZCBsb25nIHBmbikK
--047d7bd6bb56c944d104f1c1a648--
