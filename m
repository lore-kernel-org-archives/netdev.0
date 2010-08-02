From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/4] net: check for reference outside of skb
Date: Tue, 3 Aug 2010 07:11:14 +0800
Message-ID: <AANLkTi=8+xRJn_26740uKuWdgA=XvyB7-hgGT9dxjOXr@mail.gmail.com>
References: <20100802220030.991706005@vyatta.com> <20100802220113.557212477@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47063 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab0HBXLf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:11:35 -0400
Received: by wwj40 with SMTP id 40so4491470wwj.1
        for <netdev@vger.kernel.org>; Mon, 02 Aug 2010 16:11:34 -0700 (PDT)
In-Reply-To: <20100802220113.557212477@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 3, 2010 at 6:00 AM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> It is legitimate for callers of skb_header_pointer to pass a negative
> offset, but the resulting pointer should not go outside the valid
> range of data in the skb.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> --- a/include/linux/skbuff.h =A0 =A02010-08-01 09:23:01.635121262 -07=
00
> +++ b/include/linux/skbuff.h =A0 =A02010-08-01 09:25:27.453901530 -07=
00
> @@ -1853,6 +1853,9 @@ static inline void *skb_header_pointer(c
> =A0{
> =A0 =A0 =A0 =A0int hlen =3D skb_headlen(skb);
>
> + =A0 =A0 =A0 if (hlen + offset < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +

It seems wrong. do you mean

      if (skb_headroom(hlen) + offset < 0)

Nevertheless it is also wrong. skb_header_pointer doesn't know if the
headroom is filled with valid data or not.

Thanks.

> =A0 =A0 =A0 =A0if (hlen - offset >=3D len)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return skb->data + offset;




--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
