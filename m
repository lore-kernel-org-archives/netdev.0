From: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: pmtu discovery on SA
Date: Wed, 18 Jul 2007 21:39:33 +0300
Message-ID: <469E5E65.7070902@kolumbus.fi>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local> <469BB50C.10203@trash.net> <469CE9E5.7040003@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local> <469D3885.7070208@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230254@exch.facton.local> <469E1242.3050105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230257@exch.facton.local> <469E3F6F.6040004@trash.net> <469E465A.9000902@kolumbus.fi> <469E5BA0.6030200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Beschorner Daniel <Daniel.Beschorner@facton.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:49703 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761660AbXGRSle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 14:41:34 -0400
In-Reply-To: <469E5BA0.6030200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Mika Penttil=E4 wrote:
>  =20
>> Patrick McHardy wrote:
>>
>>    =20
>>> Its a debugging message nowadays (NETDEBUG). I was mostly intereste=
d
>>> in this since I changed the IPsec MTU calculation in 2.6.22 and it
>>> might have been a bug.
>>>
>>>  =20
>>>      =20
>> And we don't have pmtu discovery for esp yet, right?
>>    =20
>
>
> We do. The best I have seen to date in any IPsec implementation :)
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>  =20
Hmm. esp4_err() looks like this :

    struct iphdr *iph =3D (struct iphdr*)skb->data;
    struct ip_esp_hdr *esph =3D (struct ip_esp_hdr*)(skb->data+(iph->ih=
l<<2));
    struct xfrm_state *x;

    if (icmp_hdr(skb)->type !=3D ICMP_DEST_UNREACH ||
        icmp_hdr(skb)->code !=3D ICMP_FRAG_NEEDED)
        return;

    x =3D xfrm_state_lookup((xfrm_address_t *)&iph->daddr, esph->spi,=20
IPPROTO_ESP, AF_INET);
    if (!x)
        return;
    NETDEBUG(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%08x\n",
         ntohl(esph->spi), ntohl(iph->daddr));
    xfrm_state_put(x);



where could pmtu discovery be happening?

--Mika

