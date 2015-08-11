From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 04/10] batman-adv: Make NC capability changes atomic
Date: Tue, 11 Aug 2015 22:38:02 +0300
Message-ID: <55CA4F1A.1050606@cogentembedded.com>
References: <1439310948-32426-1-git-send-email-antonio@meshcoding.com>
 <1439310948-32426-5-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?Q?Linus_L=c3=bcssing?= <linus.luessing@c0d3.blue>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: Antonio Quartulli <antonio@meshcoding.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:36586 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334AbbHKTiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 15:38:06 -0400
Received: by lbbpu9 with SMTP id pu9so92123131lbb.3
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 12:38:04 -0700 (PDT)
In-Reply-To: <1439310948-32426-5-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/11/2015 07:35 PM, Antonio Quartulli wrote:

> From: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
>
> Bitwise OR/AND assignments in C aren't guaranteed to be atomic. One
> OGM handler might undo the set/clear of a specific bit from another
> handler run in between.
>
> Fix this by using the atomic set_bit()/clear_bit()/test_bit() functio=
ns.
>
> Fixes: 3f4841ffb336 ("batman-adv: tvlv - add network coding container=
")
> Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
> Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
> Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
> ---
>   net/batman-adv/network-coding.c | 7 ++++---
>   net/batman-adv/types.h          | 2 +-
>   2 files changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network=
-coding.c
> index f0a50f3..cfdc80d 100644
> --- a/net/batman-adv/network-coding.c
> +++ b/net/batman-adv/network-coding.c
[...]
> @@ -894,7 +895,7 @@ void batadv_nc_update_nc_node(struct batadv_priv =
*bat_priv,
>   		goto out;
>
>   	/* check if orig node is network coding enabled */
> -	if (!(orig_node->capabilities & BATADV_ORIG_CAPA_HAS_NC))
> +	if (!(test_bit(BATADV_ORIG_CAPA_HAS_NC, &orig_node->capabilities)))

    Likewise, () around the call no needed.

[...]

MBR, Sergei
