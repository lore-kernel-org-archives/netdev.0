From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 17:11:45 +0800
Message-ID: <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com>
References: <4D0DEDF9.7020102@itcare.pl> <1292773433.18869.153.camel@edumazet-laptop>
 <4D0E2E52.3090802@itcare.pl> <AANLkTimMY3D_HssWb=Sw=b3tsxEKACk2QUzFzi-HaC-J@mail.gmail.com>
 <4D0E6C6D.10806@itcare.pl> <4D0E8416.2030100@gmail.com> <4D0E857E.5060302@gmail.com>
 <4D0E868F.90005@gmail.com> <4D0F0D73.2080807@itcare.pl> <AANLkTim1YZd0FgunGKN_YPiLW+uExXajwingUkQeW=a=@mail.gmail.com>
 <1292836097.2800.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>,
	"David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:58575 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435Ab0LTJMH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 04:12:07 -0500
Received: by fxm18 with SMTP id 18so2772007fxm.2
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 01:12:06 -0800 (PST)
In-Reply-To: <1292836097.2800.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 20, 2010 at 5:08 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 20 d=E9cembre 2010 =E0 16:56 +0800, Changli Gao a =E9crit :
>
> This patch cant be right as is.
>
> =A0 =A0 =A0 =A0if (skb_is_gso(skb)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_shared(skb)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *nskb;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nskb =3D skb_clone(skb,=
 GFP_ATOMIC);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!nskb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_skb(skb); // HERE
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D nskb;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> You free original skb, while caller might dereference it later.
> So you must pass cloned skb back to caller.
>
> (line 6393 :)
> =A0count =3D ixgbe_tx_map(adapter, tx_ring, skb, tx_flags, first);
>
>

Yes, you are right. I just wonder where shared skbs are allowed. Is
there any rule?

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
