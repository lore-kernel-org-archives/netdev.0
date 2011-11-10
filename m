From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next V7] net: introduce ethernet teaming device
Date: Thu, 10 Nov 2011 17:02:10 +0100
Message-ID: <1320940930.10042.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1320939698-1062-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com, ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35691 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827Ab1KJQCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 11:02:15 -0500
Received: by wyh15 with SMTP id 15so2864893wyh.19
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 08:02:14 -0800 (PST)
In-Reply-To: <1320939698-1062-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 10 novembre 2011 =C3=A0 16:41 +0100, Jiri Pirko a =C3=A9crit :
> This patch introduces new network device called team. It supposes to =
be
> very fast, simple, userspace-driven alternative to existing bonding
> driver.
>=20

> +static bool team_dummy_transmit(struct team *team, struct sk_buff *s=
kb)
> +{
> +	dev_kfree_skb(skb);
> +	return false;
> +}
> +

ndo_start_xmit() method can be called with IRQ disabled (netpoll ?), so
dev_kfree_skb_any() is better ?
