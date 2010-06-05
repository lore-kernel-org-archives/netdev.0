From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] act_mirred: don't clone skb when skb isn't shared
Date: Sat, 5 Jun 2010 22:58:43 +0800
Message-ID: <AANLkTinRM9oSu8qbRHasrDMLVZ49I-_8YVG7STMshUY-@mail.gmail.com>
References: <1275741553-21463-1-git-send-email-xiaosuo@gmail.com>
	<1275749345.3490.88.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f185.google.com ([209.85.222.185]:42887 "EHLO
	mail-pz0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933305Ab0FEO7E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 10:59:04 -0400
Received: by pzk15 with SMTP id 15so1525931pzk.15
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 07:59:03 -0700 (PDT)
In-Reply-To: <1275749345.3490.88.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 5, 2010 at 10:49 PM, jamal <hadi@cyberus.ca> wrote:
> On Sat, 2010-06-05 at 20:39 +0800, Changli Gao wrote:
>
>> + =A0 =A0 if ((action =3D=3D TC_ACT_SHOT || action =3D=3D TC_ACT_STO=
LEN ||
>
> I am not so sure about SHOT; the other two are fine.

It is unlikely that this function will be called with TC_ACT_SHOT. In
fact, this function has only one user act_mirred. Should we remove
this flag, or keep STOLEN flag only?

>
>> - =A0 =A0 skb2 =3D skb_act_clone(skb, GFP_ATOMIC);
>> + =A0 =A0 at =3D G_TC_AT(skb->tc_verd);
>
> Was there any need to move above line?

skb2 maybe skb, and its tc_verd maybe mangled in skb_act_clone(), so I
move it up.

>
>> + =A0 =A0 skb2 =3D skb_act_clone(skb, GFP_ATOMIC, m->tcf_action);
>
>
>> - =A0 =A0 skb2->dev =3D dev;
>
> Or this one?
>
>> =A0 =A0 =A0 skb2->skb_iif =3D skb->dev->ifindex;
>> + =A0 =A0 skb2->dev =3D dev;
>

the same reason as above. skb2 and skb maybe the same. If we don't
move lines, skb->dev maybe over written.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
