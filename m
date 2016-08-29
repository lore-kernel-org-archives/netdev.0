From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 29 Aug 2016 07:35:46 -0400
Message-ID: <b117fac2-c73f-2d42-3843-52f9717224d9@mojatatu.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
 <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
 <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------52687F5CBEBBD7430A942E84"
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:35138 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932820AbcH2Lme (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:42:34 -0400
Received: by mail-it0-f44.google.com with SMTP id x131so97644900ite.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 04:42:34 -0700 (PDT)
In-Reply-To: <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------52687F5CBEBBD7430A942E84
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 16-08-29 06:38 AM, Jamal Hadi Salim wrote:
> Let me see if i can
> try something. Trickery with RCU is not one of my virtues -
> so i may get it wrong but hope you can comment.

Something like attached? Compile tested.
I tried to emulate gact - but greping around I havent
seen sample code which uses  rcu_read_un/lock + synchronize_rcu
this way
[so be gentle if i got it wrong ;->]

I am not sure where Cong is going but probably introducing
a rcu head in each policy will allow to swap and free old one
with call_rcu may be a better approach. The cost may come in
slowing down replace operations.

cheers,
jamal

--------------52687F5CBEBBD7430A942E84
Content-Type: text/plain; charset=UTF-8;
 name="skbmod-rcu-maybe"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="skbmod-rcu-maybe"

CnN0YXRpYyBpbnQgdGNmX3NrYm1vZF9ydW4oc3RydWN0IHNrX2J1ZmYgKnNrYiwgY29uc3Qg
c3RydWN0IHRjX2FjdGlvbiAqYSwKCQkJICBzdHJ1Y3QgdGNmX3Jlc3VsdCAqcmVzKQp7Cglz
dHJ1Y3QgdGNmX3NrYm1vZCAqZCA9IHRvX3NrYm1vZChhKTsKCWludCBhY3Rpb24gPSBSRUFE
X09OQ0UoZC0+dGNmX2FjdGlvbik7Cgl1NjQgZmxhZ3MgPSBSRUFEX09OQ0UoZC0+ZmxhZ3Mp
OwoKCXRjZl9sYXN0dXNlX3VwZGF0ZSgmZC0+dGNmX3RtKTsKCWJzdGF0c19jcHVfdXBkYXRl
KHRoaXNfY3B1X3B0cihkLT5jb21tb24uY3B1X2JzdGF0cyksIHNrYik7CglpZiAodW5saWtl
bHkoYWN0aW9uID09IFRDX0FDVF9TSE9UKSkgewoJCXFzdGF0c19kcm9wX2luYyh0aGlzX2Nw
dV9wdHIoZC0+Y29tbW9uLmNwdV9xc3RhdHMpKTsKCQlyZXR1cm4gYWN0aW9uOwoJfQoKCWZs
YWdzID0gUkVBRF9PTkNFKGQtPmZsYWdzKTsKCXJjdV9yZWFkX2xvY2soKTsKCWlmIChmbGFn
cyAmIFNLQk1PRF9GX0RNQUMpCgkJZXRoZXJfYWRkcl9jb3B5KGV0aF9oZHIoc2tiKS0+aF9k
ZXN0LCBkLT5ldGhfZHN0KTsKCWlmIChmbGFncyAmIFNLQk1PRF9GX1NNQUMpCgkJZXRoZXJf
YWRkcl9jb3B5KGV0aF9oZHIoc2tiKS0+aF9zb3VyY2UsIGQtPmV0aF9zcmMpOwoJaWYgKGZs
YWdzICYgU0tCTU9EX0ZfRVRZUEUpCgkJZXRoX2hkcihza2IpLT5oX3Byb3RvID0gZC0+ZXRo
X3R5cGU7CglpZiAoZmxhZ3MgJiBTS0JNT0RfRl9TV0FQTUFDKSB7CgkJdTggdG1wYWRkcltF
VEhfQUxFTl07CgkJLypYWFg6IEkgYW0gc3VyZSB3ZSBjYW4gY29tZSB1cCB3aXRoIHNvbWV0
aGluZyBtb3JlIGVmZmljaWVudCAqLwoJCWV0aGVyX2FkZHJfY29weSh0bXBhZGRyLCBldGhf
aGRyKHNrYiktPmhfZGVzdCk7CgkJZXRoZXJfYWRkcl9jb3B5KGV0aF9oZHIoc2tiKS0+aF9k
ZXN0LCBldGhfaGRyKHNrYiktPmhfc291cmNlKTsKCQlldGhlcl9hZGRyX2NvcHkoZXRoX2hk
cihza2IpLT5oX3NvdXJjZSwgdG1wYWRkcik7Cgl9CglyY3VfcmVhZF91bmxvY2soKTsKCgly
ZXR1cm4gYWN0aW9uOwp9CgpzdGF0aWMgaW50IHRjZl9za2Jtb2RfaW5pdChzdHJ1Y3QgbmV0
ICpuZXQsIHN0cnVjdCBubGF0dHIgKm5sYSwKCQkJICAgc3RydWN0IG5sYXR0ciAqZXN0LCBz
dHJ1Y3QgdGNfYWN0aW9uICoqYSwKCQkJICAgaW50IG92ciwgaW50IGJpbmQpCnsKCXN0cnVj
dCB0Y19hY3Rpb25fbmV0ICp0biA9IG5ldF9nZW5lcmljKG5ldCwgc2tibW9kX25ldF9pZCk7
CglzdHJ1Y3QgbmxhdHRyICp0YltUQ0FfU0tCTU9EX01BWCArIDFdOwoJc3RydWN0IHRjX3Nr
Ym1vZCAqcGFybTsKCXN0cnVjdCB0Y2Zfc2tibW9kICpkOwoJdTMyIGxmbGFncyA9IDA7Cgl1
OCAqZGFkZHIgPSBOVUxMOwoJdTggKnNhZGRyID0gTlVMTDsKCXUxNiBldGhfdHlwZSA9IDA7
CgoJYm9vbCBleGlzdHMgPSBmYWxzZTsKCWludCByZXQgPSAwLCBlcnI7CgoJaWYgKG5sYSA9
PSBOVUxMKQoJCXJldHVybiAtRUlOVkFMOwoKCWVyciA9IG5sYV9wYXJzZV9uZXN0ZWQodGIs
IFRDQV9TS0JNT0RfTUFYLCBubGEsIHNrYm1vZF9wb2xpY3kpOwoJaWYgKGVyciA8IDApCgkJ
cmV0dXJuIGVycjsKCglpZiAodGJbVENBX1NLQk1PRF9QQVJNU10gPT0gTlVMTCkKCQlyZXR1
cm4gLUVJTlZBTDsKCglpZiAodGJbVENBX1NLQk1PRF9ETUFDXSkgewoJCWRhZGRyID0gbmxh
X2RhdGEodGJbVENBX1NLQk1PRF9ETUFDXSk7CgkJbGZsYWdzIHw9IFNLQk1PRF9GX0RNQUM7
Cgl9CgoJaWYgKHRiW1RDQV9TS0JNT0RfU01BQ10pIHsKCQlzYWRkciA9IG5sYV9kYXRhKHRi
W1RDQV9TS0JNT0RfU01BQ10pOwoJCWxmbGFncyB8PSBTS0JNT0RfRl9TTUFDOwoJfQoKCWlm
ICh0YltUQ0FfU0tCTU9EX0VUWVBFXSkgewoJCWV0aF90eXBlID0gbmxhX2dldF91MTYodGJb
VENBX1NLQk1PRF9FVFlQRV0pOwoJCWxmbGFncyB8PSBTS0JNT0RfRl9FVFlQRTsKCX0KCglw
YXJtID0gbmxhX2RhdGEodGJbVENBX1NLQk1PRF9QQVJNU10pOwoKCWlmIChwYXJtLT5mbGFn
cyAmIFNLQk1PRF9GX1NXQVBNQUMpCgkJbGZsYWdzID0gU0tCTU9EX0ZfU1dBUE1BQzsKCgll
eGlzdHMgPSB0Y2ZfaGFzaF9jaGVjayh0biwgcGFybS0+aW5kZXgsIGEsIGJpbmQpOwoJaWYg
KGV4aXN0cyAmJiBiaW5kKQoJCXJldHVybiAwOwoKCWlmICghbGZsYWdzKSB7CgkJcmV0dXJu
IC1FSU5WQUw7Cgl9CgoJaWYgKCFleGlzdHMpIHsKCQlyZXQgPSB0Y2ZfaGFzaF9jcmVhdGUo
dG4sIHBhcm0tPmluZGV4LCBlc3QsIGEsCgkJCQkgICAgICAmYWN0X3NrYm1vZF9vcHMsIGJp
bmQsIGZhbHNlKTsKCQlpZiAocmV0KQoJCQlyZXR1cm4gcmV0OwoKCQlkID0gdG9fc2tibW9k
KCphKTsKCQlyZXQgPSBBQ1RfUF9DUkVBVEVEOwoJfSBlbHNlIHsKCQlkID0gdG9fc2tibW9k
KCphKTsKCQl0Y2ZfaGFzaF9yZWxlYXNlKCphLCBiaW5kKTsKCQlpZiAoIW92cikKCQkJcmV0
dXJuIC1FRVhJU1Q7Cgl9CgoJQVNTRVJUX1JUTkwoKTsKCWQtPmZsYWdzID0gbGZsYWdzOwoJ
ZC0+dGNmX2FjdGlvbiA9IHBhcm0tPmFjdGlvbjsKCglpZiAob3ZyKQoJCXNwaW5fbG9ja19i
aCgmZC0+dGNmX2xvY2spOwoKCWlmIChsZmxhZ3MgJiBTS0JNT0RfRl9ETUFDKQoJCWV0aGVy
X2FkZHJfY29weShkLT5ldGhfZHN0LCBkYWRkcik7CglpZiAobGZsYWdzICYgU0tCTU9EX0Zf
U01BQykKCQlldGhlcl9hZGRyX2NvcHkoZC0+ZXRoX3NyYywgc2FkZHIpOwoJaWYgKGxmbGFn
cyAmIFNLQk1PRF9GX0VUWVBFKQoJCWQtPmV0aF90eXBlID0gaHRvbnMoZXRoX3R5cGUpOwoK
CglpZiAob3ZyKSB7CgkJc3Bpbl91bmxvY2tfYmgoJmQtPnRjZl9sb2NrKTsKCQlzeW5jaHJv
bml6ZV9yY3UoKTsKCX0KCglpZiAocmV0ID09IEFDVF9QX0NSRUFURUQpCgkJdGNmX2hhc2hf
aW5zZXJ0KHRuLCAqYSk7CglyZXR1cm4gcmV0Owp9Cgo=
--------------52687F5CBEBBD7430A942E84--
