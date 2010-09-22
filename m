From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp
	reports
Date: Wed, 22 Sep 2010 15:50:52 -0600
Message-ID: <20100922215052.GK11157@obsidianresearch.com>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009221448460.32661-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2010 at 02:58:15PM -0500, Christoph Lameter wrote:
> > packets if it isn't ready quickly? A querier is what makes these
> > reliable, but for the start-up in particular, I think it'd be better
> > to not initiate the send on devices that have this problem until the
> > device is actually ready to send-- why not put the delay in the device
> > driver on initialization?
> 
> The device is ready. Its just the multicast group that has not been
> established yet.

In IB when the SA replies to a group join the group should be ready,
prior to that the device can't send into the group because it has no
MLID for the group.. If you have a MLID then the group is working.

Is the issue you are dropping IGMP packets because the 224.0.0.2 join
hasn't finished? Ideally you'd wait for the SA to reply before sending
a IGMP, but a simpler solution might just be to use the broadcast MLID
for packets addressed to a MGID that has not yet got a MLID. This
would bebe similar to the ethernet behaviour of flooding.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
