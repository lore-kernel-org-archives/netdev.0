From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 2.6.10 7/22] xfrm: Allow device drivers to force
 recalculation of offloads
Date: Fri, 21 Jan 2005 15:23:58 -0800
Message-ID: <20050121152358.5c60d0db.davem@davemloft.net>
References: <20041230035000.15@ori.thedillows.org>
	<20041230035000.16@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <20041230035000.16@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Dec 2004 03:48:35 -0500
David Dillow <dave@thedillows.org> wrote:

> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2004/12/30 00:37:44-05:00 dave@thedillows.org 
> #   Give device drivers a method to allow the use of crypto
> #   offload features for existing xfrm_states and bundles, as
> #   well as dynamically remove crypto offload capabilities.
> #   
> #   Signed-off-by: David Dillow <dave@thedillows.org>

This change looks fine, but it reminds me of something.

We have to make sure there is no way for xfrm_offloads to
refer to a device when it is brought down.

One way to ensure that, is to make each xfrm_offload attached
grab a reference to the device it is for.  The refcounting will
help catch cases where stale xfrm_offload are around at
unregister_netdev() time.
