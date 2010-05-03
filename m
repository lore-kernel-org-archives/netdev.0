From: "Simon Arlott" <simon@fire.lp0.eu>
Subject: Re: [PATCH 1/2] ppp_generic: pull 2 bytes so that PPP_PROTO(skb)
 is valid
Date: Mon, 3 May 2010 12:50:04 +0100
Message-ID: <e85216b167313bb2bd46f5990ed468f5b67a1ad8@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
References: <4BDB244D.40800@simon.arlott.org.uk>
    <20100502.232520.146109082.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;boundary="----=_20100503125004_58841"
Cc: netdev@vger.kernel.org, paulus@samba.org, linux-ppp@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20100502.232520.146109082.davem@davemloft.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_20100503125004_58841
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Mon, May 3, 2010 07:25, David Miller wrote:
> From: Simon Arlott <simon@fire.lp0.eu>
> Date: Fri, 30 Apr 2010 19:41:17 +0100
>> @@ -1572,8 +1572,18 @@ ppp_input(struct ppp_channel *chan, struct sk_buff *skb)
>>  		return;
>>  	}
>>
>> -	proto = PPP_PROTO(skb);
>> +
>>  	read_lock_bh(&pch->upl);
>> +	if (!pskb_may_pull(skb, 2)) {
>
> This makes the skb->len == 0 test at the beginning completely redundant.
>
> Put your pskb_may_pull(skb, 2) call there and remove the skb->len==0
> check entirely.

If I move pskb_may_pull(skb, 2) up to where skb->len == 0 is then it can't
increment rx_length_errors because it doesn't have the read lock on pch->upl,
so I can only remove the redundant skb->len == 0 if that error count is to
remain.

Updated patch attached.

-- 
Simon Arlott
------=_20100503125004_58841
Content-Type: application/octet-stream;
  name="0001-ppp_generic-pull-2-bytes-so-that-PPP_PROTO-skb-is-va.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
  filename=
 "0001-ppp_generic-pull-2-bytes-so-that-PPP_PROTO-skb-is-va.patch"

RnJvbSBmNmQyMjU5NzExNDNkYjFmZjUzNTMwMDhkMjA1NzllMWRlNzVmMDBkIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTaW1vbiBBcmxvdHQgPHNpbW9uQGZpcmUubHAwLmV1PgpEYXRl
OiBGcmksIDMwIEFwciAyMDEwIDE5OjA0OjMzICswMTAwClN1YmplY3Q6IFtQQVRDSCAxLzJdIHBw
cF9nZW5lcmljOiBwdWxsIDIgYnl0ZXMgc28gdGhhdCBQUFBfUFJPVE8oc2tiKSBpcyB2YWxpZAoK
SW4gcHBwX2lucHV0KCksIFBQUF9QUk9UTyhza2IpIG1heSByZWZlciB0byBpbnZhbGlkIGRhdGEg
aW4gdGhlIHNrYi4KCklmIHRoaXMgaGFwcGVucyBhbmQgKHByb3RvID49IDB4YzAwMCB8fCBwcm90
byA9PSBQUFBfQ0NQRlJBRykgdGhlbgp0aGUgcGFja2V0IGlzIHBhc3NlZCBkaXJlY3RseSB0byBw
cHBkLgoKVGhpcyBvY2N1cnMgZnJlcXVlbnRseSB3aGVuIHVzaW5nIFBQUG9FIHdpdGggYW4gaW50
ZXJmYWNlIE1UVQpncmVhdGVyIHRoYW4gMTUwMCBiZWNhdXNlIHRoZSBza2IgaXMgbW9yZSBsaWtl
bHkgdG8gYmUgbm9uLWxpbmVhci4KClRoZSBuZXh0IDIgYnl0ZXMgbmVlZCB0byBiZSBwdWxsZWQg
aW4gcHBwX2lucHV0KCkuIFRoZSBwdWxsIG9mIDIKYnl0ZXMgaW4gcHBwX3JlY2VpdmVfZnJhbWUo
KSBoYXMgYmVlbiByZW1vdmVkIGFzIGl0IGlzIG5vIGxvbmdlcgpyZXF1aXJlZC4KClNpZ25lZC1v
ZmYtYnk6IFNpbW9uIEFybG90dCA8c2ltb25AZmlyZS5scDAuZXU+Ci0tLQogZHJpdmVycy9uZXQv
cHBwX2dlbmVyaWMuYyB8ICAgMjkgKysrKysrKysrKysrKysrKysrLS0tLS0tLS0tLS0KIDEgZmls
ZXMgY2hhbmdlZCwgMTggaW5zZXJ0aW9ucygrKSwgMTEgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0
IGEvZHJpdmVycy9uZXQvcHBwX2dlbmVyaWMuYyBiL2RyaXZlcnMvbmV0L3BwcF9nZW5lcmljLmMK
aW5kZXggNmUyODFiYy4uNzVlODkwMyAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvcHBwX2dlbmVy
aWMuYworKysgYi9kcml2ZXJzL25ldC9wcHBfZ2VuZXJpYy5jCkBAIC0xNTY3LDEzICsxNTY3LDIy
IEBAIHBwcF9pbnB1dChzdHJ1Y3QgcHBwX2NoYW5uZWwgKmNoYW4sIHN0cnVjdCBza19idWZmICpz
a2IpCiAJc3RydWN0IGNoYW5uZWwgKnBjaCA9IGNoYW4tPnBwcDsKIAlpbnQgcHJvdG87CiAKLQlp
ZiAoIXBjaCB8fCBza2ItPmxlbiA9PSAwKSB7CisJaWYgKCFwY2gpIHsKIAkJa2ZyZWVfc2tiKHNr
Yik7CiAJCXJldHVybjsKIAl9CiAKLQlwcm90byA9IFBQUF9QUk9UTyhza2IpOwogCXJlYWRfbG9j
a19iaCgmcGNoLT51cGwpOworCWlmICghcHNrYl9tYXlfcHVsbChza2IsIDIpKSB7CisJCWtmcmVl
X3NrYihza2IpOworCQlpZiAocGNoLT5wcHApIHsKKwkJCSsrcGNoLT5wcHAtPmRldi0+c3RhdHMu
cnhfbGVuZ3RoX2Vycm9yczsKKwkJCXBwcF9yZWNlaXZlX2Vycm9yKHBjaC0+cHBwKTsKKwkJfQor
CQlnb3RvIGRvbmU7CisJfQorCisJcHJvdG8gPSBQUFBfUFJPVE8oc2tiKTsKIAlpZiAoIXBjaC0+
cHBwIHx8IHByb3RvID49IDB4YzAwMCB8fCBwcm90byA9PSBQUFBfQ0NQRlJBRykgewogCQkvKiBw
dXQgaXQgb24gdGhlIGNoYW5uZWwgcXVldWUgKi8KIAkJc2tiX3F1ZXVlX3RhaWwoJnBjaC0+Zmls
ZS5ycSwgc2tiKTsKQEAgLTE1ODUsNiArMTU5NCw4IEBAIHBwcF9pbnB1dChzdHJ1Y3QgcHBwX2No
YW5uZWwgKmNoYW4sIHN0cnVjdCBza19idWZmICpza2IpCiAJfSBlbHNlIHsKIAkJcHBwX2RvX3Jl
Y3YocGNoLT5wcHAsIHNrYiwgcGNoKTsKIAl9CisKK2RvbmU6CiAJcmVhZF91bmxvY2tfYmgoJnBj
aC0+dXBsKTsKIH0KIApAQCAtMTYxNyw3ICsxNjI4LDggQEAgcHBwX2lucHV0X2Vycm9yKHN0cnVj
dCBwcHBfY2hhbm5lbCAqY2hhbiwgaW50IGNvZGUpCiBzdGF0aWMgdm9pZAogcHBwX3JlY2VpdmVf
ZnJhbWUoc3RydWN0IHBwcCAqcHBwLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBzdHJ1Y3QgY2hhbm5l
bCAqcGNoKQogewotCWlmIChwc2tiX21heV9wdWxsKHNrYiwgMikpIHsKKwkvKiBub3RlOiBhIDAt
bGVuZ3RoIHNrYiBpcyB1c2VkIGFzIGFuIGVycm9yIGluZGljYXRpb24gKi8KKwlpZiAoc2tiLT5s
ZW4gPiAwKSB7CiAjaWZkZWYgQ09ORklHX1BQUF9NVUxUSUxJTksKIAkJLyogWFhYIGRvIGNoYW5u
ZWwtbGV2ZWwgZGVjb21wcmVzc2lvbiBoZXJlICovCiAJCWlmIChQUFBfUFJPVE8oc2tiKSA9PSBQ
UFBfTVApCkBAIC0xNjI1LDE1ICsxNjM3LDEwIEBAIHBwcF9yZWNlaXZlX2ZyYW1lKHN0cnVjdCBw
cHAgKnBwcCwgc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IGNoYW5uZWwgKnBjaCkKIAkJZWxz
ZQogI2VuZGlmIC8qIENPTkZJR19QUFBfTVVMVElMSU5LICovCiAJCQlwcHBfcmVjZWl2ZV9ub25t
cF9mcmFtZShwcHAsIHNrYik7Ci0JCXJldHVybjsKKwl9IGVsc2UgeworCQlrZnJlZV9za2Ioc2ti
KTsKKwkJcHBwX3JlY2VpdmVfZXJyb3IocHBwKTsKIAl9Ci0KLQlpZiAoc2tiLT5sZW4gPiAwKQot
CQkvKiBub3RlOiBhIDAtbGVuZ3RoIHNrYiBpcyB1c2VkIGFzIGFuIGVycm9yIGluZGljYXRpb24g
Ki8KLQkJKytwcHAtPmRldi0+c3RhdHMucnhfbGVuZ3RoX2Vycm9yczsKLQotCWtmcmVlX3NrYihz
a2IpOwotCXBwcF9yZWNlaXZlX2Vycm9yKHBwcCk7CiB9CiAKIHN0YXRpYyB2b2lkCi0tIAoxLjcu
MC40Cgo=
------=_20100503125004_58841--

