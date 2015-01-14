From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC v2 net-next 2/2] ip_tunnel: Remove struct gro_cells
Date: Wed, 14 Jan 2015 14:53:59 -0800
Message-ID: <1421276039.11734.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421192564-437455-1-git-send-email-kafai@fb.com>
	 <1421192564-437455-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:55923 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbbANWyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 17:54:01 -0500
Received: by mail-ie0-f169.google.com with SMTP id y20so11808838ier.0
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 14:54:00 -0800 (PST)
In-Reply-To: <1421192564-437455-3-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-13 at 15:42 -0800, Martin KaFai Lau wrote:
> After adding percpu gro_cells, struct gro_cells can be removed.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---
>  include/net/gro_cells.h  | 34 ++++++++++++++++------------------
>  include/net/ip_tunnels.h |  2 +-
>  net/ipv4/ip_tunnel.c     | 11 +++++------
>  3 files changed, 22 insertions(+), 25 deletions(-)
> 
> diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
> index 0f712c0..b1aeea1 100644
> --- a/include/net/gro_cells.h
> +++ b/include/net/gro_cells.h
> @@ -10,21 +10,18 @@ struct gro_cell {
>  	struct napi_struct	napi;
>  };
>  
> -struct gro_cells {
> -	struct gro_cell __percpu	*cells;
> -};
> -

This seems a lot of code churn for no runtime difference ?

If we ever want to add an additional 'field', we likely have to revert
this patch.

-static inline void gro_cells_destroy(struct gro_cells *gcells)
+static inline void gro_cell_free_percpu(struct gro_cell __percpu *gcells)
 {
        int i;
 
-       if (!gcells->cells)
+       if (IS_ERR_OR_NULL(gcells))
                return;

For example, I have no idea why this part is needed.
