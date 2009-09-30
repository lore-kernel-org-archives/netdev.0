From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: Allow permission checking in the receiver callbacks
Date: Wed, 30 Sep 2009 23:29:28 +0400
Message-ID: <20090930192928.GA1315@ioremap.net>
References: <1254235692-1631-1-git-send-email-philipp.reisner@linbit.com> <20090930112057.GA15150@ioremap.net> <20090930132034.GE8032@barkeeper1-xen.linbit>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philipp Reisner <philipp.reisner@linbit.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.com>
To: Lars Ellenberg <lars.ellenberg@linbit.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755157AbZI3T31@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090930132034.GE8032@barkeeper1-xen.linbit>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2009 at 03:20:35PM +0200, Lars Ellenberg (lars.ellenberg@linbit.com) wrote:
> Actually it is the basis for follow-up security fixes.
> 
> Without this, unprivileged user space is able to send arbitrary
> connector requests to kernel subsystems, which have no way to verify the
> privileges of the sender anymore, because that information, even though
> available at the netlink layer, has been dropped by the connector.

It is not. One can add some checks at receiving time which happens in
process context to get its credentials, but nothing in netlink itself
carry this info. Getting that connector schedules workqueue this ability
is lost.

> Once this is applied, the various in-kernel receiving connector
> callbacks can (and need to) add cap_raised(nsb->eff_cap, cap) where
> appropriate. For example, you don't want some guest user to be able to
> trigger a dst_del_node callback by sending a crafted netlink message,
> right?
> 
> So it _is_ a (design-) bug fix.
> Or am I missing something?

This patchset is not a bugfix, just a cleanup, since none in patchset
uses netlink_skb_parms and currently I see no users which are affected
by this behaviour in the mainline branch (not counting staging tree).

But if proposed configuration changes for DM are on the way, then I
agree and they should force this patchset into the tree as a bugfix.

-- 
	Evgeniy Polyakov
