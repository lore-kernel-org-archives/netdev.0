From: Martin Lau <kafai@fb.com>
Subject: Re: [PATCH RFC v2 net-next 2/2] ip_tunnel: Remove struct gro_cells
Date: Thu, 15 Jan 2015 10:39:20 -0800
Message-ID: <20150115181932.GA3899482@devbig242.prn2.facebook.com>
References: <1421192564-437455-1-git-send-email-kafai@fb.com>
 <1421192564-437455-3-git-send-email-kafai@fb.com>
 <1421276039.11734.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:63867 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751448AbbAOSj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 13:39:28 -0500
Content-Disposition: inline
In-Reply-To: <1421276039.11734.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 02:53:59PM -0800, Eric Dumazet wrote:
> On Tue, 2015-01-13 at 15:42 -0800, Martin KaFai Lau wrote:
> > After adding percpu gro_cells, struct gro_cells can be removed.
> > 
> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> > ---
> >  include/net/gro_cells.h  | 34 ++++++++++++++++------------------
> >  include/net/ip_tunnels.h |  2 +-
> >  net/ipv4/ip_tunnel.c     | 11 +++++------
> >  3 files changed, 22 insertions(+), 25 deletions(-)
> > 
> > diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
> > index 0f712c0..b1aeea1 100644
> > --- a/include/net/gro_cells.h
> > +++ b/include/net/gro_cells.h
> > @@ -10,21 +10,18 @@ struct gro_cell {
> >  	struct napi_struct	napi;
> >  };
> >  
> > -struct gro_cells {
> > -	struct gro_cell __percpu	*cells;
> > -};
> > -
> 
> This seems a lot of code churn for no runtime difference ?
> 
> If we ever want to add an additional 'field', we likely have to revert
> this patch.
It seems cleaning up an one item struct is unnecessary.  I
will repost without patch 2/2.

> 
> -static inline void gro_cells_destroy(struct gro_cells *gcells)
> +static inline void gro_cell_free_percpu(struct gro_cell __percpu *gcells)
>  {
>         int i;
>  
> -       if (!gcells->cells)
> +       if (IS_ERR_OR_NULL(gcells))
>                 return;
> 
> For example, I have no idea why this part is needed.
For this change:
-       err = gro_cells_init(&tunnel->gro_cells, dev);
-       if (err) {
+       tunnel->gro_cells = gro_cell_alloc_percpu(dev);
+       if (IS_ERR(tunnel->gro_cells)) {

Thanks,
--Martin
