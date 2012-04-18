From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid expensive pskb_expand_head() calls
Date: Wed, 18 Apr 2012 12:41:42 -0700
Message-ID: <CAGK4HS-jrsy2kxJUeYo+JR9CBfOFqyzBgqa+OzC85yQbaWmFoA@mail.gmail.com>
References: <1334653608.6226.11.camel@edumazet-laptop>
	<1334654187.2696.2.camel@jtkirshe-mobl>
	<4F8D93E1.9090000@intel.com>
	<1334681204.2472.41.camel@edumazet-glaptop>
	<1334698722.2472.71.camel@edumazet-glaptop>
	<1334764184.2472.299.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:42091 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066Ab2DRTln convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 15:41:43 -0400
Received: by vcqp1 with SMTP id p1so5125028vcq.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 12:41:42 -0700 (PDT)
In-Reply-To: <1334764184.2472.299.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> =A0{
> =A0 =A0 =A0 =A0if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP=
_ATOMIC))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> @@ -1134,6 +1138,7 @@ int tcp_trim_head(struct sock *sk, struct sk_bu=
ff *skb, u32 len)
> =A0 =A0 =A0 =A0__pskb_trim_head(skb, len);
>
> =A0 =A0 =A0 =A0TCP_SKB_CB(skb)->seq +=3D len;
> + =A0 =A0 =A0 TCP_SKB_CB(skb)->header.offset_ack =3D 0;
> =A0 =A0 =A0 =A0skb->ip_summed =3D CHECKSUM_PARTIAL;
>
> =A0 =A0 =A0 =A0skb->truesize =A0 =A0 =A0 =A0-=3D len;
>

Eric,
tcp_trim_head() also updates skb->truesize as above. But is this the
right thing to do when only offsets/pointers are updated. If
__pskb_trim_head() removes len bytes but does not actually free
memory,
should truesize be updated?  This could happen if data in the linear
part is acked.  This behavior takes place currently even without your
patch, by the way.


Thanks,
Vijay
