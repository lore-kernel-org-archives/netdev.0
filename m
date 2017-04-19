From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Wed, 19 Apr 2017 18:12:32 +0200
Message-ID: <CAAeHK+zZb=K4X9=NmSWQJL8bpgMbXoG+h4RasAyYDr+C5pkVYA@mail.gmail.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <CACT4Y+aomj0W8M9JNr1GLsT8EFFHV9YsOTYzWkvwKZANE9hiBQ@mail.gmail.com>
 <CACT4Y+aDzAYs9mbNGeFEkYSB2wTwomZTGEKn4hDH0PAb4uiLqw@mail.gmail.com>
 <2b60b1b8-4766-0e36-f6fb-79914bf1925d@cumulusnetworks.com>
 <CACT4Y+YpUZ+7f5bzPh1hATwUXaZaPTu4rYYdz0RY1MHA1WG3SA@mail.gmail.com>
 <328b1fa7-2d97-6ae3-3b87-e33a0d564ad9@cumulusnetworks.com>
 <CACT4Y+aQFe+M=ESuShQ4FYNWAd8CNEQ=0rW+aAB0P-tp=PpFyQ@mail.gmail.com>
 <CACT4Y+aQgM=9QMkyfcXF2B5gGidvL07JP_m_inNXTPXU22i=aA@mail.gmail.com>
 <CACT4Y+Yx1cgWCkC2c7bze1V1VaecgBfioMvKS2-FUeaRr4DGXg@mail.gmail.com>
 <CACT4Y+bcMz13ad2kLaZGvct5sQ+RDki0StnOEbz3exAa8=zxqQ@mail.gmail.com>
 <CACT4Y+Z6f4aOxMZW44WXdYEyDJbGBYLnjKsHBXfK800h+EkrxA@mail.gmail.com>
 <2270c1ca-9481-60c1-9c29-87669223bded@cumulusnetworks.com>
 <CACT4Y+aUROZgAczRfntp5Rgvzcypviz5ZWBPdE6MWSiO0-3jEg@mail.gmail.com>
 <CAAeHK+zx6W_yxnoEQ2Pc1AT4uLXqYZaoi5oQBeuCntdGS38TQg@mail.gmail.com> <580392d8-fa33-67bb-c5d6-27d262f1646a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=94eb2c14f844c66e2d054d874a02
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <580392d8-fa33-67bb-c5d6-27d262f1646a@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--94eb2c14f844c66e2d054d874a02
Content-Type: text/plain; charset=UTF-8

On Wed, Apr 19, 2017 at 6:09 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 4/18/17 2:43 PM, Andrey Konovalov wrote:
>> Hi!
>>
>> I've finally managed to reproduce one of the crashes on commit
>> 4f7d029b9bf009fbee76bb10c0c4351a1870d2f3 (4.11-rc7).
>>
>> I'm not sure if this bug has the same root cause as the first one
>> reported in this thread, but it definitely has to do with ipv6
>> routing.
>>
>> C reproducer, syzkaller program and my .config are attached.
>
> built a kernel with that config. booted the vm. ran the program. nada.
>
> strace is showing:
>
> clone(child_stack=0x72ffb0,
> flags=CLONE_NEWUTS|CLONE_NEWUSER|CLONE_NEWPID|CLONE_NEWNET) = -1 EINVAL
> (Invalid argument)
>

That's weird. I usually see this when I have CONFIG_USER_NS disabled.

Anyway, I just finished simplifying the reproducer. Give this one a try.

--94eb2c14f844c66e2d054d874a02
Content-Type: text/x-csrc; charset=US-ASCII; name="ip6_rt_cache_alloc-crash-poc2.c"
Content-Disposition: attachment; filename="ip6_rt_cache_alloc-crash-poc2.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j1p6erso0

I2luY2x1ZGUgPHN5cy9pb2N0bC5oPgojaW5jbHVkZSA8c3lzL21tYW4uaD4KI2luY2x1ZGUgPHN5
cy9tb3VudC5oPgojaW5jbHVkZSA8c3lzL3ByY3RsLmg+CiNpbmNsdWRlIDxzeXMvcmVzb3VyY2Uu
aD4KI2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4KI2luY2x1ZGUgPHN5cy9zdGF0Lmg+CiNpbmNsdWRl
IDxzeXMvc3lzY2FsbC5oPgojaW5jbHVkZSA8c3lzL3RpbWUuaD4KI2luY2x1ZGUgPHN5cy90eXBl
cy5oPgojaW5jbHVkZSA8c3lzL3dhaXQuaD4KCiNpbmNsdWRlIDxsaW51eC9jYXBhYmlsaXR5Lmg+
CiNpbmNsdWRlIDxsaW51eC9pZi5oPgojaW5jbHVkZSA8bGludXgvaWZfdHVuLmg+CiNpbmNsdWRl
IDxsaW51eC9rdm0uaD4KI2luY2x1ZGUgPGxpbnV4L3NjaGVkLmg+CiNpbmNsdWRlIDxuZXQvaWZf
YXJwLmg+CiNpbmNsdWRlIDxuZXRpbmV0L2luLmg+CiNpbmNsdWRlIDxsaW51eC9pcHY2X3JvdXRl
Lmg+CgojaW5jbHVkZSA8YXNzZXJ0Lmg+CiNpbmNsdWRlIDxkaXJlbnQuaD4KI2luY2x1ZGUgPGVy
cm5vLmg+CiNpbmNsdWRlIDxmY250bC5oPgojaW5jbHVkZSA8Z3JwLmg+CiNpbmNsdWRlIDxwdGhy
ZWFkLmg+CiNpbmNsdWRlIDxzZXRqbXAuaD4KI2luY2x1ZGUgPHNpZ25hbC5oPgojaW5jbHVkZSA8
c3RkYXJnLmg+CiNpbmNsdWRlIDxzdGRib29sLmg+CiNpbmNsdWRlIDxzdGRkZWYuaD4KI2luY2x1
ZGUgPHN0ZGludC5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN0ZGxpYi5oPgojaW5j
bHVkZSA8c3RyaW5nLmg+CiNpbmNsdWRlIDx1bmlzdGQuaD4KCnZvaWQgbG9vcCgpIHsKCWludCBz
MCA9IHNvY2tldChBRl9JTkVUNiwgU09DS19TVFJFQU0sIDB4ODQpOwoKCXN0cnVjdCBpbjZfcnRt
c2cgcnRtc2c7CgltZW1zZXQoJnJ0bXNnLnJ0bXNnX2RzdCwgMCwgc2l6ZW9mKHJ0bXNnLnJ0bXNn
X2RzdCkpOwoJcnRtc2cucnRtc2dfc3JjID0gaW42YWRkcl9sb29wYmFjazsKCW1lbXNldCgmcnRt
c2cucnRtc2dfZ2F0ZXdheSwgMCwgc2l6ZW9mKHJ0bXNnLnJ0bXNnX2dhdGV3YXkpKTsKCXJ0bXNn
LnJ0bXNnX3R5cGUgPSAweDQ7CglydG1zZy5ydG1zZ19kc3RfbGVuID0gMHgwMDAwOwoJcnRtc2cu
cnRtc2dfc3JjX2xlbiA9IDB4NzsKCXJ0bXNnLnJ0bXNnX21ldHJpYyA9IDB4MTAwOwoJcnRtc2cu
cnRtc2dfaW5mbyA9IDB4ODAwMDAwMDE7CglydG1zZy5ydG1zZ19mbGFncyA9IDB4NDAwMDAwMDA7
CglydG1zZy5ydG1zZ19pZmluZGV4ID0gaWZfbmFtZXRvaW5kZXgoImdyZTAiKTsKCWlvY3RsKHMw
LCBTSU9DQUREUlQsICZydG1zZyk7CgoJaW50IHMxID0gc29ja2V0KEFGX0lORVQ2LCBTT0NLX1JB
V3xTT0NLX05PTkJMT0NLLCBJUFBST1RPX1JBVyk7CgoJc3RydWN0IHNvY2thZGRyX2luNiBzaTsK
CW1lbXNldCgmc2ksIDAsIHNpemVvZihzaSkpOwoJY2hhciBidWZmZXJbMV07CglzZW5kdG8oczEs
ICZidWZmZXJbMF0sIDAsIE1TR19DT05GSVJNLCAoY29uc3Qgc3RydWN0IHNvY2thZGRyICopJnNp
LCBzaXplb2Yoc2kpKTsKfQoKaW50IG1haW4oKSB7Cgl1bnNoYXJlKENMT05FX05FV1VTRVIpOwoJ
dW5zaGFyZShDTE9ORV9ORVdORVQpOwoKCWxvb3AoKTsKCglyZXR1cm4gMDsKfQo=
--94eb2c14f844c66e2d054d874a02--
