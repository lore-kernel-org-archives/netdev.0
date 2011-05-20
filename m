From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 1/2] tg3: Fix NETIF_F_LOOPBACK error
Date: Fri, 20 May 2011 10:56:34 -0700
Message-ID: <BANLkTimUz4eTqcdV4-v2cH6qE0vcRnUXPA@mail.gmail.com>
References: <1305853864-2135-2-git-send-email-mcarlson@broadcom.com>
 <BANLkTi==K_eTcqQ39HwcBcg9AyuMLuhz6w@mail.gmail.com> <20110520015934.GA2258@mcarlson.broadcom.com>
 <BANLkTikO2kW2FBcyjwNuk30B58nbsj9vdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:57197 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab1ETR45 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 13:56:57 -0400
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p4KHuugX007719
	for <netdev@vger.kernel.org>; Fri, 20 May 2011 10:56:56 -0700
Received: from bwz17 (bwz17.prod.google.com [10.188.26.17])
	by wpaz24.hot.corp.google.com with ESMTP id p4KHuifp022388
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 20 May 2011 10:56:55 -0700
Received: by bwz17 with SMTP id 17so4062812bwz.0
        for <netdev@vger.kernel.org>; Fri, 20 May 2011 10:56:55 -0700 (PDT)
In-Reply-To: <BANLkTikO2kW2FBcyjwNuk30B58nbsj9vdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2011 at 11:57 PM, Micha=C5=82 Miros=C5=82aw <mirqus@gma=
il.com> wrote:
> 2011/5/20 Matt Carlson <mcarlson@broadcom.com>:
>> On Thu, May 19, 2011 at 06:15:18PM -0700, Mahesh Bandewar wrote:
>>> On Thu, May 19, 2011 at 6:11 PM, Matt Carlson <mcarlson@broadcom.co=
m> wrote:
>>> > Mahesh Bandewar noticed that the features cleanup in commit
>>> > 0da0606f493c5cdab74bdcc96b12f4305ad94085, entitled
>>> > "tg3: Consolidate all netdev feature assignments", mistakenly set=
s
>>> > NETIF_F_LOOPBACK by default. ?This patch corrects the error.
>>> >
>>> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
>>> > ---
>>> > ?drivers/net/tg3.c | ? ?3 ++-
>>> > ?1 files changed, 2 insertions(+), 1 deletions(-)
>>> >
>>> > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
>>> > index 012ce70..0b78c5d 100644
>>> > --- a/drivers/net/tg3.c
>>> > +++ b/drivers/net/tg3.c
>>> > @@ -15080,6 +15080,8 @@ static int __devinit tg3_init_one(struct =
pci_dev *pdev,
>>> > ? ? ? ? ? ? ? ? ? ? ? ?features |=3D NETIF_F_TSO_ECN;
>>> > ? ? ? ?}
>>> >
>>> > + ? ? ? dev->features |=3D features;
>>> > +
>>> > ? ? ? ?/*
>>> > ? ? ? ? * Add loopback capability only for a subset of devices th=
at support
>>> > ? ? ? ? * MAC-LOOPBACK. Eventually this need to be enhanced to al=
low INT-PHY
>>> > @@ -15090,7 +15092,6 @@ static int __devinit tg3_init_one(struct =
pci_dev *pdev,
>>> > ? ? ? ? ? ? ? ?/* Add the loopback capability */
>>> > ? ? ? ? ? ? ? ?features |=3D NETIF_F_LOOPBACK;
>>> >
>>> > - ? ? ? dev->features |=3D features;
>>> > ? ? ? ?dev->hw_features |=3D features;
>>> > ? ? ? ?dev->vlan_features |=3D features;
>>> I think this line should go up too. Otherwise newly created vlan
>>> device(s) will have spurious loopback bit set.
>> Yes. =C2=A0You are right. =C2=A0I thought vlan_features functioned l=
ike
>> hw_features.
>
> Probably NETIF_F_LOOPBACK should be forcibly set on VLAN devices when
> underlying device has it enabled. Just a quick thought for discussion=
=2E
>
I think that's a good idea for the sake of correctness and should be
done when we enable / disable loopback.

--mahesh..

> Best Regards,
> Micha=C5=82 Miros=C5=82aw
>
