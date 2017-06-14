From: David Ahern <dsahern@gmail.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Tue, 13 Jun 2017 20:27:20 -0600
Message-ID: <3230b360-528b-0ae0-8731-7906e57ee993@gmail.com>
References: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
 <a5733c67-e3a3-9cc0-0862-40ef6fc03de3@gmail.com>
 <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <da189b9d-760f-0591-2acf-1a6b7910e227@gmail.com>
 <1496809166.736.25.camel@edumazet-glaptop3.roam.corp.google.com>
 <94bcc041-6402-d0ce-b9cf-3b46aa622f34@candelatech.com>
 <CAM_iQpXM3G=J0tw=n1_mKno=i41Kmoxb00+nDyBWofWskj5P_A@mail.gmail.com>
 <7e0c97fa-cd6e-ed0f-bf99-0e4af40fbd2f@gmail.com>
 <1497043557.736.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <9cb61ef0-37c0-8f35-bb5c-e3d8e63cbe2f@candelatech.com>
 <CAM_iQpV8u=aqn-AjeRw8CKQ=0Q6_gBvCCaYi2v3pJbYNL2WhJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------DFC7C3978A65004608A000C6"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33792 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752854AbdFNC1Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 22:27:24 -0400
Received: by mail-pf0-f170.google.com with SMTP id s66so8383441pfs.1
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 19:27:24 -0700 (PDT)
In-Reply-To: <CAM_iQpV8u=aqn-AjeRw8CKQ=0Q6_gBvCCaYi2v3pJbYNL2WhJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------DFC7C3978A65004608A000C6
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 6/13/17 3:42 PM, Cong Wang wrote:
> On Tue, Jun 13, 2017 at 1:16 PM, Ben Greear <greearb@candelatech.com> wrote:
>> On 06/09/2017 02:25 PM, Eric Dumazet wrote:
>>>
>>> On Fri, 2017-06-09 at 07:27 -0600, David Ahern wrote:
>>>>
>>>> On 6/8/17 11:55 PM, Cong Wang wrote:
>>>>> Apparently fn->parent is NULL here for some reason, but
>>>>> I don't know if that is expected or not. If a simple NULL check
>>>>> is not enough here, we have to trace why it is NULL.
>>>>
>>>>
>>>> From my understanding, parent should not be null hence the attempts to
>>>> fix access to table nodes under a lock. ie., figuring out why it is null
>>>> here.
>>
>>
>> If someone has more suggestions, I'll be happy to test.
> 
> Can you enable RT6_TRACE() by changing RT6_DEBUG
> from 2 to 3? We may collect some useful log with it.
> 
> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> index d4bf2c6..1941595 100644
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
> @@ -37,7 +37,7 @@
>  #include <net/ip6_fib.h>
>  #include <net/ip6_route.h>
> 
> -#define RT6_DEBUG 2
> +#define RT6_DEBUG 3
> 
>  #if RT6_DEBUG >= 3
>  #define RT6_TRACE(x...) pr_debug(x)
> 

Let's try a targeted debug patch. See attached

--------------DFC7C3978A65004608A000C6
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="fib6-walk-debug.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="fib6-walk-debug.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L2lwNl9maWIuYyBiL25ldC9pcHY2L2lwNl9maWIuYwpp
bmRleCBkZWVhOTAxNzQ2YzguLjM2N2YxMjg0ZjA1YiAxMDA2NDQKLS0tIGEvbmV0L2lwdjYv
aXA2X2ZpYi5jCisrKyBiL25ldC9pcHY2L2lwNl9maWIuYwpAQCAtMTM5Niw2ICsxMzk2LDgg
QEAgc3RhdGljIHN0cnVjdCBmaWI2X25vZGUgKmZpYjZfcmVwYWlyX3RyZWUoc3RydWN0IG5l
dCAqbmV0LAogCQkJCQkJUlQ2X1RSQUNFKCJXICVwIGFkanVzdGVkIGJ5IGRlbG5vZGUgMiwg
cz0lZFxuIiwgdywgdy0+c3RhdGUpOwogCQkJCQkJdy0+c3RhdGUgPSB3LT5zdGF0ZSA+PSBG
V1NfQyA/IEZXU19VIDogRldTX0lOSVQ7CiAJCQkJCX0KKwkJCQkJaWYgKHctPnN0YXRlID09
IEZXU19VKQorCQkJCQkJcHJfd2FybigiZmliNl9yZXBhaXJfdHJlZTogVyAlcCBhZGp1c3Rl
ZCBieSBkZWxub2RlIDIsIHN0YXRlIEZXU19VXG4iLCB3LCB3LT5zdGF0ZSk7CiAJCQkJfQog
CQkJfQogCQl9CkBAIC0xNDQ3LDggKzE0NDksMTAgQEAgc3RhdGljIHZvaWQgZmliNl9kZWxf
cm91dGUoc3RydWN0IGZpYjZfbm9kZSAqZm4sIHN0cnVjdCBydDZfaW5mbyAqKnJ0cCwKIAkJ
aWYgKHctPnN0YXRlID09IEZXU19DICYmIHctPmxlYWYgPT0gcnQpIHsKIAkJCVJUNl9UUkFD
RSgid2Fsa2VyICVwIGFkanVzdGVkIGJ5IGRlbHJvdXRlXG4iLCB3KTsKIAkJCXctPmxlYWYg
PSBydC0+ZHN0LnJ0Nl9uZXh0OwotCQkJaWYgKCF3LT5sZWFmKQorCQkJaWYgKCF3LT5sZWFm
KSB7CisJCQkJcHJfd2FybigiZmliNl9kZWxfcm91dGU6IHdhbGtlciAlcCBhZGp1c3RlZCBi
eSBkZWxyb3V0ZSAtIHN0YXRlIEZXU19VXG4iLCB3KTsKIAkJCQl3LT5zdGF0ZSA9IEZXU19V
OworCQkJfQogCQl9CiAJfQogCXJlYWRfdW5sb2NrKCZuZXQtPmlwdjYuZmliNl93YWxrZXJf
bG9jayk7CkBAIC0xNTkxLDYgKzE1OTUsNyBAQCBzdGF0aWMgaW50IGZpYjZfd2Fsa19jb250
aW51ZShzdHJ1Y3QgZmliNl93YWxrZXIgKncpCiAJCQkJY29udGludWU7CiAJCQl9CiBza2lw
OgorCQkJcHJfd2FybigiZmliNl93YWxrX2NvbnRpbnVlOiBzZXQgc3RhdGUgdG8gRldTX1Vc
biIpOwogCQkJdy0+c3RhdGUgPSBGV1NfVTsKIAkJY2FzZSBGV1NfVToKIAkJCWlmIChmbiA9
PSB3LT5yb290KQo=
--------------DFC7C3978A65004608A000C6--
