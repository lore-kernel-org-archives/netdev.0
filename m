From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH next 1/6] bonding: Verify RX LACPDU has proper dest mac-addr
Date: Fri, 6 Feb 2015 17:21:46 -0800
Message-ID: <CAHo-OozZTFyAapsssPKk2SmwWHJPSJMH1qhGSZSmHX2m8C6MBQ@mail.gmail.com>
References: <1423270307-9139-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:44054 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899AbbBGBVs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 20:21:48 -0500
Received: by mail-lb0-f173.google.com with SMTP id p9so21097881lbv.4
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 17:21:47 -0800 (PST)
In-Reply-To: <1423270307-9139-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Maciej =C5=BBenczykowski <maze@google.com>

On Fri, Feb 6, 2015 at 4:51 PM, Mahesh Bandewar <maheshb@google.com> wr=
ote:
> The 802.1AX standard states:
> "The DA in LACPDUs is the Slow_Protocols_Multicast address."
>
> This patch enforces that and drops LACPDUs with destination MAC
> addresses other than Slow_Protocols_Multicast address
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_3ad.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bon=
d_3ad.c
> index cfc4a9c1000a..9b436696b95e 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -2485,6 +2485,9 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *=
skb, struct bonding *bond,
>         if (skb->protocol !=3D PKT_TYPE_LACPDU)
>                 return RX_HANDLER_ANOTHER;
>
> +       if (!MAC_ADDRESS_EQUAL(eth_hdr(skb)->h_dest, lacpdu_mcast_add=
r))
> +               return RX_HANDLER_ANOTHER;
> +
>         lacpdu =3D skb_header_pointer(skb, 0, sizeof(_lacpdu), &_lacp=
du);
>         if (!lacpdu)
>                 return RX_HANDLER_ANOTHER;
> --
> 2.2.0.rc0.207.ga3a616c
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
