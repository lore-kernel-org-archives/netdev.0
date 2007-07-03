From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/2] net: make net and forcedeth to use kmalloc_node
Date: Tue, 3 Jul 2007 14:34:07 -0700
Message-ID: <20070703143407.7e4232f8@freepuppy.localdomain.hemminger.net>
References: <200706291330.37070.yinghai.lu@sun.com>
	<20070703115840.e05a0f47.akpm@linux-foundation.org>
	<20070703120430.4dcbba68@freepuppy.localdomain.hemminger.net>
	<468ABF92.5030800@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>,
	Greg KH <greg@kroah.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Yinghai.Lu@Sun.COM
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757879AbXGCVfK@vger.kernel.org>
In-Reply-To: <468ABF92.5030800@sun.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 03 Jul 2007 14:28:50 -0700
Yinghai Lu <Yinghai.Lu@Sun.COM> wrote:

> Stephen Hemminger wrote:
> > On Tue, 3 Jul 2007 11:58:40 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> >> On Fri, 29 Jun 2007 13:30:36 -0700
> >> Yinghai Lu <Yinghai.Lu@Sun.COM> wrote:
> >>
> >>> [PATCH 2/2] net: make net and forcedeth to use kmalloc_node
> >> Please copy netdev@vger.kernel.org on net patches.
> >>
> >> This patch modifies a net driver as well as the networking core.  These
> >> subsytems have different maintainers who run different development trees. 
> >> Consequently I must split your patch into two and change their titles and
> >> changelogs appropriately.
> >>
> >> Please do this for us in future, thanks.
> >>
> >>
> >>> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> >>> index 42ba1c0..6d53b52 100644
> >>> --- a/drivers/net/forcedeth.c
> >>> +++ b/drivers/net/forcedeth.c
> >>> @@ -1383,7 +1383,7 @@ static int nv_alloc_rx(struct net_device *dev)
> >>>  		less_rx = np->last_rx.orig;
> >>>  
> >>>  	while (np->put_rx.orig != less_rx) {
> >>> -		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
> >>> +		struct sk_buff *skb = dev_alloc_skb_node(np->rx_buf_sz + NV_RX_ALLOC_PAD, dev_to_node(&dev->dev));
> >> If we're going to do this then it would probably make sense to change
> >> dev_alloc_skb_node() so that it takes a `struct net_device *' rather than a
> >> bare node-id.  That's a call which the net guys will need to make, which is
> >> why we cc them on our emails.
> > 
> > The driver should use netdev_alloc_skb. That routine is supposed to be overriden
> > on architecture's that need per node changes.
> 
> do you mean:
> use dev_alloc_skb_node for numa arch.

Look at __netdev_alloc_skb() source. It does all the necessary dev_to_node()
stuff.

dev_alloc_skb is the old routine and kept around only because not all
usage has been converted yet. It should probably be deprecated at some point.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
