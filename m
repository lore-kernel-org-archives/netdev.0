From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [RFC net-next (v2) 11/14] igb: set maximal number of default
 RSS queues
Date: Mon, 25 Jun 2012 19:38:18 +0100
Message-ID: <1340649498.2572.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
	 <1340624745-8650-12-git-send-email-yuvalmin@broadcom.com>
	 <06DFBC1E25D8024DB214DC7F41A3CD3448870CE4@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <yuvalmin@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eilong@broadcom.com" <eilong@broadcom.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29039 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756127Ab2FYSiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 14:38:23 -0400
In-Reply-To: <06DFBC1E25D8024DB214DC7F41A3CD3448870CE4@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-25 at 17:31 +0000, Vick, Matthew wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Yuval Mintz
> > Sent: Monday, June 25, 2012 4:46 AM
> > To: davem@davemloft.net; netdev@vger.kernel.org
> > Cc: eilong@broadcom.com; Yuval Mintz; Kirsher, Jeffrey T
> > Subject: [RFC net-next (v2) 11/14] igb: set maximal number of default
> > RSS queues
> > 
> > Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> > 
> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  drivers/net/ethernet/intel/igb/igb_main.c |    3 ++-
> >  1 files changed, 2 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
> > b/drivers/net/ethernet/intel/igb/igb_main.c
> > index 01ced68..b11ee60 100644
> > --- a/drivers/net/ethernet/intel/igb/igb_main.c
> > +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> > @@ -2465,7 +2465,8 @@ static int __devinit igb_sw_init(struct
> > igb_adapter *adapter)
> >  		break;
> >  	}
> > 
> > -	adapter->rss_queues = min_t(u32, max_rss_queues,
> > num_online_cpus());
> > +	adapter->rss_queues = min_t(u32, max_rss_queues,
> > +				    netif_get_num_default_rss_queues());
> > 
> >  	/* Determine if we need to pair queues. */
> >  	switch (hw->mac.type) {
> > --
> > 1.7.9.rc2
> 
> Since igb supports a maximum of 8 RSS queues anyway, it's generally
> unaffected by this change.

I'm interested in providing a global configuration mechanism for this,
which is why I asked Yuval to introduce this function.

> That being said, I'm confused about what you're trying to
> accomplish--is it to standardize the number of RSS queues or limit the
> number of interrupts by default? Or is it the former with a hope that
> it will trickle down to the latter?
>
> For example, if you take an igb device that supports 8 RSS queues
> (say, I350) and you change the default to 4 RSS queues, you will end
> up with the same number of interrupt vectors being requested as we
> will disable queue pairing and request separate vectors for Rx/Tx
> queues. I haven't looked at the other drivers affected by this RFC,
> but it's possible other drivers behave the same way.

sfc also supports those two modes, but under control of a module
parameter.  If it's a common enough feature then perhaps it should also
be subject to global configuration (though that might be confusing if
most drivers continue to support only one mode).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
