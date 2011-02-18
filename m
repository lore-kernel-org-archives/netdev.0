From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible netfilter-related memory corruption in 2.6.37
Date: Fri, 18 Feb 2011 19:37:33 +0100
Message-ID: <4D5EBC6D.6070200@trash.net>
References: <4D594313.4050009@redhat.com>	 <1297696283.2996.33.camel@edumazet-laptop>	 <alpine.LNX.2.01.1102141617330.12050@obet.zrqbmnf.qr>	 <1297698641.2996.38.camel@edumazet-laptop>  <4D595745.7070505@trash.net>	 <1297700955.2996.40.camel@edumazet-laptop>  <4D595A48.9070201@trash.net> <1297702128.2996.41.camel@edumazet-laptop> <4D595DBD.3090005@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060608050108090802020104"
Cc: Jan Engelhardt <jengelh@medozas.de>, Avi Kivity <avi@redhat.com>,
	netfilter-devel@vger.kernel.org,
	Marcelo Tosatti <mtosatti@redhat.com>,
	nicolas prochazka <prochazka.nicolas@gmail.com>,
	KVM list <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D595DBD.3090005@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060608050108090802020104
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Am 14.02.2011 17:52, schrieb Patrick McHardy:
> Am 14.02.2011 17:48, schrieb Eric Dumazet:
>> I am not sure, but I guess nf_reinject() needs a fix too ;)
> 
> I agree. That one looks uglier though, I guess we'll have to
> iterate through all hooks to note the previous one.

How about this? Unfortunately I don't think we can avoid
iterating through all hooks without violating RCU rules.



--------------060608050108090802020104
Content-Type: text/plain;
 name="x.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="x.diff"

ZGlmZiAtLWdpdCBhL25ldC9uZXRmaWx0ZXIvbmZfcXVldWUuYyBiL25ldC9uZXRmaWx0ZXIv
bmZfcXVldWUuYwppbmRleCA3NGFlYmVkLi44MzRiYjA3IDEwMDY0NAotLS0gYS9uZXQvbmV0
ZmlsdGVyL25mX3F1ZXVlLmMKKysrIGIvbmV0L25ldGZpbHRlci9uZl9xdWV1ZS5jCkBAIC0y
MzUsNiArMjM1LDcgQEAgaW50IG5mX3F1ZXVlKHN0cnVjdCBza19idWZmICpza2IsCiB2b2lk
IG5mX3JlaW5qZWN0KHN0cnVjdCBuZl9xdWV1ZV9lbnRyeSAqZW50cnksIHVuc2lnbmVkIGlu
dCB2ZXJkaWN0KQogewogCXN0cnVjdCBza19idWZmICpza2IgPSBlbnRyeS0+c2tiOworCXN0
cnVjdCBuZl9ob29rX29wcyAqaSwgKnByZXY7CiAJc3RydWN0IGxpc3RfaGVhZCAqZWxlbSA9
ICZlbnRyeS0+ZWxlbS0+bGlzdDsKIAljb25zdCBzdHJ1Y3QgbmZfYWZpbmZvICphZmluZm87
CiAKQEAgLTI0NCw4ICsyNDUsMjEgQEAgdm9pZCBuZl9yZWluamVjdChzdHJ1Y3QgbmZfcXVl
dWVfZW50cnkgKmVudHJ5LCB1bnNpZ25lZCBpbnQgdmVyZGljdCkKIAogCS8qIENvbnRpbnVl
IHRyYXZlcnNhbCBpZmYgdXNlcnNwYWNlIHNhaWQgb2suLi4gKi8KIAlpZiAodmVyZGljdCA9
PSBORl9SRVBFQVQpIHsKLQkJZWxlbSA9IGVsZW0tPnByZXY7Ci0JCXZlcmRpY3QgPSBORl9B
Q0NFUFQ7CisJCXByZXYgPSBOVUxMOworCQlsaXN0X2Zvcl9lYWNoX2VudHJ5X3JjdShpLCAm
bmZfaG9va3NbZW50cnktPnBmXVtlbnRyeS0+aG9va10sCisJCQkJCWxpc3QpIHsKKwkJCWlm
ICgmaS0+bGlzdCA9PSBlbGVtKQorCQkJCWJyZWFrOworCQkJcHJldiA9IGk7CisJCX0KKwor
CQlpZiAocHJldiA9PSBOVUxMIHx8CisJCSAgICAmaS0+bGlzdCA9PSAmbmZfaG9va3NbZW50
cnktPnBmXVtlbnRyeS0+aG9va10pCisJCQl2ZXJkaWN0ID0gTkZfRFJPUDsKKwkJZWxzZSB7
CisJCQllbGVtID0gJnByZXYtPmxpc3Q7CisJCQl2ZXJkaWN0ID0gTkZfQUNDRVBUOworCQl9
CiAJfQogCiAJaWYgKHZlcmRpY3QgPT0gTkZfQUNDRVBUKSB7Cg==
--------------060608050108090802020104--
