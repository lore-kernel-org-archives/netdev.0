From: David Dillow <dave@thedillows.org>
Subject: Re: [RFC 2.6.10 7/22] xfrm: Allow device drivers to force
	recalculation of offloads
Date: Sat, 22 Jan 2005 00:53:36 -0500
Message-ID: <1106373216.3691.43.camel@ori.thedillows.org>
References: <20041230035000.15@ori.thedillows.org>
	 <20041230035000.16@ori.thedillows.org>
	 <20050121152358.5c60d0db.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050121152358.5c60d0db.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-01-21 at 15:23 -0800, David S. Miller wrote: 
> On Thu, 30 Dec 2004 03:48:35 -0500
> David Dillow <dave@thedillows.org> wrote:
> 
> > # This is a BitKeeper generated diff -Nru style patch.
> > #
> > # ChangeSet
> > #   2004/12/30 00:37:44-05:00 dave@thedillows.org 
> > #   Give device drivers a method to allow the use of crypto
> > #   offload features for existing xfrm_states and bundles, as
> > #   well as dynamically remove crypto offload capabilities.
> > #   
> > #   Signed-off-by: David Dillow <dave@thedillows.org>
> 
> This change looks fine, but it reminds me of something.
> 
> We have to make sure there is no way for xfrm_offloads to
> refer to a device when it is brought down.
> 
> One way to ensure that, is to make each xfrm_offload attached
> grab a reference to the device it is for.  The refcounting will
> help catch cases where stale xfrm_offload are around at
> unregister_netdev() time.

You're right, it would be a problem, and I have the oopsen to prove
it. :)

In patch 3 of the series, xfrm_offload_add() grabs a reference to the
device, and xfrm_offload_release() releases it when the offload's own
reference count hits zero.
-- 
David Dillow <dave@thedillows.org>
