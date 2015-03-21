From: Joe Harvell <jharvell@dogpad.tk>
Subject: Re: contributions to iproute2
Date: Fri, 20 Mar 2015 23:14:04 -0500
Message-ID: <550CF00C.2090309@dogpad.tk>
References: <ec4611159b474e158079d8d528e71030@BRMWP-EXMB11.corp.brocade.com> <20150320160819.1477223d@uryu.home.lan>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020700020805090205050302"
Cc: Stephen Hemminger <shemming@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-152-154-249.lightspeed.dllstx.sbcglobal.net ([99.152.154.249]:42608
	"EHLO akita.dogpad.tk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbbCUEYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 00:24:00 -0400
In-Reply-To: <20150320160819.1477223d@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020700020805090205050302
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Thanks, Stephen.

The bugfix is attached as fix-broken-get_prefix_1.diff with the 
following commit log:

commit 415464c94a62cfaa9c5ba493e45ce24a58d2118a
Author: Joe Harvell <joe.harvell@tekcomms.com>
Date:   Fri Mar 20 15:08:51 2015 -0500

      Fixing obvious error of passing in the wrong variable for the 
family parameter
      of af_bit_len.

I assume master must have some new change because this fix was needed 
for a basic 'ip addr add 10.0.3.1/24 dev dumbo label foo' command I 
pased in.  In this case, 'family' passed into get_addr_1 two lines above 
is zero, causing get_addr_1 to detect the family from the address and 
populate the result in the family field in dst.  But then instead of 
passing in the result, family (still 0) is passed in to af_bit_len. 
Without my change, the above command complains that 10.0.3.1/24 is not 
an address prefix.  With the change it works fine as expected.

The enhancement is attached as addr-label-noncompat.diff with the 
following commit log which speaks for itself.

commit 51b21cc0382e8a99246289a13e6e842f10e23c80
Author: Joe Harvell <joe.harvell@tekcomms.com>
Date:   Fri Mar 20 15:02:16 2015 -0500

      Making -force option of ip command also allow address labels that 
are not
      backward-compatible with ifconfig.  Note that even without this change
      the ip command does allow some incompatible address labels to be 
created.
      ifconfig depends on the labels beginning with 
<interface-name><colon>, but
      the ip command (even before the changes in this commit) only 
requires the
      prefix of the label to be <interface-name>.  Thus, if you add a 
label such
      as eth0-media, it will be accepted by ip but ifconfig will barf on 
ifconfig -a.
      The motivation for this change is that the lenght allowed for a 
lable is small,
      so requiring a long prefix for ifconfig backwards compatibility 
limits the
      usefulness of the label.  For embedded systems (or any system) 
where ifconfig
      is not even installed, it is useful to be able to create longer 
labels.

The only thing I have to add to the above is that maybe also the 
existing check (when -force is not specified) should be strengthened to 
reject any labels not beginning with <interface-name><colon> instead of 
just <interface-name>.  Try the following command sequence to the 
existing code to see what I mean:

sudo ip link add name dumbo type dummy
sudo ip addr add 10.0.1.0/24 dev dumbo label dumbo-a
ifconfig -a

You will see ifconfig abort when it encouters the address label dumo-a 
that it cannot map back to an interface.  I think the intent of the 
existing check is to prevent people from inadvertently creating such a 
configuration.  I think -force is a good option to enable it since 
anyone enabling this option must realize it and are not doing it 
inadvertently.

Thanks for your consideration.
---
Joe Harvell

On 20/03/2015 16:08, Stephen Hemminger wrote:
> On Fri, 20 Mar 2015 20:17:26 +0000
> Joe Harvell <jharvell@dogpad.tk> wrote:
>
>> Hi Stephen,
>>
>> I have an obvious bugfix and small enhancement to the ip command.  I
>> have each implemented in a separate branch baselined from today's master
>> (git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git)
>> and would like to submit the changes for consideration to be merged to
>> master.  I cannot push these branches, so what is the procedure?
>>
>> Thanks.
>>
>> ---
>> Joe Harvell
>>
> Send patch to netdev@vger.kernel.org
> It will get reviewed there and I will track it in patchwork



--------------020700020805090205050302
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="fix-broken-get_prefix_1.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="fix-broken-get_prefix_1.diff"

ZGlmZiAtLWdpdCBhL2xpYi91dGlscy5jIGIvbGliL3V0aWxzLmMKaW5kZXggMGQwOGE4Ni4u
OWNkYTI2OCAxMDA2NDQKLS0tIGEvbGliL3V0aWxzLmMKKysrIGIvbGliL3V0aWxzLmMKQEAg
LTQ3Nyw3ICs0NzcsNyBAQCBpbnQgZ2V0X3ByZWZpeF8xKGluZXRfcHJlZml4ICpkc3QsIGNo
YXIgKmFyZywgaW50IGZhbWlseSkKIAogCWVyciA9IGdldF9hZGRyXzEoZHN0LCBhcmcsIGZh
bWlseSk7CiAJaWYgKGVyciA9PSAwKSB7Ci0JCWRzdC0+Yml0bGVuID0gYWZfYml0X2xlbihk
c3QtPmZhbWlseSk7CisJCWRzdC0+Yml0bGVuID0gYWZfYml0X2xlbihmYW1pbHkpOwogCiAJ
CWlmIChzbGFzaCkgewogCQkJaWYgKGdldF9uZXRtYXNrKCZwbGVuLCBzbGFzaCsxLCAwKQoK

--------------020700020805090205050302
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="addr-label-noncompat.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="addr-label-noncompat.diff"

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvdXRpbHMuaCBiL2luY2x1ZGUvdXRpbHMuaAppbmRleCBl
OGE1NDY3Li45MTUxYzRmIDEwMDY0NAotLS0gYS9pbmNsdWRlL3V0aWxzLmgKKysrIGIvaW5j
bHVkZS91dGlscy5oCkBAIC0yNSw3ICsyNSw2IEBAIGV4dGVybiBjaGFyICogX1NMXzsKIGV4
dGVybiBpbnQgbWF4X2ZsdXNoX2xvb3BzOwogZXh0ZXJuIGludCBiYXRjaF9tb2RlOwogZXh0
ZXJuIGJvb2wgZG9fYWxsOwotZXh0ZXJuIGJvb2wgcmVxdWlyZV9pZmNvbmZpZ19jb21wYXQ7
CiAKICNpZm5kZWYgSVBQUk9UT19FU1AKICNkZWZpbmUgSVBQUk9UT19FU1AJNTAKZGlmZiAt
LWdpdCBhL2lwL2lwLmMgYi9pcC9pcC5jCmluZGV4IDI2Zjk5MTAuLmRhMTZiMTUgMTAwNjQ0
Ci0tLSBhL2lwL2lwLmMKKysrIGIvaXAvaXAuYwpAQCAtMzcsNyArMzcsNiBAQCBpbnQgZm9y
Y2UgPSAwOwogaW50IG1heF9mbHVzaF9sb29wcyA9IDEwOwogaW50IGJhdGNoX21vZGUgPSAw
OwogYm9vbCBkb19hbGwgPSBmYWxzZTsKLWJvb2wgcmVxdWlyZV9pZmNvbmZpZ19jb21wYXQg
PSB0cnVlOwogCiBzdHJ1Y3QgcnRubF9oYW5kbGUgcnRoID0geyAuZmQgPSAtMSB9OwogCkBA
IC0yNDcsNyArMjQ2LDYgQEAgaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKiphcmd2KQogCQkJ
ZXhpdCgwKTsKIAkJfSBlbHNlIGlmIChtYXRjaGVzKG9wdCwgIi1mb3JjZSIpID09IDApIHsK
IAkJCSsrZm9yY2U7Ci0gICAgICAgICAgICAgICAgICAgICAgICByZXF1aXJlX2lmY29uZmln
X2NvbXBhdCA9IGZhbHNlOwogCQl9IGVsc2UgaWYgKG1hdGNoZXMob3B0LCAiLWJhdGNoIikg
PT0gMCkgewogCQkJYXJnYy0tOwogCQkJYXJndisrOwpkaWZmIC0tZ2l0IGEvaXAvaXBhZGRy
ZXNzLmMgYi9pcC9pcGFkZHJlc3MuYwppbmRleCBhMWZhNzg1Li45OWE2YWI1IDEwMDY0NAot
LS0gYS9pcC9pcGFkZHJlc3MuYworKysgYi9pcC9pcGFkZHJlc3MuYwpAQCAtMTY5MSw3ICsx
NjkxLDcgQEAgc3RhdGljIGludCBpcGFkZHJfbW9kaWZ5KGludCBjbWQsIGludCBmbGFncywg
aW50IGFyZ2MsIGNoYXIgKiphcmd2KQogCQlmcHJpbnRmKHN0ZGVyciwgIk5vdCBlbm91Z2gg
aW5mb3JtYXRpb246IFwiZGV2XCIgYXJndW1lbnQgaXMgcmVxdWlyZWQuXG4iKTsKIAkJcmV0
dXJuIC0xOwogCX0KLQlpZiAocmVxdWlyZV9pZmNvbmZpZ19jb21wYXQgJiYgbCAmJiBtYXRj
aGVzKGQsIGwpICE9IDApIHsKKwlpZiAobCAmJiBtYXRjaGVzKGQsIGwpICE9IDApIHsKIAkJ
ZnByaW50ZihzdGRlcnIsICJcImRldlwiICglcykgbXVzdCBtYXRjaCBcImxhYmVsXCIgKCVz
KS5cbiIsIGQsIGwpOwogCQlyZXR1cm4gLTE7CiAJfQpkaWZmIC0tZ2l0IGEvbWFuL21hbjgv
aXAuOCBiL21hbi9tYW44L2lwLjgKaW5kZXggM2MzNTEyYy4uMDE2ZThjNiAxMDA2NDQKLS0t
IGEvbWFuL21hbjgvaXAuOAorKysgYi9tYW4vbWFuOC9pcC44CkBAIC01NCw4ICs1NCw2IEBA
IEZpcnN0IGZhaWx1cmUgd2lsbCBjYXVzZSB0ZXJtaW5hdGlvbiBvZiBpcC4KIERvbid0IHRl
cm1pbmF0ZSBpcCBvbiBlcnJvcnMgaW4gYmF0Y2ggbW9kZS4KIElmIHRoZXJlIHdlcmUgYW55
IGVycm9ycyBkdXJpbmcgZXhlY3V0aW9uIG9mIHRoZSBjb21tYW5kcywgdGhlIGFwcGxpY2F0
aW9uIHJldHVybiBjb2RlIHdpbGwgYmUgbm9uIHplcm8uCiAKLVRoaXMgb3B0aW9uIGFsc28g
YWxsb3dzIGNyZWF0aW9uIG9mIGFkZHJlc3MgbGFiZWxzIHRoYXQgbWF5IG5vdCBiZSBiYWNr
d2FyZHMgY29tcGF0aWJsZSB3aXRoIGlmY29uZmlnLgotCiAuVFAKIC5CUiAiXC1zIiAsICIg
XC1zdGF0cyIgLCAiIFwtc3RhdGlzdGljcyIKIE91dHB1dCBtb3JlIGluZm9ybWF0aW9uLiAg
SWYgdGhlIG9wdGlvbgoK
--------------020700020805090205050302--
