From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Change MAC without bringing interface down
Date: Mon, 18 Aug 2003 04:19:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818041911.358c3437.davem@redhat.com>
References: <20030818091312.GA4889@lapdog>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommi Virtanen <tv@debian.org>
In-Reply-To: <20030818091312.GA4889@lapdog>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 12:13:12 +0300
Tommi Virtanen <tv@debian.org> wrote:

> 	Here's a patch that
> 
> 	1. makes eth_header_cache_update also update the source MAC in
> 	   hh_cache.
> 
> 	2. adds a NETDEV_CHANGEADDR notifier in net/core/neighbour.c
> 	   that walks through all the neighbour entries and updates
> 	   the hh_cache's for all the neighbour entries related to
> 	   given device.
> 
> 	3. adds neighbour_init() to allow registration of said notifier.

I would suggest to fix this by instead flushing the hh
entries (just like neigh_destroy() does).

This way, we don't have to fix up every single header cache
implementation, that's painful :(
