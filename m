From: Lars Ellenberg <lars.ellenberg@linbit.com>
Subject: Re: [PATCH] connector: Allow permission checking in the receiver
	callbacks
Date: Wed, 30 Sep 2009 15:20:35 +0200
Message-ID: <20090930132034.GE8032@barkeeper1-xen.linbit>
References: <1254235692-1631-1-git-send-email-philipp.reisner@linbit.com> <20090930112057.GA15150@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philipp Reisner <philipp.reisner@linbit.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.com>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754094AbZI3NUd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090930112057.GA15150@ioremap.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2009 at 03:20:57PM +0400, Evgeniy Polyakov wrote:
> Hi Philipp.
> 
> On Tue, Sep 29, 2009 at 04:48:07PM +0200, Philipp Reisner (philipp.reisner@linbit.com) wrote:
> > Various users of the connector should actually check if the
> > sender's capabilities of a netlink/connector packet are
> > actually sufficient for the operation they trigger. Up to
> > now the connector framework did not allow the kernel side
> > receiver to do so.
> > 
> > This patch set does the groundwork.
> > 
> > Philipp Reisner (4):
> >   connector: Keep the skb in cn_callback_data
> >   connector: Provide the sender's credentials to the callback
> >   connector/dm: Fixed a compilation warning
> >   connector: Removed the destruct_data callback since it is always
> >     kfree_skb()
> 
> Patches look good to me.
> Andrew please apply to the appropriate tree. I do not know whether it is
> acceptible now, since it is not a bugfix, but merely a simple cleanup.
> Feel free to add my signed off or ack, thank you.

Thanks.

Actually it is the basis for follow-up security fixes.

Without this, unprivileged user space is able to send arbitrary
connector requests to kernel subsystems, which have no way to verify the
privileges of the sender anymore, because that information, even though
available at the netlink layer, has been dropped by the connector.

Once this is applied, the various in-kernel receiving connector
callbacks can (and need to) add cap_raised(nsb->eff_cap, cap) where
appropriate. For example, you don't want some guest user to be able to
trigger a dst_del_node callback by sending a crafted netlink message,
right?

So it _is_ a (design-) bug fix.
Or am I missing something?

	Lars
