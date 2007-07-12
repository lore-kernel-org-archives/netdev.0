From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH v2 -mm 9/9] netconsole: Support dynamic reconfiguration
 using configfs
Date: Thu, 12 Jul 2007 22:38:17 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707122235330.10842@cselinux1.cse.iitk.ac.in>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070710092006.23907.33652.sendpatchset@cselinux1.cse.iitk.ac.in>
 <4695FCB8.8090102@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Keiichi KII <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:53505 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935456AbXGLQpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 12:45:44 -0400
In-Reply-To: <4695FCB8.8090102@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, 12 Jul 2007, Keiichi KII wrote:
> Hi Satyam,
> 
> >  struct netconsole_target {
> >  	struct list_head	list;
> > +#ifdef	CONFIG_NETCONSOLE_DYNAMIC
> > +	struct config_item	item;
> > +	int			enabled;
> > +#endif
> >  	struct netpoll		np;
> >  };
> 
> If CONFIG_NETCONSOLE_DYNAMIC is unset, we can't access to the "enabled" member.
> So, the compile errors occur because the following functions make use of 
> the above one.

Gargh, yes.

> Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> 
> Index: mm/drivers/net/netconsole.c
> ===================================================================
> --- mm.orig/drivers/net/netconsole.c
> +++ mm/drivers/net/netconsole.c
> @@ -94,8 +94,8 @@ struct netconsole_target {
>         struct list_head        list;
>  #ifdef CONFIG_NETCONSOLE_DYNAMIC
>         struct config_item      item;
> -       int                     enabled;
>  #endif
> +       int                     enabled;
>         struct netpoll          np;
>  };

Yup, enabled should be out of CONFIG_NETCONSOLE_DYNAMIC. I'll include this
change in the next version as well.

Thanks,
Satyam
