From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] netstamp_needed shouldn't be jump_label_key
Date: Mon, 28 Nov 2011 23:23:58 +0100
Message-ID: <1322519038.2970.37.camel@edumazet-laptop>
References: <igorm@etf.rs> <1322511796-6908-1-git-send-email-igorm@etf.rs>
	 <1322511796-6908-2-git-send-email-igorm@etf.rs>
	 <1322512426.2970.15.camel@edumazet-laptop>
	 <1322515010.2970.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:49173 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494Ab1K1WYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 17:24:02 -0500
Received: by eaak14 with SMTP id k14so2309631eaa.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 14:24:01 -0800 (PST)
In-Reply-To: <1322515010.2970.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 22:16 +0100, Eric Dumazet a =C3=A9crit=
 :

> [PATCH net-next] net: dont call jump_label_dec from irq context
>=20
> Igor Maravic reported an error caused by jump_label_dec() being calle=
d
> from IRQ context :

> ...

> Since jump_label_{inc|dec} must be called from process context only,
> we must defer jump_label_dec() if net_disable_timestamp() is called
> from interrupt context.
>=20
> Reported-by: Igor Maravic <igorm@etf.rs>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/core/dev.c                 |   23 +++++++++++++++++++++++
>  net/ipv4/netfilter/ip_queue.c  |    6 ++++--
>  net/ipv6/netfilter/ip6_queue.c |    5 ++++-
>  3 files changed, 31 insertions(+), 3 deletions(-)

By the way, we also can call sock_disable_timestamp() from sk_free()
instead of calling it from __sk_free()

This makes no sense to wait that all in-flight packets were destroyed
before removing sk timestamping.
