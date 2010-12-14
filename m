From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] e1000e: convert to stats64
Date: Tue, 14 Dec 2010 22:29:33 +0100
Message-ID: <1292362173.2478.6.camel@edumazet-laptop>
References: <1292358735-32089-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59079 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760158Ab0LNV3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 16:29:37 -0500
Received: by wwa36 with SMTP id 36so950316wwa.1
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 13:29:36 -0800 (PST)
In-Reply-To: <1292358735-32089-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 d=C3=A9cembre 2010 =C3=A0 18:32 -0200, Flavio Leitner a =C3=
=A9crit :
> Provides accurate stats at the time user reads them.
>=20
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> ---
>  drivers/net/e1000e/e1000.h   |    5 ++-
>  drivers/net/e1000e/ethtool.c |   27 +++++++++-------
>  drivers/net/e1000e/netdev.c  |   68 ++++++++++++++++++++++++--------=
---------
>  3 files changed, 59 insertions(+), 41 deletions(-)
>=20
> diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
> index fdc67fe..5a5e944 100644
> --- a/drivers/net/e1000e/e1000.h
> +++ b/drivers/net/e1000e/e1000.h
> @@ -363,6 +363,8 @@ struct e1000_adapter {
>  	/* structs defined in e1000_hw.h */
>  	struct e1000_hw hw;
> =20
> +	spinlock_t stats64_lock;
> +	struct rtnl_link_stats64 stats64;

I am not sure why you add this stats64 in e1000_adapter ?

Why isnt it provided by callers (automatic variable, or provided to
ndo_get_stats64()). I dont see accumulators, only a full rewrite of thi=
s
structure in e1000e_update_stats() ?


