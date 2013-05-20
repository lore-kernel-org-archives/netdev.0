From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netfront: avoid leaking resources when
 setup_netfront fails
Date: Mon, 20 May 2013 10:01:12 +0100
Message-ID: <20130520090112.GA27858@zion.uk.xensource.com>
References: <1368783838-24187-1-git-send-email-wei.liu2@citrix.com>
 <20130519.232833.988876168197782913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <ian.campbell@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:11085 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab3ETJBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 05:01:15 -0400
Content-Disposition: inline
In-Reply-To: <20130519.232833.988876168197782913.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 19, 2013 at 11:28:33PM -0700, David Miller wrote:
> From: Wei Liu <wei.liu2@citrix.com>
> Date: Fri, 17 May 2013 10:43:58 +0100
> 
> >  
> > + /* If we fail to setup netfront, it is safe to just revoke access to granted
> > +  * pages because backend is not accessing it at this point.
> > +  */
> > + bind_fail:
> > +	xenbus_free_evtchn(dev, info->evtchn);
> > + alloc_evtchn_fail:
> > +	gnttab_end_foreign_access_ref(info->rx_ring_ref, 0);
> > + grant_rx_ring_fail:
> > +	free_page((unsigned long)rxs);
> > + alloc_rx_ring_fail:
> > +	gnttab_end_foreign_access_ref(info->tx_ring_ref, 0);
> > + grant_tx_ring_fail:
> > +	free_page((unsigned long)txs);
> >   fail:
> >  	return err;
> >  }
> 
> This is not even close to adhering to proper coding style.
> 
> The comment should be indented by one tab not one space:
> 
> 	/* Like
> 	 * this.
> 	 */
> 
> And the code labels should appear at the first column, not
> with a leading space.

Thanks, coding style problems are fixed now.

For some reason some other labels in this file appear to have the same
style problem, I will fix them when I touch other part of the file in
the future.


Wei.
