From: David Dillow <dave@thedillows.org>
Subject: Re: [RFC 2.6.10 4/22] xfrm: Try to offload inbound xfrm_states
Date: Sat, 22 Jan 2005 00:52:13 -0500
Message-ID: <1106373133.3691.40.camel@ori.thedillows.org>
References: <20041230035000.12@ori.thedillows.org>
	 <20041230035000.13@ori.thedillows.org>
	 <20050121145608.65ad2d48.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050121145608.65ad2d48.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-01-21 at 14:56 -0800, David S. Miller wrote: 
> On Thu, 30 Dec 2004 03:48:35 -0500
> David Dillow <dave@thedillows.org> wrote:
> 
> > # This is a BitKeeper generated diff -Nru style patch.
> > #
> > # ChangeSet
> > #   2004/12/30 00:33:11-05:00 dave@thedillows.org 
> > #   Plumb in offloading of inbound xfrm_states.
> > #   
> > #   Signed-off-by: David Dillow <dave@thedillows.org>
> 
> Hmmm, this seems to deadlock.  xfrm_state_add() is invoked
> with the RTNL semaphore already acquired.  For example, via
> xfrm_user.c:xfrm_add_sa()

Are you sure? It worked just fine during testing, and I don't see where
in the call chain from xfrm_netlink_rcv() to xfrm_state_add() the RTNL
sema is taken. Perhaps you were thinking of xfrm_cfg_sem?
-- 
David Dillow <dave@thedillows.org>
