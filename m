From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] bgmac: Remove all offloading features, including GRO.
Date: Fri, 15 Sep 2017 23:04:29 -0700
Message-ID: <0CEBE536-2C18-4ED2-90CB-3836CEF9A70E@gmail.com>
References: <20170916002305.2794-1-rosenp@gmail.com> <1505522096.29839.13.camel@edumazet-glaptop3.roam.corp.google.com> <1505522322.3726.0.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: rosenp@gmail.com, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34683 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdIPGEe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2017 02:04:34 -0400
Received: by mail-oi0-f68.google.com with SMTP id v66so521088oig.1
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 23:04:34 -0700 (PDT)
In-Reply-To: <1505522322.3726.0.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On September 15, 2017 5:38:42 PM PDT, rosenp@gmail=2Ecom wrote:
>I have not=2E Unfortunately I own no gigabit hardware to test this on=2E
>The MIPS CPU runs at 300MHz on my unit=2E
>

bgmac is used on Gigabit capable hardware, like Northstar and Northstar Pl=
us, and others too, so unless you can get access to such HW or get confirma=
tion from someone that your patches changes something, I would just drop th=
is change and not bother=2E This is already not 100mbits/sec linerate=2E=2E=
=2E

>On Fri, 2017-09-15 at 17:34 -0700, Eric Dumazet wrote:
>> On Fri, 2017-09-15 at 17:23 -0700, Rosen Penev wrote:
>> > On a linksys E1200v1 (actually a crossflashed E1000v2), the
>> > offloading features give no measurable benefit to speed or latency=2E
>> > Furthermore, disabling GRO actually improves iperf performance by a
>> > whoppimg 3mbps=2E Results:
>> >=20
>> > Currently:
>> >=20
>> > v2: Changed napi_gro_receive to netif_receive_skb=2E Seems to have an
>> > identical result=2E
>> >=20
>> > Signed-off-by: Rosen Penev <rosenp@gmail=2Ecom>
>> > ---
>> >  drivers/net/ethernet/broadcom/bgmac=2Ec | 2 +-
>> >  1 file changed, 1 insertion(+), 1 deletion(-)
>> >=20
>> > diff --git a/drivers/net/ethernet/broadcom/bgmac=2Ec
>> > b/drivers/net/ethernet/broadcom/bgmac=2Ec
>> > index 48d672b204a4=2E=2E1fb0053aeee7 100644
>> > --- a/drivers/net/ethernet/broadcom/bgmac=2Ec
>> > +++ b/drivers/net/ethernet/broadcom/bgmac=2Ec
>> > @@ -483,7 +483,7 @@ static int bgmac_dma_rx_read(struct bgmac
>> > *bgmac, struct bgmac_dma_ring *ring,
>> >  			skb->protocol =3D eth_type_trans(skb, bgmac-
>> > >net_dev);
>> >  			bgmac->net_dev->stats=2Erx_bytes +=3D len;
>> >  			bgmac->net_dev->stats=2Erx_packets++;
>> > -			napi_gro_receive(&bgmac->napi, skb);
>> > +			netif_receive_skb(skb);
>> >  			handled++;
>> >  		} while (0);
>> > =20
>>=20
>> And have you tested 1Gbit link speed ?
>> ( Or 2=2E5 Gbit link speed )
>>=20
>> If you want to disable GRO on your host, fine : you can use ethtool
>> -K
>>=20
>>=20
>>=20

(please don't top-post)
--=20
Florian
