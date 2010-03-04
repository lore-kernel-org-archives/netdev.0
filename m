From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] Re: [PATCH v4] ethtool: Add direct access to ops->get_sset_count
Date: Thu, 04 Mar 2010 13:21:53 -0500
Message-ID: <4B8FFA41.2020700@garzik.org>
References: <20100304085054.4471.44679.stgit@localhost.localdomain> <1267712797.2819.149.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060606080704070002030604"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41999 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018Ab0CDSV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 13:21:56 -0500
Received: by vws9 with SMTP id 9so1401350vws.19
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 10:21:55 -0800 (PST)
In-Reply-To: <1267712797.2819.149.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060606080704070002030604
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 03/04/2010 09:26 AM, Ben Hutchings wrote:
> On Thu, 2010-03-04 at 00:51 -0800, Jeff Kirsher wrote:
>> From: Jeff Garzik<jgarzik@redhat.com>
>>
>> This patch is an alternative approach for accessing string
>> counts, vs. the drvinfo indirect approach.  This way the drvinfo
>> space doesn't run out, and we don't break ABI later.
> [...]
>> --- a/net/core/ethtool.c
>> +++ b/net/core/ethtool.c
>> @@ -214,6 +214,10 @@ static noinline int ethtool_get_drvinfo(struct net_device *dev, void __user *use
>>   	info.cmd = ETHTOOL_GDRVINFO;
>>   	ops->get_drvinfo(dev,&info);
>>
>> +	/*
>> +	 * this method of obtaining string set info is deprecated;
>> +	 * consider using ETHTOOL_GSSET_INFO instead
>> +	 */
>
> This comment belongs on the interface (ethtool.h) not the
> implementation.

Debatable -- the current comment is located at the callsite of 
ops->get_sset_count(), which is where an implementor might think to add 
a new call.  Not all the numeric fields in ethtool_drvinfo are obtained 
from ->get_sset_count().

Hence the "some" in the attached patch to include/linux/ethtool.h, 
addressing your comment.


> [...]
>> +static noinline int ethtool_get_sset_info(struct net_device *dev,
>> +                                          void __user *useraddr)
>> +{
> [...]
>> +	/* calculate size of return buffer */
>> +	for (i = 0; i<  64; i++)
>> +		if (sset_mask&  (1ULL<<  i))
>> +			n_bits++;
> [...]
>
> We have a function for this:
>
> 	n_bits = hweight64(sset_mask);

Agreed.

I've attached a follow-up patch, which should enable my/Jeff's kernel 
patch to be applied, followed by this one.

	Jeff




--------------060606080704070002030604
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="patch"

ClNpZ25lZC1vZmYtYnk6IEplZmYgR2FyemlrIDxqZ2FyemlrQHJlZGhhdC5jb20+Ci0tLQog
aW5jbHVkZS9saW51eC9ldGh0b29sLmggfCAgICA3ICsrKysrKysKIG5ldC9jb3JlL2V0aHRv
b2wuYyAgICAgIHwgICAgNyArKystLS0tCiAyIGZpbGVzIGNoYW5nZWQsIDEwIGluc2VydGlv
bnMoKyksIDQgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9ldGh0
b29sLmggYi9pbmNsdWRlL2xpbnV4L2V0aHRvb2wuaAppbmRleCBmNmY5NjFmLi5iMzNmMzE2
IDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L2V0aHRvb2wuaAorKysgYi9pbmNsdWRlL2xp
bnV4L2V0aHRvb2wuaApAQCAtNjEsNiArNjEsMTMgQEAgc3RydWN0IGV0aHRvb2xfZHJ2aW5m
byB7CiAJCQkJLyogRm9yIFBDSSBkZXZpY2VzLCB1c2UgcGNpX25hbWUocGNpX2RldikuICov
CiAJY2hhcglyZXNlcnZlZDFbMzJdOwogCWNoYXIJcmVzZXJ2ZWQyWzEyXTsKKwkJCQkvKgor
CQkJCSAqIFNvbWUgc3RydWN0IG1lbWJlcnMgYmVsb3cgYXJlIGZpbGxlZCBpbgorCQkJCSAq
IHVzaW5nIG9wcy0+Z2V0X3NzZXRfY291bnQoKS4gIE9idGFpbmluZworCQkJCSAqIHRoaXMg
aW5mbyBmcm9tIGV0aHRvb2xfZHJ2aW5mbyBpcyBub3cKKwkJCQkgKiBkZXByZWNhdGVkOyBV
c2UgRVRIVE9PTF9HU1NFVF9JTkZPCisJCQkJICogaW5zdGVhZC4KKwkJCQkgKi8KIAlfX3Uz
MgluX3ByaXZfZmxhZ3M7CS8qIG51bWJlciBvZiBmbGFncyB2YWxpZCBpbiBFVEhUT09MX0dQ
RkxBR1MgKi8KIAlfX3UzMgluX3N0YXRzOwkvKiBudW1iZXIgb2YgdTY0J3MgZnJvbSBFVEhU
T09MX0dTVEFUUyAqLwogCV9fdTMyCXRlc3RpbmZvX2xlbjsKZGlmZiAtLWdpdCBhL25ldC9j
b3JlL2V0aHRvb2wuYyBiL25ldC9jb3JlL2V0aHRvb2wuYwppbmRleCA3MDA3NWM0Li4zM2Qy
ZGVkIDEwMDY0NAotLS0gYS9uZXQvY29yZS9ldGh0b29sLmMKKysrIGIvbmV0L2NvcmUvZXRo
dG9vbC5jCkBAIC0xNyw2ICsxNyw3IEBACiAjaW5jbHVkZSA8bGludXgvZXJybm8uaD4KICNp
bmNsdWRlIDxsaW51eC9ldGh0b29sLmg+CiAjaW5jbHVkZSA8bGludXgvbmV0ZGV2aWNlLmg+
CisjaW5jbHVkZSA8bGludXgvYml0b3BzLmg+CiAjaW5jbHVkZSA8YXNtL3VhY2Nlc3MuaD4K
IAogLyoKQEAgLTIxNiw3ICsyMTcsNyBAQCBzdGF0aWMgbm9pbmxpbmUgaW50IGV0aHRvb2xf
Z2V0X2RydmluZm8oc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgdm9pZCBfX3VzZXIgKnVzZQog
CiAJLyoKIAkgKiB0aGlzIG1ldGhvZCBvZiBvYnRhaW5pbmcgc3RyaW5nIHNldCBpbmZvIGlz
IGRlcHJlY2F0ZWQ7Ci0JICogY29uc2lkZXIgdXNpbmcgRVRIVE9PTF9HU1NFVF9JTkZPIGlu
c3RlYWQKKwkgKiBVc2UgRVRIVE9PTF9HU1NFVF9JTkZPIGluc3RlYWQuCiAJICovCiAJaWYg
KG9wcy0+Z2V0X3NzZXRfY291bnQpIHsKIAkJaW50IHJjOwpAQCAtMjY1LDkgKzI2Niw3IEBA
IHN0YXRpYyBub2lubGluZSBpbnQgZXRodG9vbF9nZXRfc3NldF9pbmZvKHN0cnVjdCBuZXRf
ZGV2aWNlICpkZXYsCiAJCXJldHVybiAwOwogCiAJLyogY2FsY3VsYXRlIHNpemUgb2YgcmV0
dXJuIGJ1ZmZlciAqLwotCWZvciAoaSA9IDA7IGkgPCA2NDsgaSsrKQotCQlpZiAoc3NldF9t
YXNrICYgKDFVTEwgPDwgaSkpCi0JCQluX2JpdHMrKzsKKwluX2JpdHMgPSBod2VpZ2h0NjQo
c3NldF9tYXNrKTsKIAogCW1lbXNldCgmaW5mbywgMCwgc2l6ZW9mKGluZm8pKTsKIAlpbmZv
LmNtZCA9IEVUSFRPT0xfR1NTRVRfSU5GTzsK
--------------060606080704070002030604--
