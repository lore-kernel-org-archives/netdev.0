From: =?UTF-8?Q?Vicente_Jim=C3=A9nez?= <googuy@gmail.com>
Subject: Re: [Regression w/ patch] Restore network resistance to weird ICMP messages
Date: Thu, 10 Nov 2016 11:52:01 +0100
Message-ID: <CAO1wt+aZ-vkP0e43oSvxWR-rNXKfbPFh1P=Shkn6x_rCczmX1A@mail.gmail.com>
References: <CAO1wt+Y7JfeCXnrR5BeZ7K6dErmB3nfdA4mRkFQ21S=VPCkLXg@mail.gmail.com>
 <20161109.202210.1450575682716819324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1130d266da0d650540f029aa
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34944 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754796AbcKJKwD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 05:52:03 -0500
In-Reply-To: <20161109.202210.1450575682716819324.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a1130d266da0d650540f029aa
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Corrected patch attached.
Thanks for the advices.
I was unaware of those style policies.

On Thu, Nov 10, 2016 at 2:22 AM, David Miller <davem@davemloft.net> wrote:
> From: Vicente Jim=C3=A9nez <googuy@gmail.com>
> Date: Mon, 7 Nov 2016 12:11:59 +0100
>
>> From bfc9a00e6b78d8eb60e46dacd7d761669d29a573 Mon Sep 17 00:00:00 2001
>> From: Vicente Jimenez Aguilar <googuy@gmail.com>
>> Date: Mon, 31 Oct 2016 13:10:29 +0100
>> Subject: [PATCH] ipv4: icmp: Fix pMTU handling for rarest case
>>
>> Restore network resistance to weird ICMP fragmentation needed messages
>> with next hop MTU equal to (or exceeding) dropped packet size
>>
>> Fixes: 46517008e116 ("ipv4: Kill ip_rt_frag_needed().")
>> Signed-off-by: Vicente Jimenez Aguilar <googuy@gmail.com>
>> ---
>>  net/ipv4/icmp.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
>> index 38abe70..c0af1d2 100644
>> --- a/net/ipv4/icmp.c
>> +++ b/net/ipv4/icmp.c
>> @@ -776,6 +776,7 @@ static bool icmp_unreach(struct sk_buff *skb)
>>       struct icmphdr *icmph;
>>       struct net *net;
>>       u32 info =3D 0;
>> +     unsigned short old_mtu;
>>
>>       net =3D dev_net(skb_dst(skb)->dev);
>>
>
> Order local variable declarations from longest to shortest line
> please.
>
>> +                             if ( info >=3D old_mtu )
>
> There should be no space after the '(' and before the ')' in this
> conditional.



--=20
saludos
vicente

--001a1130d266da0d650540f029aa
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-ipv4-icmp-Fix-pMTU-handling-for-rarest-case.patch"
Content-Disposition: attachment;
	filename="0001-ipv4-icmp-Fix-pMTU-handling-for-rarest-case.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ivc8drtr0

RnJvbSA4OGFjNDlmYTI4N2UyZTBkM2QzYmM4MDVkZWExZmVjMzAxYWFkMWRmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBWaWNlbnRlIEppbWVuZXogQWd1aWxhciA8Z29vZ3V5QGdtYWls
LmNvbT4KRGF0ZTogTW9uLCAzMSBPY3QgMjAxNiAxMzoxMDoyOSArMDEwMApTdWJqZWN0OiBbUEFU
Q0hdIGlwdjQ6IGljbXA6IEZpeCBwTVRVIGhhbmRsaW5nIGZvciByYXJlc3QgY2FzZQoKUmVzdG9y
ZSBuZXR3b3JrIHJlc2lzdGFuY2UgdG8gd2VpcmQgSUNNUCBmcmFnbWVudGF0aW9uIG5lZWRlZCBt
ZXNzYWdlcwp3aXRoIG5leHQgaG9wIE1UVSBlcXVhbCB0byAob3IgZXhjZWVkaW5nKSBkcm9wcGVk
IHBhY2tldCBzaXplCgpGaXhlczogNDY1MTcwMDhlMTE2ICgiaXB2NDogS2lsbCBpcF9ydF9mcmFn
X25lZWRlZCgpLiIpClNpZ25lZC1vZmYtYnk6IFZpY2VudGUgSmltZW5leiBBZ3VpbGFyIDxnb29n
dXlAZ21haWwuY29tPgotLS0KIG5ldC9pcHY0L2ljbXAuYyB8IDcgKysrKysrKwogMSBmaWxlIGNo
YW5nZWQsIDcgaW5zZXJ0aW9ucygrKQoKZGlmZiAtLWdpdCBhL25ldC9pcHY0L2ljbXAuYyBiL25l
dC9pcHY0L2ljbXAuYwppbmRleCAzOGFiZTcwLi40YzkwZDc2IDEwMDY0NAotLS0gYS9uZXQvaXB2
NC9pY21wLmMKKysrIGIvbmV0L2lwdjQvaWNtcC5jCkBAIC03NzMsNiArNzczLDcgQEAgc3RhdGlj
IGJvb2wgaWNtcF90YWdfdmFsaWRhdGlvbihpbnQgcHJvdG8pCiBzdGF0aWMgYm9vbCBpY21wX3Vu
cmVhY2goc3RydWN0IHNrX2J1ZmYgKnNrYikKIHsKIAljb25zdCBzdHJ1Y3QgaXBoZHIgKmlwaDsK
Kwl1bnNpZ25lZCBzaG9ydCBvbGRfbXR1OwogCXN0cnVjdCBpY21waGRyICppY21waDsKIAlzdHJ1
Y3QgbmV0ICpuZXQ7CiAJdTMyIGluZm8gPSAwOwpAQCAtODE5LDYgKzgyMCwxMiBAQCBzdGF0aWMg
Ym9vbCBpY21wX3VucmVhY2goc3RydWN0IHNrX2J1ZmYgKnNrYikKIAkJCQkvKiBmYWxsIHRocm91
Z2ggKi8KIAkJCWNhc2UgMDoKIAkJCQlpbmZvID0gbnRvaHMoaWNtcGgtPnVuLmZyYWcubXR1KTsK
KwkJCQkvKiBIYW5kbGUgd2VpcmQgY2FzZSB3aGVyZSBuZXh0IGhvcCBNVFUgaXMKKwkJCQkgKiBl
cXVhbCB0byBvciBleGNlZWRpbmcgZHJvcHBlZCBwYWNrZXQgc2l6ZQorCQkJCSAqLworCQkJCW9s
ZF9tdHUgPSBudG9ocyhpcGgtPnRvdF9sZW4pOworCQkJCWlmIChpbmZvID49IG9sZF9tdHUpCisJ
CQkJCWluZm8gPSBvbGRfbXR1IC0gMjsKIAkJCX0KIAkJCWJyZWFrOwogCQljYXNlIElDTVBfU1Jf
RkFJTEVEOgotLSAKMi43LjMKCg==
--001a1130d266da0d650540f029aa--
