From: Lars Ellenberg <lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2 v2] netlink: kill eff_cap from struct
 netlink_skb_parms
Date: Thu, 3 Mar 2011 23:37:46 +0100
Message-ID: <20110303223746.GI25069@barkeeper1-xen.linbit>
References: <4D6F6180.5030903@trash.net>
	<20110303173230.GP4988@sequoia.sous-sol.org>
	<20110303.105655.189705829.davem@davemloft.net>
	<20110303201522.GT4988@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
To: Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>
Return-path: <drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110303201522.GT4988-JyIX8gxvWYPr2PDY2+4mTGD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <http://lists.linbit.com/mailman/options/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linbit.com/pipermail/drbd-dev>
List-Post: <mailto:drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
List-Help: <mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=help>
List-Subscribe: <http://lists.linbit.com/mailman/listinfo/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=subscribe>
Sender: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
Errors-To: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2011 at 12:15:22PM -0800, Chris Wright wrote:
> * David Miller (davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org) wrote:
> > From: Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>
> > Date: Thu, 3 Mar 2011 09:32:30 -0800
> > 
> > > * Patrick McHardy (kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org) wrote:
> > > 
> > >> commit 8ff259625f0ab295fa085b0718eed13093813fbc
> > >> Author: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> > >> Date:   Thu Mar 3 10:17:31 2011 +0100
> > >> 
> > >>     netlink: kill eff_cap from struct netlink_skb_parms
> > >>     
> > >>     Netlink message processing in the kernel is synchronous these days,
> > >>     capabilities can be checked directly in security_netlink_recv() from
> > >>     the current process.
> > >>     
> > >>     Signed-off-by: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> > > 
> > > Thanks for doing that Patrick.  I looked at this earlier and thought
> > > there was still an async path, but I guess that's just to another
> > > userspace process.
> > > 
> > > BTW, I think you missed a couple connector based callers:
> > > 
> > > drivers/staging/pohmelfs/config.c:      if (!cap_raised(nsp->eff_cap, CAP_SYS_AD
> > > drivers/video/uvesafb.c:        if (!cap_raised(nsp->eff_cap, CAP_SYS_ADMIN))


Last time I checked, current() for connector based netlink message
consumers was the work queue that is used for connector.

So unless that changed, or my understanding is wrong, current_cap()
inside cn_queue_wrapper(), respectively the d->callback()
will not be the userland sender process' capabilities, but the work
queue capabilities.

If so, then this change introduces the possibility for normal users to
send privileged commands to connector based subsystems, even if they
may not be able to bind() to suitable sockets to receive any replies.

Am I missing something?

	Lars
