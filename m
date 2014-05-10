From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/4] batman-adv: fix removing neigh_ifinfo
Date: Sun, 11 May 2014 00:39:50 +0400
Message-ID: <536E8E96.7090401@cogentembedded.com>
References: <1399736110-22333-1-git-send-email-antonio@meshcoding.com> <1399736110-22333-5-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: Antonio Quartulli <antonio@meshcoding.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:50520 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbaEJUjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 16:39:35 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so6436914lbi.29
        for <netdev@vger.kernel.org>; Sat, 10 May 2014 13:39:33 -0700 (PDT)
In-Reply-To: <1399736110-22333-5-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/10/2014 07:35 PM, Antonio Quartulli wrote:

> From: Simon Wunderlich <simon@open-mesh.com>

> When an interface is removed separately, all neighbors need to be
> checked if they have a neigh_ifinfo structure for that particular
> interface. If that is the case, remove that ifinfo so any references to
> a hard interface can be freed.

> This is a regression introduced by
> 89652331c00f43574515059ecbf262d26d885717
> ("batman-adv: split tq information in neigh_node struct")

> Reported-by: Antonio Quartulli <antonio@open-mesh.com>
> Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
> Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
> Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
> ---
>   net/batman-adv/originator.c | 46 +++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 46 insertions(+)

> diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
> index 8104c3c..427c07d 100644
> --- a/net/batman-adv/originator.c
> +++ b/net/batman-adv/originator.c
> @@ -707,6 +707,47 @@ free_orig_node:
>   }
>
>   /**
> + * batadv_purge_neigh_ifinfo - purge obsolete ifinfo entries from neighbor
> + * @bat_priv: the bat priv with all the soft interface information
> + * @neigh_node: orig node which is to be checked

    The corresponding parameter is called just 'neigh'.

> + */
> +static void
> +batadv_purge_neigh_ifinfo(struct batadv_priv *bat_priv,
> +			  struct batadv_neigh_node *neigh)
[...]

WBR, Sergei
