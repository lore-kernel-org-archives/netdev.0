From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: RE: [PATCH net-next 5/5] tls: Add generic NIC offload infrastructure.
Date: Tue, 19 Sep 2017 07:36:28 +0000
Message-ID: <AM4PR0501MB2723F6F5A22955102CDC2886D4600@AM4PR0501MB2723.eurprd05.prod.outlook.com>
References: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
        <1505385988-94522-6-git-send-email-ilyal@mellanox.com>
 <87poaocb4q.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "davejwatson@fb.com" <davejwatson@fb.com>,
        "tom@herbertland.com" <tom@herbertland.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Liran Liss <liranl@mellanox.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0076.outbound.protection.outlook.com ([104.47.1.76]:21453
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750972AbdISHgb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 03:36:31 -0400
In-Reply-To: <87poaocb4q.fsf@stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:

> The user should be aware of that they can't migrate the socket to another
> interface if they got hw offloaded. This is not the case for software off=
load.
> Thus I think the user has to opt in and it shouldn't be a heuristic until=
 we can
> switch back to sw offload path.
>=20
> Maybe change flowi_oif to sk_bound_dev_if and somwhow lock it against
> further changes if hw tls is in use?
>=20

I'm not sure I follow.
We do set sk->sk_bound_dev_if to prevent further changes.

Do you recommend we enable TLS offload only if SO_BINDTODEVICE=09
was previously used on that socket?
and prevent even users with CAP_NET_RAW from unbinding it?

I would rather avoid requiring CAP_NET_RAW to use TLS offload.=20
But admittedly I'm not sure setting sk->sk_bound_dev_if=20
without CAP_NET_RAW like we do is legit either.

Finally, the reason we made HW offload the default is that the user
can use sudo ethtool -K enp0s4 tls-hw-tx-offload off to opt out of HW offlo=
ad
and we currently don't have anything equivalent for opting out of SW KTLS.

Thanks,
Ilya
