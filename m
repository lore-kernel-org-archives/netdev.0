From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 2.6.10 3/22] xfrm: Add offload management routines
Date: Fri, 21 Jan 2005 14:47:38 -0800
Message-ID: <20050121144738.7155893e.davem@davemloft.net>
References: <20041230035000.11@ori.thedillows.org>
	<20041230035000.12@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <20041230035000.12@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Dec 2004 03:48:35 -0500
David Dillow <dave@thedillows.org> wrote:

> +static inline struct xfrm_offload *
> +xfrm_offload_alloc(int sizeof_priv, struct net_device *dev)

This whole scheme looks buggy.  The intent is to 8-byte align
the object, but look at what the code is actually doing.

Whatever kmalloc() returns to xfrm_offload_alloc() is directly
used as the xfrm_offload pointer, and the members are initialized.

Then xfrm_offload_priv() does the alignments.

It is clear that kmalloc() is always giving you 8-byte aligned
data else the first time xfrm_offload_priv() is used you'd
get a bogus pointer since xfrm_offload_alloc() initialized
the object without first aligning the pointer.

We do something similar when we allocate netdevs, so have a look
at how net/core/dev.c:alloc_netdev() works.
