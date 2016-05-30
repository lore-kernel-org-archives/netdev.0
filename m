From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] veth: delay peer link configuration after interfaces are
 tied
Date: Mon, 30 May 2016 17:19:30 +0200
Message-ID: <574C5A02.4020606@6wind.com>
References: <574C0697.6060506@6wind.com>
 <1464603227-25355-1-git-send-email-vincent@bernat.im>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Vincent Bernat <vincent@bernat.im>,
	"David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34951 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933000AbcE3PTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 11:19:33 -0400
Received: by mail-wm0-f52.google.com with SMTP id a136so91441689wme.0
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 08:19:32 -0700 (PDT)
In-Reply-To: <1464603227-25355-1-git-send-email-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/05/2016 12:13, Vincent Bernat a =C3=A9crit :
> When the peer link is created, its "iflink" information is not
> advertised through netlink. If a user is maintaining a cache from all
> updates, it will miss this information:
>=20
>     2: veth0@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DO=
WN group default
>         link/ether ae:0e:08:af:fb:a0 brd ff:ff:ff:ff:ff:ff
>     3: veth1@veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop =
state DOWN group default
>         link/ether 3a:31:f1:36:2e:e5 brd ff:ff:ff:ff:ff:ff
>=20
> To avoid this situation, the peer link is only configured after both
> interfaces are tied together:
>=20
>     3: veth0@veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state D=
OWN group default
>         link/ether ee:0d:80:46:36:fe brd ff:ff:ff:ff:ff:ff
>     4: veth1@veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop =
state DOWN group default
>         link/ether ba:25:bc:7a:0d:c8 brd ff:ff:ff:ff:ff:ff
>=20
> Signed-off-by: Vincent Bernat <vincent@bernat.im>
> ---
Please specify the version in the title (something like '[PATCH net v3]=
' here,
see --subject-prefix).

Also add the changelog after the '---' (see --annotate).
