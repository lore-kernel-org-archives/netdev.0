From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next-2.6 RFC PATCH v2 01/13] ethtool: allow custom
 interval for physical identification
Date: Wed, 13 Apr 2011 23:44:39 +0100
Message-ID: <1302734679.2873.23.camel@bwh-desktop>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
	 <20110413195851.25901.8139.stgit@gitlad.jf.intel.com>
	 <1302726313.2873.18.camel@bwh-desktop>
	 <8DD2590731AB5D4C9DBF71A877482A90018A3427B6@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:1400 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757289Ab1DMWol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 18:44:41 -0400
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A90018A3427B6@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-13 at 15:39 -0700, Allan, Bruce W wrote:
> 
> >-----Original Message-----
> >From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> >Sent: Wednesday, April 13, 2011 1:25 PM
> >To: Allan, Bruce W
> >Cc: netdev@vger.kernel.org
> >Subject: Re: [net-next-2.6 RFC PATCH v2 01/13] ethtool: allow custom interval
> >for physical identification
> >
> >I'm sure there ought to be a clearer way to do this, and to avoid any
> >weird effects from integer overflow in the multiplication.  How about
> >using an inner loop for each second:
> >
> >		/* Driver expects to be called at twice the frequency in rc */
> >		int n = rc * 2, i, interval = HZ / n;
> >

		/* Count down seconds */
> >		do {
			/* Count down iterations per second */
> >			i = n;
> >			do {
> >	 			rtnl_lock();
> > 				rc = dev->ethtool_ops->set_phys_id(
> >					dev, (i & 1) ? ETHTOOL_ID_OFF : ETHTOOL_ID_ON);
> >	 			rtnl_unlock();
> > 				if (rc)
> > 					break;
> >				schedule_timeout_interruptible(interval);
> >			} while (!signal_pending(current) && --i != 0);
> > 		} while (!signal_pending(current) &&
> >			 (id.data == 0 || --id.data != 0));
> >
> >Ben.
> 
> OK, if that is clearer to you...v3 forthcoming.

I guess it wouldn't hurt to add comemnts too.  Would you agree that it's
clear with the additions above?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

