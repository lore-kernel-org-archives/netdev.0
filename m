From: Shahar Klein <shahark@mellanox.com>
Subject: Re: Soft lockup in tc_classify
Date: Wed, 21 Dec 2016 13:25:18 +0200
Message-ID: <94c8dece-42b3-5e60-d73e-daabc4d4edc5@mellanox.com>
References: <c1c394d3-3aea-52a8-89e3-be57d4d46b8e@mellanox.com>
 <7394f89e-e8a5-5fb2-ee04-63bf1c4ef6e7@mellanox.com>
 <584EA60B.80803@iogearbox.net>
 <CAJ3xEMjABmvAMs6h0EqBgPH8QDDwF_x0COx01MkEw2pa+fp7LA@mail.gmail.com>
 <CAM_iQpVJ_Y5bB-RP2S2tK7sPNo6Atwcz5Ud8sG6bwDOSnq4NnA@mail.gmail.com>
 <18a64d65-1241-6c72-8333-47b0ae933139@mellanox.com>
 <CAM_iQpXUQYvvXonEXe0czd4osL5YxZ+G5B-PUddautcHnGOtQw@mail.gmail.com>
 <5a985705-11e5-1575-a049-723accb97608@mellanox.com>
 <58591A46.4060703@iogearbox.net>
 <66a3cb1e-862f-70e6-fff4-5a421766c432@mellanox.com>
 <CAM_iQpX3jL4URUQn5+-wV+3g2UKHWGBWYHr31wyZk2FQKVCzVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="------------FCA2AC359D3D63B36C953A88"
Cc: <shahark@mellanox.com>, Daniel Borkmann <daniel@iogearbox.net>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0041.outbound.protection.outlook.com ([104.47.0.41]:25280
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752022AbcLULk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Dec 2016 06:40:26 -0500
In-Reply-To: <CAM_iQpX3jL4URUQn5+-wV+3g2UKHWGBWYHr31wyZk2FQKVCzVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------FCA2AC359D3D63B36C953A88
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit



On 12/21/2016 9:03 AM, Cong Wang wrote:
> On Tue, Dec 20, 2016 at 10:44 PM, Shahar Klein <shahark@mellanox.com> wrote:
>>
>> Tried it with same results
>
> This piece is pretty interesting:
>
> [  408.554689] DEBUGG:SK thread-2853[cpu-1] setting tp_created to 1
> tp=ffff94b5b02805a0 back=ffff94b9ea932060
> [  408.574258] DEBUGG:SK thread-2853[cpu-1] add/change filter by:
> fl_get [cls_flower] tp=ffff94b5b02805a0 tp->next=ffff94b9ea932060
> [  408.587849] DEBUGG:SK destroy ffff94b5b0280780 tcf_destroy:1905
> [  408.595862] DEBUGG:SK thread-2845[cpu-1] add/change filter by:
> fl_get [cls_flower] tp=ffff94b5b02805a0 tp->next=ffff94b5b02805a0
>
> Looks like you added a debug printk inside tcf_destroy() too,
> which seems racy with filter creation, it should not happen since
> in both cases we take RTNL lock.
>
> Don't know if changing all RCU_INIT_POINTER in that file to
> rcu_assign_pointer could help anything or not. Mind to try?
>

Tried it with same results

>
> Thanks for debugging!
>

--------------FCA2AC359D3D63B36C953A88
Content-Type: text/plain; charset="UTF-8"; name="cls_api_no_RCU.c.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="cls_api_no_RCU.c.diff"

ZGlmZiAtLWdpdCBhL25ldC9zY2hlZC9jbHNfYXBpLmMgYi9uZXQvc2NoZWQvY2xzX2FwaS5j
CmluZGV4IDNmYmJhNzkuLmI4YTY2ZDggMTAwNjQ0Ci0tLSBhL25ldC9zY2hlZC9jbHNfYXBp
LmMKKysrIGIvbmV0L3NjaGVkL2Nsc19hcGkuYwpAQCAtMzA1LDcgKzMwNSw3IEBAIHN0YXRp
YyBpbnQgdGNfY3RsX3RmaWx0ZXIoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IG5sbXNn
aGRyICpuKQogCQkJa2ZyZWUodHApOwogCQkJZ290byBlcnJvdXQ7CiAJCX0KLQorCQlwcmlu
dGsoS0VSTl9FUlIgIkRFQlVHRzpTSyB0aHJlYWQtJWRbY3B1LSVkXSBzZXR0aW5nIHRwX2Ny
ZWF0ZWQgdG8gMSB0cD0lcCBiYWNrPSVwXG4iLCBjdXJyZW50LT5waWQsIGN1cnJlbnQtPm9u
X2NwdSwgdHAsIHJ0bmxfZGVyZWZlcmVuY2UoKmJhY2spKTsKIAkJdHBfY3JlYXRlZCA9IDE7
CiAKIAl9IGVsc2UgaWYgKHRjYVtUQ0FfS0lORF0gJiYgbmxhX3N0cmNtcCh0Y2FbVENBX0tJ
TkRdLCB0cC0+b3BzLT5raW5kKSkKQEAgLTMxNywxMSArMzE3LDEzIEBAIHN0YXRpYyBpbnQg
dGNfY3RsX3RmaWx0ZXIoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IG5sbXNnaGRyICpu
KQogCQlpZiAobi0+bmxtc2dfdHlwZSA9PSBSVE1fREVMVEZJTFRFUiAmJiB0LT50Y21faGFu
ZGxlID09IDApIHsKIAkJCXN0cnVjdCB0Y2ZfcHJvdG8gKm5leHQgPSBydG5sX2RlcmVmZXJl
bmNlKHRwLT5uZXh0KTsKIAotCQkJUkNVX0lOSVRfUE9JTlRFUigqYmFjaywgbmV4dCk7CisJ
CQlwcmludGsoS0VSTl9FUlIgIkRFQlVHRzpTSyBkZWxldGUgZmlsdGVyIGJ5OiAlcGZcbiIs
IHRwLT5vcHMtPmdldCk7CisKKwkJCXJjdV9hc3NpZ25fcG9pbnRlcigqYmFjaywgbmV4dCk7
CiAKIAkJCXRmaWx0ZXJfbm90aWZ5KG5ldCwgc2tiLCBuLCB0cCwgZmgsCiAJCQkJICAgICAg
IFJUTV9ERUxURklMVEVSLCBmYWxzZSk7Ci0JCQl0Y2ZfZGVzdHJveSh0cCwgdHJ1ZSk7CisJ
CQl0Y2ZfZGVzdHJveSh0cCk7CiAJCQllcnIgPSAwOwogCQkJZ290byBlcnJvdXQ7CiAJCX0K
QEAgLTMzMSwyNSArMzMzLDMwIEBAIHN0YXRpYyBpbnQgdGNfY3RsX3RmaWx0ZXIoc3RydWN0
IHNrX2J1ZmYgKnNrYiwgc3RydWN0IG5sbXNnaGRyICpuKQogCQkgICAgIShuLT5ubG1zZ19m
bGFncyAmIE5MTV9GX0NSRUFURSkpCiAJCQlnb3RvIGVycm91dDsKIAl9IGVsc2UgeworCQli
b29sIGxhc3Q7CisKIAkJc3dpdGNoIChuLT5ubG1zZ190eXBlKSB7CiAJCWNhc2UgUlRNX05F
V1RGSUxURVI6CiAJCQllcnIgPSAtRUVYSVNUOwogCQkJaWYgKG4tPm5sbXNnX2ZsYWdzICYg
TkxNX0ZfRVhDTCkgewogCQkJCWlmICh0cF9jcmVhdGVkKQotCQkJCQl0Y2ZfZGVzdHJveSh0
cCwgdHJ1ZSk7CisJCQkJCXRjZl9kZXN0cm95KHRwKTsKIAkJCQlnb3RvIGVycm91dDsKIAkJ
CX0KIAkJCWJyZWFrOwogCQljYXNlIFJUTV9ERUxURklMVEVSOgotCQkJZXJyID0gdHAtPm9w
cy0+ZGVsZXRlKHRwLCBmaCk7CisJCQlwcmludGsoS0VSTl9FUlIgIkRFQlVHRzpTSyAlczol
ZFxuIiwgX19mdW5jX18sIF9fTElORV9fKTsKKwkJCWVyciA9IHRwLT5vcHMtPmRlbGV0ZSh0
cCwgZmgsICZsYXN0KTsKIAkJCWlmIChlcnIgPT0gMCkgewotCQkJCXN0cnVjdCB0Y2ZfcHJv
dG8gKm5leHQgPSBydG5sX2RlcmVmZXJlbmNlKHRwLT5uZXh0KTsKLQogCQkJCXRmaWx0ZXJf
bm90aWZ5KG5ldCwgc2tiLCBuLCB0cCwKIAkJCQkJICAgICAgIHQtPnRjbV9oYW5kbGUsCiAJ
CQkJCSAgICAgICBSVE1fREVMVEZJTFRFUiwgZmFsc2UpOwotCQkJCWlmICh0Y2ZfZGVzdHJv
eSh0cCwgZmFsc2UpKQotCQkJCQlSQ1VfSU5JVF9QT0lOVEVSKCpiYWNrLCBuZXh0KTsKKwkJ
CQlpZiAobGFzdCkgeworCQkJCQlzdHJ1Y3QgdGNmX3Byb3RvICpuZXh0ID0gcnRubF9kZXJl
ZmVyZW5jZSh0cC0+bmV4dCk7CisKKwkJCQkJcmN1X2Fzc2lnbl9wb2ludGVyKCpiYWNrLCBu
ZXh0KTsKKwkJCQkJdGNmX2Rlc3Ryb3kodHApOworCQkJCX0KIAkJCX0KIAkJCWdvdG8gZXJy
b3V0OwogCQljYXNlIFJUTV9HRVRURklMVEVSOgpAQCAtMzY2LDEzICszNzMsMTQgQEAgc3Rh
dGljIGludCB0Y19jdGxfdGZpbHRlcihzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBzdHJ1Y3Qgbmxt
c2doZHIgKm4pCiAJCQkgICAgICBuLT5ubG1zZ19mbGFncyAmIE5MTV9GX0NSRUFURSA/IFRD
QV9BQ1RfTk9SRVBMQUNFIDogVENBX0FDVF9SRVBMQUNFKTsKIAlpZiAoZXJyID09IDApIHsK
IAkJaWYgKHRwX2NyZWF0ZWQpIHsKLQkJCVJDVV9JTklUX1BPSU5URVIodHAtPm5leHQsIHJ0
bmxfZGVyZWZlcmVuY2UoKmJhY2spKTsKKwkJCXJjdV9hc3NpZ25fcG9pbnRlcih0cC0+bmV4
dCwgcnRubF9kZXJlZmVyZW5jZSgqYmFjaykpOwogCQkJcmN1X2Fzc2lnbl9wb2ludGVyKCpi
YWNrLCB0cCk7CisJCQlwcmludGsoS0VSTl9FUlIgIkRFQlVHRzpTSyB0aHJlYWQtJWRbY3B1
LSVkXSBhZGQvY2hhbmdlIGZpbHRlciBieTogJXBmIHRwPSVwIHRwLT5uZXh0PSVwXG4iLCBj
dXJyZW50LT5waWQsIGN1cnJlbnQtPm9uX2NwdSwgdHAtPm9wcy0+Z2V0LCB0cCwgdHAtPm5l
eHQpOwogCQl9CiAJCXRmaWx0ZXJfbm90aWZ5KG5ldCwgc2tiLCBuLCB0cCwgZmgsIFJUTV9O
RVdURklMVEVSLCBmYWxzZSk7CiAJfSBlbHNlIHsKIAkJaWYgKHRwX2NyZWF0ZWQpCi0JCQl0
Y2ZfZGVzdHJveSh0cCwgdHJ1ZSk7CisJCQl0Y2ZfZGVzdHJveSh0cCk7CiAJfQogCiBlcnJv
dXQ6Cg==
--------------FCA2AC359D3D63B36C953A88--
