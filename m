From: "Satoru SATOH" <satoru.satoh@gmail.com>
Subject: Re: [PATCH][IP] Make use of the inline function dst_metric_locked()
Date: Mon, 5 May 2008 12:44:50 +0900
Message-ID: <d72b7ace0805042044n51c57d31ycc4b00991761acfb@mail.gmail.com>
References: <4817C8F5.7060101@gmail.com>
	 <20080429.182443.154118887.davem@davemloft.net>
	 <4817DF2B.1080701@gmail.com> <4817F140.7000302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_14770_8236580.1209959090090"
Cc: netdev@vger.kernel.org, "David Miller" <davem@davemloft.net>
To: "Wang Chen" <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:29528 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757924AbYEEDou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 23:44:50 -0400
Received: by wf-out-1314.google.com with SMTP id 27so973475wfd.4
        for <netdev@vger.kernel.org>; Sun, 04 May 2008 20:44:50 -0700 (PDT)
In-Reply-To: <4817F140.7000302@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_14770_8236580.1209959090090
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Thanks for your info.

I don't know the way to fix that problem, so I send it also as an
attachment to be safe.

- satoru

2008/4/30 Wang Chen <wangchen@cn.fujitsu.com>:
> Satoru SATOH said the following on 2008-4-30 10:53:
>
> > # Resend it. I think it fixed.
>  >
>  > I found some parts inline function dst_metric_locked should be used but
>  > not. The following patch fixes these.
>  >
>  > Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>
>  >
>  >  include/net/ip.h |    2 +-
>  >  net/ipv4/route.c |    2 +-
>  >  2 files changed, 2 insertions(+), 2 deletions(-)
>  >
>  > diff --git a/include/net/ip.h b/include/net/ip.h
>  > index 6d7bcd5..3b40bc2 100644
>  > --- a/include/net/ip.h
>  > +++ b/include/net/ip.h
>  > @@ -210,7 +210,7 @@ int ip_dont_fragment(struct sock *sk, struct
>  > dst_entry *dst)
>  >  {
>  >      return (inet_sk(sk)->pmtudisc == IP_PMTUDISC_DO ||
>
>  Still not fixed.
>  Your mail client converted tab to blank space.
>
>  BTW, you need to send this patch to David and cc to netdev list.
>
>
>
>  >          (inet_sk(sk)->pmtudisc == IP_PMTUDISC_WANT &&
>  > -         !(dst_metric(dst, RTAX_LOCK)&(1<<RTAX_MTU))));
>  > +         !(dst_metric_locked(dst, RTAX_MTU))));
>  >  }
>  >
>  >  extern void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst,
>  > int more);
>  > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>  > index ce25a13..2fd69b5 100644
>  > --- a/net/ipv4/route.c
>  > +++ b/net/ipv4/route.c
>  > @@ -1607,7 +1607,7 @@ static void rt_set_nexthop(struct rtable *rt,
>  > struct fib_result *res, u32 itag)
>  >                 sizeof(rt->u.dst.metrics));
>  >          if (fi->fib_mtu == 0) {
>  >              rt->u.dst.metrics[RTAX_MTU-1] = rt->u.dst.dev->mtu;
>  > -            if (rt->u.dst.metrics[RTAX_LOCK-1] & (1 << RTAX_MTU) &&
>  > +            if (dst_metric_locked(&rt->u.dst, RTAX_MTU) &&
>  >                  rt->rt_gateway != rt->rt_dst &&
>  >                  rt->u.dst.dev->mtu > 576)
>  >                  rt->u.dst.metrics[RTAX_MTU-1] = 576;

------=_Part_14770_8236580.1209959090090
Content-Type: text/x-patch; name=linux-net-2.6-use-dst_metric_locked.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ffuhzm8g0
Content-Disposition: attachment;
 filename=linux-net-2.6-use-dst_metric_locked.patch

IGluY2x1ZGUvbmV0L2lwLmggfCAgICAyICstCiBuZXQvaXB2NC9yb3V0ZS5jIHwgICAgMiArLQog
MiBmaWxlcyBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0t
Z2l0IGEvaW5jbHVkZS9uZXQvaXAuaCBiL2luY2x1ZGUvbmV0L2lwLmgKaW5kZXggNmQ3YmNkNS4u
M2I0MGJjMiAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvaXAuaAorKysgYi9pbmNsdWRlL25ldC9p
cC5oCkBAIC0yMTAsNyArMjEwLDcgQEAgaW50IGlwX2RvbnRfZnJhZ21lbnQoc3RydWN0IHNvY2sg
KnNrLCBzdHJ1Y3QgZHN0X2VudHJ5ICpkc3QpCiB7CiAJcmV0dXJuIChpbmV0X3NrKHNrKS0+cG10
dWRpc2MgPT0gSVBfUE1UVURJU0NfRE8gfHwKIAkJKGluZXRfc2soc2spLT5wbXR1ZGlzYyA9PSBJ
UF9QTVRVRElTQ19XQU5UICYmCi0JCSAhKGRzdF9tZXRyaWMoZHN0LCBSVEFYX0xPQ0spJigxPDxS
VEFYX01UVSkpKSk7CisJCSAhKGRzdF9tZXRyaWNfbG9ja2VkKGRzdCwgUlRBWF9NVFUpKSkpOwog
fQogCiBleHRlcm4gdm9pZCBfX2lwX3NlbGVjdF9pZGVudChzdHJ1Y3QgaXBoZHIgKmlwaCwgc3Ry
dWN0IGRzdF9lbnRyeSAqZHN0LCBpbnQgbW9yZSk7CmRpZmYgLS1naXQgYS9uZXQvaXB2NC9yb3V0
ZS5jIGIvbmV0L2lwdjQvcm91dGUuYwppbmRleCA1ZTM2ODVjLi45MDg0MDU1IDEwMDY0NAotLS0g
YS9uZXQvaXB2NC9yb3V0ZS5jCisrKyBiL25ldC9pcHY0L3JvdXRlLmMKQEAgLTE2MTMsNyArMTYx
Myw3IEBAIHN0YXRpYyB2b2lkIHJ0X3NldF9uZXh0aG9wKHN0cnVjdCBydGFibGUgKnJ0LCBzdHJ1
Y3QgZmliX3Jlc3VsdCAqcmVzLCB1MzIgaXRhZykKIAkJICAgICAgIHNpemVvZihydC0+dS5kc3Qu
bWV0cmljcykpOwogCQlpZiAoZmktPmZpYl9tdHUgPT0gMCkgewogCQkJcnQtPnUuZHN0Lm1ldHJp
Y3NbUlRBWF9NVFUtMV0gPSBydC0+dS5kc3QuZGV2LT5tdHU7Ci0JCQlpZiAocnQtPnUuZHN0Lm1l
dHJpY3NbUlRBWF9MT0NLLTFdICYgKDEgPDwgUlRBWF9NVFUpICYmCisJCQlpZiAoZHN0X21ldHJp
Y19sb2NrZWQoJnJ0LT51LmRzdCwgUlRBWF9NVFUpICYmCiAJCQkgICAgcnQtPnJ0X2dhdGV3YXkg
IT0gcnQtPnJ0X2RzdCAmJgogCQkJICAgIHJ0LT51LmRzdC5kZXYtPm10dSA+IDU3NikKIAkJCQly
dC0+dS5kc3QubWV0cmljc1tSVEFYX01UVS0xXSA9IDU3NjsK
------=_Part_14770_8236580.1209959090090--
