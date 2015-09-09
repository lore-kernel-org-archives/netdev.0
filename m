From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCH net] xen-netback: respect user provided max_queues
Date: Wed, 9 Sep 2015 11:29:22 +0100
Message-ID: <1441794562.24450.266.camel@citrix.com>
References: <1441793395-25537-1-git-send-email-wei.liu2@citrix.com>
	 <55F0061C.2080403@citrix.com>
	 <20150909101628.GK12714@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Xen-devel <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>,
	Johnny Strom <johnny.strom@linuxsolutions.fi>
To: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:8125 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751886AbbIIK3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2015 06:29:24 -0400
In-Reply-To: <20150909101628.GK12714@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-09 at 11:16 +0100, Wei Liu wrote:
> On Wed, Sep 09, 2015 at 11:12:44AM +0100, David Vrabel wrote:
> > On 09/09/15 11:09, Wei Liu wrote:
> > > Originally that parameter was always reset to num_online_cpus during
> > > module initialisation, which renders it useless.
> > > 
> > > The fix is to only set max_queues to num_online_cpus when user has
> > > not
> > > provided a value.
> > [...]
> > > --- a/drivers/net/xen-netback/netback.c
> > > +++ b/drivers/net/xen-netback/netback.c
> > > @@ -67,7 +67,7 @@ module_param(rx_drain_timeout_msecs, uint, 0444);
> > >  unsigned int rx_stall_timeout_msecs = 60000;
> > >  module_param(rx_stall_timeout_msecs, uint, 0444);
> > >  
> > > -unsigned int xenvif_max_queues;
> > > +unsigned int xenvif_max_queues = 0;
> > 
> > You don't need this.
> > 
> > Otherwise,
> > 
> > Reviewed-by: David Vrabel <david.vrabel@citrix.com>
> > 
> > Is an equivalent fix needed in netfront?
> > 
> 
> I think so.
> 
> I will address your comment

With that: Acked-by: Ian Campbell <ian.campbell@citrix.com>



>  and send both fixes (front and back) in a
> series.
> 
> Wei.
> 
> > David
> > 
> > >  module_param_named(max_queues, xenvif_max_queues, uint, 0644);
> > >  MODULE_PARM_DESC(max_queues,
> > >  		 "Maximum number of queues per virtual interface");
> > > @@ -2105,8 +2105,11 @@ static int __init netback_init(void)
> > >  	if (!xen_domain())
> > >  		return -ENODEV;
> > >  
> > > -	/* Allow as many queues as there are CPUs, by default */
> > > -	xenvif_max_queues = num_online_cpus();
> > > +	/* Allow as many queues as there are CPUs if user has not
> > > +	 * specified a value.
> > > +	 */
> > > +	if (xenvif_max_queues == 0)
> > > +		xenvif_max_queues = num_online_cpus();
> > >  
> > >  	if (fatal_skb_slots < XEN_NETBK_LEGACY_SLOTS_MAX) {
> > >  		pr_info("fatal_skb_slots too small (%d), bump it to
> > > XEN_NETBK_LEGACY_SLOTS_MAX (%d)\n",
> > > 
