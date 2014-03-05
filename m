From: Hariprasad S <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net-next 10/31] cxgb4/iw_cxgb4: Doorbell Drop Avoidance
 Bug Fixes.
Date: Wed, 5 Mar 2014 11:04:14 +0530
Message-ID: <20140305053413.GB23862@hariprasad-pc>
References: <1393427230-14532-11-git-send-email-hariprasad@chelsio.com>
 <20140226.181216.1563503549713890339.davem@davemloft.net>
 <005101cf33df$00749e40$015ddac0$@opengridcomputing.com>
 <20140227.130544.1892840202381139797.davem@davemloft.net>
 <1393975366.16256.23.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	<kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1393975366.16256.23.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 04, 2014 at 23:22:46 +0000, Ben Hutchings wrote:
> On Thu, 2014-02-27 at 13:05 -0500, David Miller wrote:
> > From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
> > Date: Thu, 27 Feb 2014 11:11:49 -0600
> > 
> > >> 
> > >> > -static int allow_db_fc_on_t5;
> > >> > -module_param(allow_db_fc_on_t5, int, 0644);
> > >> > -MODULE_PARM_DESC(allow_db_fc_on_t5,
> > >> > -           "Allow DB Flow Control on T5 (default = 0)");
> > >> > -
> > >> > -static int allow_db_coalescing_on_t5;
> > >> > -module_param(allow_db_coalescing_on_t5, int, 0644);
> > >> > -MODULE_PARM_DESC(allow_db_coalescing_on_t5,
> > >> > -           "Allow DB Coalescing on T5 (default = 0)");
> > >> 
> > >> Module parameters are a user facing interface.
> > >> 
> > >> You cannot just delete, or change the semantics of, the ones you feel
> > >> like doing so to.
> > > 
> > > I see your point on user facing interfaces.   These module params were
> > > added initially to allow tweaking the db drop recovery for T5 devices in
> > > the thought that we might need it.  It turns out T5 doesn't suffer from
> > > this issue.  These params default to 0 anyway, and I doubt anyone has
> > > changed them.  Disabling the hw db coalescing feature proved problematic
> > > and it turned out to even make the issue worse, so I removed it totally
> > > at the recommendation from the HW engineers, and put in place the new
> > > design which better rate controls things under heavy load.
> > 
> > You have to keep the old ones around.
> 
> Setting an unknown module parameter now results in a warning (since
> 3.11), so removing a parameter isn't so disruptive as it used to be.
> 
> Obviously this is removing a feature, but as the feature sounds like it
> was only marginally useful I think it's a perfectly valid change.
> 
> Ben.

Thanks Ben for letting us know that things have changed post 3.11 kernel.

Hi David,
Would you be OK if we remove the unused module_param now when we re-submit the series ?


Thanks,
-Hari.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
