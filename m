From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] cls_rsvp: add sanity check for the packet length
Date: Wed, 4 Aug 2010 21:52:53 +0800
Message-ID: <AANLkTiksAahqvgawQF7waw61jPwsiw7ptR_ozmc4CimV@mail.gmail.com>
References: <1280912124-30374-1-git-send-email-xiaosuo@gmail.com>
	<1280929327.5669.10.camel@bigi> <AANLkTinW6zSEWQZVVz=utH1zqL_+bRStT7a_Pdx5-705@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47500 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757700Ab0HDNxP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 09:53:15 -0400
Received: by wwj40 with SMTP id 40so6467851wwj.1
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 06:53:13 -0700 (PDT)
In-Reply-To: <AANLkTinW6zSEWQZVVz=utH1zqL_+bRStT7a_Pdx5-705@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 4, 2010 at 9:44 PM, Changli Gao <xiaosuo@gmail.com> wrote:
> On Wed, Aug 4, 2010 at 9:42 PM, jamal <hadi@cyberus.ca> wrote:
>> On Wed, 2010-08-04 at 16:55 +0800, Changli Gao wrote:
>>> The packet length should be checked before the packet data is deref=
erenced.
>>>
>>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>>> ---
>>> =A0net/sched/cls_rsvp.h | =A0 10 +++++++++-
>>> =A01 file changed, 9 insertions(+), 1 deletion(-)
>>> diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
>>> index dd9414e..4fa119d 100644
>>> --- a/net/sched/cls_rsvp.h
>>> +++ b/net/sched/cls_rsvp.h
>>> @@ -143,9 +143,17 @@ static int rsvp_classify(struct sk_buff *skb, =
struct tcf_proto *tp,
>>> =A0 =A0 =A0 u8 tunnelid =3D 0;
>>> =A0 =A0 =A0 u8 *xprt;
>>> =A0#if RSVP_DST_LEN =3D=3D 4
>>> - =A0 =A0 struct ipv6hdr *nhptr =3D ipv6_hdr(skb);
>>> + =A0 =A0 struct ipv6hdr *nhptr;
>>> +
>>> + =A0 =A0 if (!pskb_may_pull(skb, skb_network_offset(skb) + sizeof(=
*nhptr)))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>>> + =A0 =A0 nhptr =3D ipv6_hdr(skb);
>>> =A0#else
>>> =A0 =A0 =A0 struct iphdr *nhptr =3D ip_hdr(skb);
>>> +
>>> + =A0 =A0 if (!pskb_may_pull(skb, skb_network_offset(skb) + sizeof(=
*nhptr)))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>>> + =A0 =A0 nhptr =3D ip_hdr(skb);
>>> =A0#endif
>>
>> Maybe a good time to move nhptr declaration outside #if since it is =
used
>> in #else as well.
>>
>
> They are not the same type. I am afraid that it won't work.
>

I'll respin it with the routine pskb_network_may_pull(). Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
