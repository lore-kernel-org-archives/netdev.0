From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,1/3] hv_netvsc: Use per socket hash when
 available
Date: Wed, 12 Apr 2017 16:24:36 +0000
Message-ID: <BLUPR03MB14123B438231A0EFAC4DCBCBCA030@BLUPR03MB1412.namprd03.prod.outlook.com>
References: <1491699241-9944-1-git-send-email-haiyangz@exchange.microsoft.com>
 <20170411.221241.2175639910931847215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        KY Srinivasan <kys@microsoft.com>,
        "olaf@aepfle.de" <olaf@aepfle.de>,
        "vkuznets@redhat.com" <vkuznets@redhat.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0100.outbound.protection.outlook.com ([104.47.37.100]:59744
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754946AbdDLQYk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 12:24:40 -0400
In-Reply-To: <20170411.221241.2175639910931847215.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, April 11, 2017 10:13 PM
> To: Haiyang Zhang <haiyangz@microsoft.com>; Haiyang Zhang
> <haiyangz@microsoft.com>
> Cc: netdev@vger.kernel.org; KY Srinivasan <kys@microsoft.com>;
> olaf@aepfle.de; vkuznets@redhat.com; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH net-next,1/3] hv_netvsc: Use per socket hash when
> available
>=20
> From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
> Date: Sat,  8 Apr 2017 17:53:59 -0700
>=20
> > diff --git a/drivers/net/hyperv/netvsc_drv.c
> b/drivers/net/hyperv/netvsc_drv.c
> > index f24c289..0a129cb 100644
> > --- a/drivers/net/hyperv/netvsc_drv.c
> > +++ b/drivers/net/hyperv/netvsc_drv.c
> > @@ -211,9 +211,14 @@ static u16 netvsc_select_queue(struct net_device
> *ndev, struct sk_buff *skb,
> >  	int q_idx =3D sk_tx_queue_get(sk);
> >
> >  	if (q_idx < 0 || skb->ooo_okay || q_idx >=3D num_tx_queues) {
> > -		u16 hash =3D __skb_tx_hash(ndev, skb, VRSS_SEND_TAB_SIZE);
> > +		u16 hash;
> >  		int new_idx;
> >
> > +		if (sk)
> > +			skb_set_hash_from_sk(skb, sk);
> > +
> > +		hash =3D __skb_tx_hash(ndev, skb, VRSS_SEND_TAB_SIZE);
>=20
> Please do not do this.
>=20
> TCP performs this operation for you for every pack it emits.
>=20
> And also every socket family that uses skb_set_owner_w() either
> directly or indirectly gets this done as well.
>=20
> I do not want to see drivers start to get peppered with calls to this
> thing.
>=20
> Explain the case which is missing that matters, and we can address
> that instead.
>=20
> Thanks.

Thanks for pointing this out. I did some tests, the skb->hash is indeed
set to the sk->sk_txhash by upper layer. I will remove this patch, and
re-submit other patches.

Thanks,
- Haiyang
