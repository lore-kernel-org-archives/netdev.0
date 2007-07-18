From: Patrick McHardy <kaber@trash.net>
Subject: Re: pmtu discovery on SA
Date: Wed, 18 Jul 2007 20:41:22 +0200
Message-ID: <469E5ED2.1060306@trash.net>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local> <469BB50C.10203@trash.net> <469CE9E5.7040003@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local> <469D3885.7070208@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230254@exch.facton.local> <469E1242.3050105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230257@exch.facton.local> <469E3F6F.6040004@trash.net> <469E465A.9000902@kolumbus.fi> <469E5BA0.6030200@trash.net> <469E5E65.7070902@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Beschorner Daniel <Daniel.Beschorner@facton.com>,
	netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45233 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbXGRSog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 14:44:36 -0400
In-Reply-To: <469E5E65.7070902@kolumbus.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mika Penttil=E4 wrote:
> Hmm. esp4_err() looks like this :
>
>    struct iphdr *iph =3D (struct iphdr*)skb->data;
>    struct ip_esp_hdr *esph =3D (struct=20
> ip_esp_hdr*)(skb->data+(iph->ihl<<2));
>    struct xfrm_state *x;
>
>    if (icmp_hdr(skb)->type !=3D ICMP_DEST_UNREACH ||
>        icmp_hdr(skb)->code !=3D ICMP_FRAG_NEEDED)
>        return;
>
>    x =3D xfrm_state_lookup((xfrm_address_t *)&iph->daddr, esph->spi,=20
> IPPROTO_ESP, AF_INET);
>    if (!x)
>        return;
>    NETDEBUG(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%08x\n",
>         ntohl(esph->spi), ntohl(iph->daddr));
>    xfrm_state_put(x);
>
>
>
> where could pmtu discovery be happening?

xfrm_init_pmtu, xfrm_bundle_ok, xfrm_state_mtu, esp4_get_mtu, ...

