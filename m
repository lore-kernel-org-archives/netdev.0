From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Extend lock less TX to real devices
Date: Wed, 1 Sep 2004 22:33:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040901223301.1a8d97a8.davem@redhat.com>
References: <m38ybvjxdv.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m38ybvjxdv.fsf@averell.firstfloor.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 31 Aug 2004 14:38:20 +0200
Andi Kleen <ak@muc.de> wrote:

> This patch extends the recently added NETIF_F_LLTX to real devices.

Well, it does a lot of other things too.

> I added support for trylocking instead of spinning like sch_generic
> does - for that the driver has to return -1, then the packet is requeued.
> The check for a local device deadlock is lost for this case, 
> but that doesn't seem to be a big loss (I've never seen this printk 
> ever get triggered)

It is triggerable if you misconfigure your system.
I'm totally against this change, because previously at
least the user would find out in their logs.  With your
change the system explodes looping with no explanation why.

> The patch looks bigger than it really is because i moved some code
> around and converted the macros into inlines. 
 ..
> I also did an additional micro optimization:

And for this reason you need to split this patch up.
I would recommend:

patch 1) Change macros into inlines
patch 2) local_bh_disable() preemption count optimization
patch 3) support for F_LLTX on real devices
patch 4) locking changes

Thanks Andi.
