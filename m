From: Cong Wang <cwang@twopensource.com>
Subject: Re: Fw: [Bug 70071] New: Sending netconsole messages over a bridged
 network interface doesn't work anymore
Date: Wed, 5 Feb 2014 22:49:13 -0800
Message-ID: <CAHA+R7Ork+gER_v=YhQCSDO9N=aokXiSiMUWwD3aMSv2YaZJ4g@mail.gmail.com>
References: <20140205141539.450095fa@samsung-9>
	<52F30863.7000206@lab.ntt.co.jp>
	<CAHA+R7Pf1q7+xyqpwmGPToa0fTGn6dmukLvyncWwYAP-F_JvLg@mail.gmail.com>
	<52F3214C.4060308@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11c373ec7782b104f1b74570
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:50216 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbaBFGtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 01:49:14 -0500
Received: by mail-lb0-f179.google.com with SMTP id l4so1131777lbv.10
        for <netdev@vger.kernel.org>; Wed, 05 Feb 2014 22:49:13 -0800 (PST)
In-Reply-To: <52F3214C.4060308@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a11c373ec7782b104f1b74570
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Feb 5, 2014 at 9:44 PM, Toshiaki Makita
<makita.toshiaki@lab.ntt.co.jp> wrote:
> Tested this patch with latest net-tree and netconsole works with it.
> But I thinks it is better to move that "if" to br_add_if() because if we
> don't have npinfo, we don't have to alloc p->np in br_add_if(), right?
>

Hmm, we shouldn't handle netpoll-specific code inside br_add_if(),
we probably need the attached patch instead. Please give it
a try, or I will test it tomorrow, it's too late here.

Thanks!

--001a11c373ec7782b104f1b74570
Content-Type: text/plain; charset=US-ASCII; name="br.diff"
Content-Disposition: attachment; filename="br.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hrbnz1c80

ZGlmZiAtLWdpdCBhL25ldC9icmlkZ2UvYnJfZGV2aWNlLmMgYi9uZXQvYnJpZGdlL2JyX2Rldmlj
ZS5jCmluZGV4IGU0NDAxYTUuLmQ5YTliMGYgMTAwNjQ0Ci0tLSBhL25ldC9icmlkZ2UvYnJfZGV2
aWNlLmMKKysrIGIvbmV0L2JyaWRnZS9icl9kZXZpY2UuYwpAQCAtMjI2LDYgKzIyNiwzMyBAQCBz
dGF0aWMgdm9pZCBicl9uZXRwb2xsX2NsZWFudXAoc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIAkJ
YnJfbmV0cG9sbF9kaXNhYmxlKHApOwogfQogCitzdGF0aWMgaW50IF9fYnJfbmV0cG9sbF9lbmFi
bGUoc3RydWN0IG5ldF9icmlkZ2VfcG9ydCAqcCwgZ2ZwX3QgZ2ZwKQoreworCXN0cnVjdCBuZXRw
b2xsICpucDsKKwlpbnQgZXJyOworCisJbnAgPSBremFsbG9jKHNpemVvZigqcC0+bnApLCBnZnAp
OworCWlmICghbnApCisJCXJldHVybiAtRU5PTUVNOworCisJZXJyID0gX19uZXRwb2xsX3NldHVw
KG5wLCBwLT5kZXYsIGdmcCk7CisJaWYgKGVycikgeworCQlrZnJlZShucCk7CisJCXJldHVybiBl
cnI7CisJfQorCisJcC0+bnAgPSBucDsKKwlyZXR1cm4gZXJyOworfQorCitpbnQgYnJfbmV0cG9s
bF9lbmFibGUoc3RydWN0IG5ldF9icmlkZ2VfcG9ydCAqcCwgZ2ZwX3QgZ2ZwKQoreworCWlmICgh
cC0+YnItPmRldi0+bnBpbmZvKQorCQlyZXR1cm4gMDsKKworCXJldHVybiBfX2JyX25ldHBvbGxf
ZW5hYmxlKHAsIGdmcCk7Cit9CisKIHN0YXRpYyBpbnQgYnJfbmV0cG9sbF9zZXR1cChzdHJ1Y3Qg
bmV0X2RldmljZSAqZGV2LCBzdHJ1Y3QgbmV0cG9sbF9pbmZvICpuaSwKIAkJCSAgICBnZnBfdCBn
ZnApCiB7CkBAIC0yMzYsNyArMjYzLDcgQEAgc3RhdGljIGludCBicl9uZXRwb2xsX3NldHVwKHN0
cnVjdCBuZXRfZGV2aWNlICpkZXYsIHN0cnVjdCBuZXRwb2xsX2luZm8gKm5pLAogCWxpc3RfZm9y
X2VhY2hfZW50cnkocCwgJmJyLT5wb3J0X2xpc3QsIGxpc3QpIHsKIAkJaWYgKCFwLT5kZXYpCiAJ
CQljb250aW51ZTsKLQkJZXJyID0gYnJfbmV0cG9sbF9lbmFibGUocCwgZ2ZwKTsKKwkJZXJyID0g
X19icl9uZXRwb2xsX2VuYWJsZShwLCBnZnApOwogCQlpZiAoZXJyKQogCQkJZ290byBmYWlsOwog
CX0KQEAgLTI0OSwyOCArMjc2LDYgQEAgZmFpbDoKIAlnb3RvIG91dDsKIH0KIAotaW50IGJyX25l
dHBvbGxfZW5hYmxlKHN0cnVjdCBuZXRfYnJpZGdlX3BvcnQgKnAsIGdmcF90IGdmcCkKLXsKLQlz
dHJ1Y3QgbmV0cG9sbCAqbnA7Ci0JaW50IGVycjsKLQotCWlmICghcC0+YnItPmRldi0+bnBpbmZv
KQotCQlyZXR1cm4gMDsKLQotCW5wID0ga3phbGxvYyhzaXplb2YoKnAtPm5wKSwgZ2ZwKTsKLQlp
ZiAoIW5wKQotCQlyZXR1cm4gLUVOT01FTTsKLQotCWVyciA9IF9fbmV0cG9sbF9zZXR1cChucCwg
cC0+ZGV2LCBnZnApOwotCWlmIChlcnIpIHsKLQkJa2ZyZWUobnApOwotCQlyZXR1cm4gZXJyOwot
CX0KLQotCXAtPm5wID0gbnA7Ci0JcmV0dXJuIGVycjsKLX0KLQogdm9pZCBicl9uZXRwb2xsX2Rp
c2FibGUoc3RydWN0IG5ldF9icmlkZ2VfcG9ydCAqcCkKIHsKIAlzdHJ1Y3QgbmV0cG9sbCAqbnAg
PSBwLT5ucDsK
--001a11c373ec7782b104f1b74570--
