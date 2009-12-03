From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast
 delivery
Date: Thu, 03 Dec 2009 23:59:58 +0100
Message-ID: <4B1842EE.7030208@gmail.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <1259879498-27860-4-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60471 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbZLCW75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 17:59:57 -0500
In-Reply-To: <1259879498-27860-4-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> This patch adds a per SAP device based hash table to solve the
> multicast delivery scalability issues for the case where the are a
> large number of interfaces and a large number of sockets (bound to th=
e
> same SAP) are used.
>=20
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---
>  include/net/llc.h      |   20 ++++++++++++++++----
>  include/net/llc_conn.h |    1 +
>  net/llc/llc_conn.c     |   18 +++++++++++++++++-
>  net/llc/llc_core.c     |    3 +++
>  net/llc/llc_sap.c      |   11 ++++++-----
>  5 files changed, 43 insertions(+), 10 deletions(-)
>=20
> diff --git a/include/net/llc.h b/include/net/llc.h
> index 7940da1..31e9902 100644
> --- a/include/net/llc.h
> +++ b/include/net/llc.h
> @@ -31,6 +31,14 @@ struct llc_addr {
>  #define LLC_SAP_STATE_INACTIVE	1
>  #define LLC_SAP_STATE_ACTIVE	2
> =20
> +#define LLC_SK_DEV_HASH_BITS 10
> +#define LLC_SK_DEV_HASH_ENTRIES (1<<LLC_SK_DEV_HASH_BITS)
> +
> +struct llc_sk_list {
> +	rwlock_t lock;
> +	struct hlist_head list;
> +};
> +

This patch introduces a big hash table, and 1024 rwlocks, for IXIACOM n=
eed.

Is the problem both on lock contention and lookup ?
