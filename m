From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 2/2] bonding: COW before overwriting the destination MAC address
Date: Thu, 3 Mar 2011 14:54:36 +0800
Message-ID: <AANLkTim3EKe7hqyhpQ97uBn0_8ZFP=ve3RgurQzTpi1b@mail.gmail.com>
References: <1299126321-9300-1-git-send-email-xiaosuo@gmail.com> <1299134742.2456.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37072 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab1CCGy5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 01:54:57 -0500
Received: by fxm17 with SMTP id 17so804894fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 22:54:56 -0800 (PST)
In-Reply-To: <1299134742.2456.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2011 at 2:45 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le jeudi 03 mars 2011 =E0 12:25 +0800, Changli Gao a =E9crit :
>> When there is a ptype handler holding a clone of this skb, whose
>> destination MAC addresse is overwritten, the owner of this handler m=
ay
>> get a corrupted packet.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> =A0drivers/net/bonding/bond_main.c | =A0 =A05 +++++
>> =A01 file changed, 5 insertions(+)
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index 912b416..211be52 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1513,6 +1513,11 @@ static struct sk_buff *bond_handle_frame(stru=
ct sk_buff *skb)
>> =A0 =A0 =A0 =A0 =A0 skb->pkt_type =3D=3D PACKET_HOST) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 *dest =3D (u16 *) eth_hdr(skb)->h_de=
st;
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(skb_cow_head(skb,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 skb->data - skb_mac_header(skb)))) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_skb(skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(dest, bond_dev->dev_addr, ETH_ALE=
N);
>> =A0 =A0 =A0 }
>>
>
> This seems buggy.
>
> dest points to old skb head content.
>
>

Oh, thanks. I'll respin it.



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
