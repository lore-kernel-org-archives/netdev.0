From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 3/4] 6lowpan: the two
 bytes of u16 tag needs to be stored/accessed the other way around
Date: Tue, 12 Jun 2012 22:07:12 +0400
Message-ID: <CAJmB2rB20UL_8u1PmJM67dQJ1FaW09irJhz6-OusZwWkgs0kLQ@mail.gmail.com>
References: <20120611003953.0725d77a@dualbox>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Tony Cheneau <tony.cheneauh-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20120611003953.0725d77a@dualbox>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

2012/6/11 Tony Cheneau <tony.cheneauh-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>:
> Or else, tag values, as displayed with a trafic analyser, such a
> Wireshark, are not properly displayed (e.g. 0x01 00 insted of 0x00 01,
> and so on). ---
> =A0net/ieee802154/6lowpan.c | =A0 =A06 +++---
> =A01 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index af4f29b..af2f12e 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -307,7 +307,7 @@ static u16 lowpan_fetch_skb_u16(struct sk_buff *skb)
>
> =A0 =A0 =A0 =A0BUG_ON(!pskb_may_pull(skb, 2));
>
> - =A0 =A0 =A0 ret =3D skb->data[0] | (skb->data[1] << 8);
> + =A0 =A0 =A0 ret =3D (skb->data[0] << 8) | skb->data[1];

This function aimed to obtain u16 from skb, why did you change the
byte-order here instead of 'tag' variable byte-shifting? Will this
code work properly on the both little and big-endian machines? Please
rework this to keep order properly for all the architectures.

> =A0 =A0 =A0 =A0skb_pull(skb, 2);
> =A0 =A0 =A0 =A0return ret;
> =A0}
> @@ -1002,8 +1002,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb)
> =A0 =A0 =A0 =A0/* first fragment header */
> =A0 =A0 =A0 =A0head[0] =3D LOWPAN_DISPATCH_FRAG1 | (payload_length & 0x7);
> =A0 =A0 =A0 =A0head[1] =3D (payload_length >> 3) & 0xff;
> - =A0 =A0 =A0 head[2] =3D tag & 0xff;
> - =A0 =A0 =A0 head[3] =3D tag >> 8;
> + =A0 =A0 =A0 head[2] =3D tag >> 8;
> + =A0 =A0 =A0 head[3] =3D tag & 0xff;
>
> =A0 =A0 =A0 =A0err =3D lowpan_fragment_xmit(skb, head, header_length, 0, =
0);
>
> --
> 1.7.3.4
>
>

---------------------------------------------------------------------------=
---
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and =

threat landscape has changed and how IT managers can respond. Discussions =

will include endpoint security, mobile security and the latest in malware =

threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
