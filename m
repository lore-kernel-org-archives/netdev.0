From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/8] dccp: use limited socket backlog
Date: Wed, 03 Mar 2010 07:56:27 +0100
Message-ID: <1267599387.2839.89.camel@edumazet-laptop>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:52973 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754722Ab0CCG4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 01:56:36 -0500
Received: by bwz4 with SMTP id 4so764959bwz.28
        for <netdev@vger.kernel.org>; Tue, 02 Mar 2010 22:56:34 -0800 (PST)
In-Reply-To: <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 mars 2010 =C3=A0 14:35 +0800, Zhu Yi a =C3=A9crit :
> Make dccp adapt to the limited socket backlog change.
>=20
> Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> ---
>  net/dccp/minisocks.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
> index af226a0..0d508c3 100644
> --- a/net/dccp/minisocks.c
> +++ b/net/dccp/minisocks.c
> @@ -254,7 +254,7 @@ int dccp_child_process(struct sock *parent, struc=
t sock *child,
>  		 * in main socket hash table and lock on listening
>  		 * socket does not protect us more.
>  		 */
> -		sk_add_backlog(child, skb);
> +		__sk_add_backlog(child, skb);
>  	}
> =20
>  	bh_unlock_sock(child);

I dont understand this patch.

You make dccp vulnerable to memory exhaustion, I thought you wanted to
solve this problem.

It should therefore be named "dccp: use unlimited socket backlog"

(And this sounds not so sexy :) )


