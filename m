From: Cong Wang <cwang@twopensource.com>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Mon, 4 May 2015 11:45:41 -0700
Message-ID: <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
	<20150504133943.GA17043@x131e>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=f46d043c7f0c094cdd051545f810
Cc: netdev <netdev@vger.kernel.org>
To: Dominick Grift <dac.override@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34766 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbbEDSpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 14:45:43 -0400
Received: by wgso17 with SMTP id o17so159655735wgs.1
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 11:45:42 -0700 (PDT)
In-Reply-To: <20150504133943.GA17043@x131e>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--f46d043c7f0c094cdd051545f810
Content-Type: text/plain; charset=UTF-8

On Mon, May 4, 2015 at 6:39 AM, Dominick Grift <dac.override@gmail.com> wrote:
> On Thu, Apr 23, 2015 at 01:07:45PM -0400, Josh Boyer wrote:
>> Hi All,
>>
>> We've had a user report the following backtrace from the bridge module
>> with a recent Linus' tree.  Has anything like this been reported yet?
>> If you have any questions on setup, the user is CC'd.
>>
>> josh
>>
>> [   29.382235] br0: port 1(tap0) entered forwarding state
>>
>> [   29.382286] ===============================
>> [   29.382315] [ INFO: suspicious RCU usage. ]
>> [   29.382344] 4.1.0-0.rc0.git11.1.fc23.x86_64 #1 Not tainted
>> [   29.382380] -------------------------------
>> [   29.382409] net/bridge/br_private.h:626 suspicious
>> rcu_dereference_check() usage!
>
> <snip>
>
> With 4.1.0-0.rc1.git1.1.fc23.x86_64 the situation seems to have slightly changed:
>

Should be the same issue. Please give the attached patch a try,
it is compile-tested only.

Thanks!

--f46d043c7f0c094cdd051545f810
Content-Type: text/plain; charset=US-ASCII; name="br.diff"
Content-Disposition: attachment; filename="br.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i9a8ly3r1

ZGlmZiAtLWdpdCBhL25ldC9icmlkZ2UvYnJfbmV0bGluay5jIGIvbmV0L2JyaWRnZS9icl9uZXRs
aW5rLmMKaW5kZXggNGI1YzIzNi4uOGJhOTg5YSAxMDA2NDQKLS0tIGEvbmV0L2JyaWRnZS9icl9u
ZXRsaW5rLmMKKysrIGIvbmV0L2JyaWRnZS9icl9uZXRsaW5rLmMKQEAgLTMyNSwyMiArMzI1LDI4
IEBAIHN0YXRpYyBpbnQgYnJfZmlsbF9pZmluZm8oc3RydWN0IHNrX2J1ZmYgKnNrYiwKIAkJc3Ry
dWN0IG5sYXR0ciAqYWY7CiAJCWludCBlcnI7CiAKKwkJcmN1X3JlYWRfbG9jaygpOwogCQlpZiAo
cG9ydCkKIAkJCXB2ID0gbmJwX2dldF92bGFuX2luZm8ocG9ydCk7CiAJCWVsc2UKIAkJCXB2ID0g
YnJfZ2V0X3ZsYW5faW5mbyhicik7CiAKLQkJaWYgKCFwdiB8fCBiaXRtYXBfZW1wdHkocHYtPnZs
YW5fYml0bWFwLCBWTEFOX05fVklEKSkKKwkJaWYgKCFwdiB8fCBiaXRtYXBfZW1wdHkocHYtPnZs
YW5fYml0bWFwLCBWTEFOX05fVklEKSkgeworCQkJcmN1X3JlYWRfdW5sb2NrKCk7CiAJCQlnb3Rv
IGRvbmU7CisJCX0KIAogCQlhZiA9IG5sYV9uZXN0X3N0YXJ0KHNrYiwgSUZMQV9BRl9TUEVDKTsK
LQkJaWYgKCFhZikKKwkJaWYgKCFhZikgeworCQkJcmN1X3JlYWRfdW5sb2NrKCk7CiAJCQlnb3Rv
IG5sYV9wdXRfZmFpbHVyZTsKKwkJfQogCiAJCWlmIChmaWx0ZXJfbWFzayAmIFJURVhUX0ZJTFRF
Ul9CUlZMQU5fQ09NUFJFU1NFRCkKIAkJCWVyciA9IGJyX2ZpbGxfaWZ2bGFuaW5mb19jb21wcmVz
c2VkKHNrYiwgcHYpOwogCQllbHNlCiAJCQllcnIgPSBicl9maWxsX2lmdmxhbmluZm8oc2tiLCBw
dik7CisJCXJjdV9yZWFkX3VubG9jaygpOwogCQlpZiAoZXJyKQogCQkJZ290byBubGFfcHV0X2Zh
aWx1cmU7CiAJCW5sYV9uZXN0X2VuZChza2IsIGFmKTsKZGlmZiAtLWdpdCBhL25ldC9icmlkZ2Uv
YnJfcHJpdmF0ZS5oIGIvbmV0L2JyaWRnZS9icl9wcml2YXRlLmgKaW5kZXggMzM2MmMyOS4uODYw
ODMyZSAxMDA2NDQKLS0tIGEvbmV0L2JyaWRnZS9icl9wcml2YXRlLmgKKysrIGIvbmV0L2JyaWRn
ZS9icl9wcml2YXRlLmgKQEAgLTYxNywxMyArNjE3LDE3IEBAIGludCBuYnBfdmxhbl9pbml0KHN0
cnVjdCBuZXRfYnJpZGdlX3BvcnQgKnBvcnQpOwogc3RhdGljIGlubGluZSBzdHJ1Y3QgbmV0X3Bv
cnRfdmxhbnMgKmJyX2dldF92bGFuX2luZm8oCiAJCQkJCQljb25zdCBzdHJ1Y3QgbmV0X2JyaWRn
ZSAqYnIpCiB7Ci0JcmV0dXJuIHJjdV9kZXJlZmVyZW5jZV9ydG5sKGJyLT52bGFuX2luZm8pOwor
CXJldHVybiByY3VfZGVyZWZlcmVuY2VfcHJvdGVjdGVkKGJyLT52bGFuX2luZm8sCisJCQkJCSBy
Y3VfcmVhZF9sb2NrX2hlbGQoKSB8fAorCQkJCQkgbG9ja2RlcF9ydG5sX2lzX2hlbGQoKSk7CiB9
CiAKIHN0YXRpYyBpbmxpbmUgc3RydWN0IG5ldF9wb3J0X3ZsYW5zICpuYnBfZ2V0X3ZsYW5faW5m
bygKIAkJCQkJCWNvbnN0IHN0cnVjdCBuZXRfYnJpZGdlX3BvcnQgKnApCiB7Ci0JcmV0dXJuIHJj
dV9kZXJlZmVyZW5jZV9ydG5sKHAtPnZsYW5faW5mbyk7CisJcmV0dXJuIHJjdV9kZXJlZmVyZW5j
ZV9wcm90ZWN0ZWQocC0+dmxhbl9pbmZvLAorCQkJCQkgcmN1X3JlYWRfbG9ja19oZWxkKCkgfHwK
KwkJCQkJIGxvY2tkZXBfcnRubF9pc19oZWxkKCkpOwogfQogCiAvKiBTaW5jZSBicmlkZ2Ugbm93
IGRlcGVuZHMgb24gODAyMVEgbW9kdWxlLCBidXQgdGhlIHRpbWUgYnJpZGdlIHNlZXMgdGhlCg==
--f46d043c7f0c094cdd051545f810--
