From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 1/2] tg3: Fix NETIF_F_LOOPBACK error
Date: Thu, 19 May 2011 18:15:18 -0700
Message-ID: <BANLkTi==K_eTcqQ39HwcBcg9AyuMLuhz6w@mail.gmail.com>
References: <1305853864-2135-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:43801 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933379Ab1ETBPz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 21:15:55 -0400
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p4K1FsTH010701
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 18:15:54 -0700
Received: from bwg12 (bwg12.prod.google.com [10.188.7.12])
	by hpaq11.eem.corp.google.com with ESMTP id p4K1Fcm4017983
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 18:15:38 -0700
Received: by bwg12 with SMTP id 12so2769903bwg.26
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 18:15:38 -0700 (PDT)
In-Reply-To: <1305853864-2135-2-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2011 at 6:11 PM, Matt Carlson <mcarlson@broadcom.com> w=
rote:
> Mahesh Bandewar noticed that the features cleanup in commit
> 0da0606f493c5cdab74bdcc96b12f4305ad94085, entitled
> "tg3: Consolidate all netdev feature assignments", mistakenly sets
> NETIF_F_LOOPBACK by default. =A0This patch corrects the error.
>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> ---
> =A0drivers/net/tg3.c | =A0 =A03 ++-
> =A01 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 012ce70..0b78c5d 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -15080,6 +15080,8 @@ static int __devinit tg3_init_one(struct pci_=
dev *pdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0features |=3D NETIF_F_=
TSO_ECN;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 dev->features |=3D features;
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Add loopback capability only for a subset of device=
s that support
> =A0 =A0 =A0 =A0 * MAC-LOOPBACK. Eventually this need to be enhanced t=
o allow INT-PHY
> @@ -15090,7 +15092,6 @@ static int __devinit tg3_init_one(struct pci_=
dev *pdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Add the loopback capability */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0features |=3D NETIF_F_LOOPBACK;
>
> - =A0 =A0 =A0 dev->features |=3D features;
> =A0 =A0 =A0 =A0dev->hw_features |=3D features;
> =A0 =A0 =A0 =A0dev->vlan_features |=3D features;
I think this line should go up too. Otherwise newly created vlan
device(s) will have spurious loopback bit set.
>
> --
> 1.7.3.4
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
