From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH 2/6] netback: add module unload function.
Date: Mon, 16 Jan 2012 09:31:58 +0000
Message-ID: <1326706318.5285.4.camel@liuw-desktop>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
	 <1326473949-22389-3-git-send-email-wei.liu2@citrix.com>
	 <4F10709B.8070804@cantab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Vrabel <dvrabel@cantab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:31144 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628Ab2APJcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 04:32:48 -0500
In-Reply-To: <4F10709B.8070804@cantab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-13 at 17:57 +0000, David Vrabel wrote:
> On 13/01/12 16:59, Wei Liu wrote:
> > Enables users to unload netback module.
> [...]
> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> > index 26af7b7..dd10c0d 100644
> > --- a/drivers/net/xen-netback/netback.c
> > +++ b/drivers/net/xen-netback/netback.c
> > @@ -1653,5 +1653,19 @@ failed_init:
> >  
> >  module_init(netback_init);
> >  
> > +static void __exit netback_exit(void)
> > +{
> > +	int i;
> > +	for (i = 0; i < xen_netbk_group_nr; i++) {
> > +		struct xen_netbk *netbk = &xen_netbk[i];
> > +		del_timer(&netbk->net_timer);
> 
> This needs to be del_timer_sync().
> 
> > +		kthread_stop(netbk->task);
> > +	}
> > +	vfree(xen_netbk);
> > +	page_pool_destroy();
> > +	xenvif_xenbus_exit();
> > +}

Both fixed.

Thanks
Wei.
