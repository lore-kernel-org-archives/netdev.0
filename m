From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/3] NET: Generic rate estimator
Date: Sun, 3 Oct 2004 16:14:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003161436.50293f9a.davem@davemloft.net>
References: <20041003213124.GG14344@postel.suug.ch>
	<20041003213954.GI14344@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041003213954.GI14344@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 3 Oct 2004 23:39:54 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Introduces a generic rate estimator based on timers. Patch is based on
> Jamal's patch and adapted to the new generic network statistics API.

First, how does this new thing ever get built into the tree?

Second:

> +#if (HZ%4) != 0
> +#error Bad HZ value.
> +#endif

This is going to fail to compile on a few platforms, namely m68knommu
and v850 which have configurations that result in using a HZ value
of 50 and 122 respectively.

Otherwise I mostly like all of the new generic stats stuff, although
I do have one question:

+int
+gnet_stats_start_copy_compat(struct sk_buff *skb, int type, int tc_stats_type,
+	int xstats_type, spinlock_t *lock, struct gnet_dump *d)
+{
 ...
+	return gnet_stats_copy(d, type, NULL, 0);

What is this dummy zero-sized RTA_PUT() being done for
(via the gnet_stats_copy() call with size==0 arg)?
