From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC v2 net-next 2/2] ip_tunnel: Remove struct gro_cells
Date: Thu, 15 Jan 2015 11:24:55 -0800
Message-ID: <1421349895.11734.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421192564-437455-1-git-send-email-kafai@fb.com>
	 <1421192564-437455-3-git-send-email-kafai@fb.com>
	 <1421276039.11734.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150115181932.GA3899482@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: Martin Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34491 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672AbbAOTY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 14:24:57 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so16771849iec.1
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 11:24:56 -0800 (PST)
In-Reply-To: <20150115181932.GA3899482@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-15 at 10:39 -0800, Martin Lau wrote:

> > 
> > -static inline void gro_cells_destroy(struct gro_cells *gcells)
> > +static inline void gro_cell_free_percpu(struct gro_cell __percpu *gcells)
> >  {
> >         int i;
> >  
> > -       if (!gcells->cells)
> > +       if (IS_ERR_OR_NULL(gcells))
> >                 return;
> > 
> > For example, I have no idea why this part is needed.
> For this change:
> -       err = gro_cells_init(&tunnel->gro_cells, dev);
> -       if (err) {
> +       tunnel->gro_cells = gro_cell_alloc_percpu(dev);
> +       if (IS_ERR(tunnel->gro_cells)) {

That is bad. See David Miller recent mail about this kind of construct.

Current code is better : Do not store an error code in structure, but
rather use a local variable.

Thanks
