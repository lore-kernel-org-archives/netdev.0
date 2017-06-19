From: "Belgazal, Netanel" <netanel@amazon.com>
Subject: Re: [PATCH net-next 10/13] net: ena: add mtu limitation in
 ena_change_mtu()
Date: Mon, 19 Jun 2017 12:26:08 +0000
Message-ID: <1497875168290.26033@amazon.com>
References: <1497785298-13468-1-git-send-email-netanel@amazon.com>
        <1497785298-13468-11-git-send-email-netanel@amazon.com>,<20170618.122103.1131376179675660541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Woodhouse, David" <dwmw@amazon.co.uk>,
        "Machulsky, Zorik" <zorik@amazon.com>,
        "Matushevsky, Alexander" <matua@amazon.com>,
        "BSHARA, Said" <saeedb@amazon.com>,
        "Wilson, Matt" <msw@amazon.com>,
        "Liguori, Anthony" <aliguori@amazon.com>,
        "Bshara, Nafea" <nafea@amazon.com>,
        "Schmeilin, Evgeny" <evgenys@amazon.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-6002.amazon.com ([52.95.49.90]:29892 "EHLO
        smtp-fw-6002.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753669AbdFSM0R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 08:26:17 -0400
In-Reply-To: <20170618.122103.1131376179675660541.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'll discard this patch.=0A=
________________________________________=0A=
From: David Miller <davem@davemloft.net>=0A=
Sent: Sunday, June 18, 2017 7:21 PM=0A=
To: Belgazal, Netanel=0A=
Cc: netdev@vger.kernel.org; Woodhouse, David; Machulsky, Zorik; Matushevsky=
, Alexander; BSHARA, Said; Wilson, Matt; Liguori, Anthony; Bshara, Nafea; S=
chmeilin, Evgeny=0A=
Subject: Re: [PATCH net-next 10/13] net: ena: add mtu limitation in ena_cha=
nge_mtu()=0A=
=0A=
From: <netanel@amazon.com>=0A=
Date: Sun, 18 Jun 2017 14:28:15 +0300=0A=
=0A=
> From: Netanel Belgazal <netanel@amazon.com>=0A=
>=0A=
> Signed-off-by: Netanel Belgazal <netanel@amazon.com>=0A=
=0A=
I don't understand this at all.=0A=
=0A=
This whole reason we have those:=0A=
=0A=
> @@ -3008,8 +3015,6 @@ static void ena_set_conf_feat_params(struct ena_ada=
pter *adapter,=0A=
>       ena_set_dev_offloads(feat, netdev);=0A=
>=0A=
>       adapter->max_mtu =3D feat->dev_attr.max_mtu;=0A=
> -     netdev->max_mtu =3D adapter->max_mtu;=0A=
> -     netdev->min_mtu =3D ENA_MIN_MTU;=0A=
>  }=0A=
>=0A=
=0A=
assignments you are removing is so that the core networking can=0A=
validate the request and therefore individual drivers don't have to.=0A=
=0A=
If it's just to get that silly driver message out when the MTU asked=0A=
for is too large, that's not a good reason to bypass the=0A=
infrastructure for MTU changes that we've provided for drivers in the=0A=
core.=0A=
=0A=
I don't like this change at all.=0A=
=0A=
You could have helped things a lot by actually writing a commit log=0A=
message explaining what you are really doing, and why you are doing=0A=
it.  Empty commit log messages are never a good idea.=0A=
