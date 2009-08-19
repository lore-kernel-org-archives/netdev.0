From: Mike McCormack <mikem@ring3k.org>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Thu, 20 Aug 2009 00:00:31 +0900
Message-ID: <392fb48f0908190800j508456d6h9c520e82bc7f51e0@mail.gmail.com>
References: <4A65EC3F.4050400@gibraltar.at> <4A7FF66A.1090506@mayrhofer.eu.org>
	 <4A8131DD.7010700@mayrhofer.eu.org>
	 <200908190902.02854.rene.mayrhofer@gibraltar.at>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001485e60a0d74030504717fe5ef
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:57145 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbZHSPAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 11:00:30 -0400
Received: by fg-out-1718.google.com with SMTP id e12so811434fga.17
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 08:00:31 -0700 (PDT)
In-Reply-To: <200908190902.02854.rene.mayrhofer@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001485e60a0d74030504717fe5ef
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

2009/8/19 Rene Mayrhofer <rene.mayrhofer@gibraltar.at>:
> Hi everybody,
>
> On Tuesday 11 August 2009 10:54:53 am Rene Mayrhofer wrote:
>> Thus, there really seems to be an uncaught case in sky2.c. When
>> sky2_phy_power_down is not called, chip should not go down, right? But
>> still sky2_poll seems to be called (maybe by an interrupt belonging to
>> another network interface but the same chip)?
>
> Is there anything else I could try? We still have this issue, making one range
> of hardware appliances unusable with 2.6 kernels...

Hi Rene,

There's a couple of things to try:

* try the latest sky2 code from net-next-2.6
* try adding an msleep(1) after sky2_rx_stop() in sky2_down()
* try adding a check for rx_ring and tx_ring being NULL in
sky2_status_intr(), and disable napi while freeing the buffers in
sky2_down()

I've got an untested, ad-hoc patch against net-next-2.6 for the last
two bits ...

thanks,

Mike

--001485e60a0d74030504717fe5ef
Content-Type: text/x-patch; charset=US-ASCII; name="sky2-bandaids.diff"
Content-Disposition: attachment; filename="sky2-bandaids.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fyk6kdjy1

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3NreTIuYyBiL2RyaXZlcnMvbmV0L3NreTIuYwppbmRl
eCA4YTc2M2Y4Li5hNGMyNzc4IDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9za3kyLmMKKysrIGIv
ZHJpdmVycy9uZXQvc2t5Mi5jCkBAIC0xODc0LDYgKzE4NzQsOCBAQCBzdGF0aWMgaW50IHNreTJf
ZG93bihzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQogCiAJc2t5Ml9yeF9zdG9wKHNreTIpOwogCisJ
bXNsZWVwKDEpOworCiAJLyogRGlzYWJsZSBwb3J0IElSUSAqLwogCWltYXNrID0gc2t5Ml9yZWFk
MzIoaHcsIEIwX0lNU0spOwogCWltYXNrICY9IH5wb3J0aXJxX21za1twb3J0XTsKQEAgLTE4ODEs
NyArMTg4Myw3IEBAIHN0YXRpYyBpbnQgc2t5Ml9kb3duKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYp
CiAJc2t5Ml9yZWFkMzIoaHcsIEIwX0lNU0spOwogCiAJc3luY2hyb25pemVfaXJxKGh3LT5wZGV2
LT5pcnEpOwotCW5hcGlfc3luY2hyb25pemUoJmh3LT5uYXBpKTsKKwluYXBpX2Rpc2FibGUoJmh3
LT5uYXBpKTsKIAogCXNwaW5fbG9ja19iaCgmc2t5Mi0+cGh5X2xvY2spOwogCXNreTJfcGh5X3Bv
d2VyX2Rvd24oaHcsIHBvcnQpOwpAQCAtMTkxMiw2ICsxOTE0LDggQEAgc3RhdGljIGludCBza3ky
X2Rvd24oc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIAlza3kyLT5yeF9yaW5nID0gTlVMTDsKIAlz
a3kyLT50eF9yaW5nID0gTlVMTDsKIAorCW5hcGlfZW5hYmxlKCZody0+bmFwaSk7CisKIAlyZXR1
cm4gMDsKIH0KIApAQCAtMjM3MSw3ICsyMzc1LDcgQEAgc3RhdGljIGlubGluZSB2b2lkIHNreTJf
dHhfZG9uZShzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCB1MTYgbGFzdCkKIHsKIAlzdHJ1Y3Qgc2t5
Ml9wb3J0ICpza3kyID0gbmV0ZGV2X3ByaXYoZGV2KTsKIAotCWlmIChuZXRpZl9ydW5uaW5nKGRl
dikpCisJaWYgKGxpa2VseShuZXRpZl9ydW5uaW5nKGRldikgJiYgc2t5Mi0+dHhfcmluZykpCiAJ
CXNreTJfdHhfY29tcGxldGUoc2t5MiwgbGFzdCk7CiB9CiAKQEAgLTI0MzcsNiArMjQ0MSwxMiBA
QCBzdGF0aWMgaW50IHNreTJfc3RhdHVzX2ludHIoc3RydWN0IHNreTJfaHcgKmh3LCBpbnQgdG9f
ZG8sIHUxNiBpZHgpCiAJCWxlbmd0aCA9IGxlMTZfdG9fY3B1KGxlLT5sZW5ndGgpOwogCQlzdGF0
dXMgPSBsZTMyX3RvX2NwdShsZS0+c3RhdHVzKTsKIAorCQlpZiAodW5saWtlbHkoIXNreTItPnJ4
X3JpbmcpKSB7CisJCQlwcmludGsoS0VSTl9JTkZPIFBGWCAiJXM6IHJ4IHJpbmcgTlVMTCAlMDh4
XG4iLAorCQkJICAgICAgIGRldi0+bmFtZSwgb3Bjb2RlKTsKKwkJCWNvbnRpbnVlOworCQl9CisK
IAkJbGUtPm9wY29kZSA9IDA7CiAJCXN3aXRjaCAob3Bjb2RlICYgfkhXX09XTkVSKSB7CiAJCWNh
c2UgT1BfUlhTVEFUOgo=
--001485e60a0d74030504717fe5ef--
