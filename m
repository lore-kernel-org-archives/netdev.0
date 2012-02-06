From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH v5 1/5] netdev: ethernet dev_alloc_skb to netdev_alloc_skb
Date: Mon, 6 Feb 2012 23:07:44 +0530
Message-ID: <CA+Dx6HaYkYCB3d8Md-LdEg8ER1qL=Jj1XRPwA9NHHg_LUS-o5A@mail.gmail.com>
References: <cf736034e7bd407297e2ea9fbf247fb410eb7b39.1328445742.git.netdev@pradeepdalvi.com>
	<20120206.114505.1068389709235471266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120206.114505.1068389709235471266.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 6, 2012 at 10:15 PM, David Miller <davem@davemloft.net> wro=
te:
> From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
> Date: Sun, =A05 Feb 2012 18:19:09 +0530
>
>> From: Pradeep A Dalvi <netdev@pradeepdalvi.com>
>>
>> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/=
net/ethernet
>> =A0 - Removed extra skb->dev =3D dev after netdev_alloc_skb
>>
>> Signed-off-by: Pradeep A Dalvi <netdev@pradeepdalvi.com>
>
> Applied, but I had to fix several things up:
>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pkt_len < rx_copybreak=
 && (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pkt_len < rx_copybreak=
 &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 (skb =3D netdev_alloc_skb(dev, pkt_len + 2)) !=3D NULL) {
>
> This is not the correct way to format a multi-line conditional.
>
> All subsequent lines must start at the first column after the initial=
 line's
> openning parenthesis:
>
> =A0 =A0 =A0 =A0if (format_it &&
> =A0 =A0 =A0 =A0 =A0 =A0like_this)
>
> =A0 =A0 =A0 =A0if (not &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0like_this)
>
> To be honest I have no idea what posses people to tab things out in s=
uch
> an incredibly ugly fashion in the first place.
>
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!(lp->rx_skbuff[i] =3D dev_alloc_skb(l=
p->rx_buff_len))) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 lp->rx_skbuff[i] =3D netdev_alloc_skb(dev,=
 lp->rx_buff_len);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!lp->rx_skbuff[i]) {
>
> You properly leave this test alone and keep it as "!foo" yet:
>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if(!(new_skb =3D dev_alloc=
_skb(lp->rx_buff_len))){
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_skb =3D netdev_alloc_s=
kb(dev, lp->rx_buff_len);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new_skb =3D=3D NULL) {
>
> You change this one to the undesirable "=3D=3D NULL" test, don't do t=
hat.
> "!foo" is the canonical and most efficient NULL pointer test.
>
>> - =A0 =A0 =A0skb =3D dev_alloc_skb(pkt_len+2);
>> + =A0 =A0 skb =3D netdev_alloc_skb(dev, pkt_len + 2);
>
> Do not change the indentation in one place when the entire rest of th=
e source
> file uses something else, fixing that would a seperate change from wh=
at you're
> doing.
>
>> - =A0 =A0 =A0 =A0 skb =3D dev_alloc_skb(RX_BUFLEN + 2);
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb =3D netdev_alloc_skb(RX_BUFLEN + 2);
>
> Same problem.

Thanks a lot! I will make note of these points and shall not repeat aga=
in.

Regards,
Pradeep A. Dalvi
