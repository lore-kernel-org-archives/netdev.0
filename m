From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual network
	device driver.
Date: Tue, 9 May 2006 16:39:11 -0700
Message-ID: <20060509233911.GI24291@moss.sous-sol.org>
References: <20060509084945.373541000@sous-sol.org>
	<20060509085201.446830000@sous-sol.org>
	<20060509115633.36b4879e@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xensource.com, Ian Pratt <ian.pratt@xensource.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Wright <chrisw@sous-sol.org>, virtualization@lists.osdl.org,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
Return-path: <xen-devel-bounces@lists.xensource.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060509115633.36b4879e@localhost.localdomain>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

* Stephen Hemminger (shemminger@osdl.org) wrote:
> The stuff in /proc could easily just be added attributes to the class_device kobject
> of the net device (and then show up in sysfs).

Agreed, it's on the todo list to drop proc support there.  Thought that
was marked in the patch.

> > +#define GRANT_INVALID_REF	0
> > +
> > +#define NET_TX_RING_SIZE __RING_SIZE((struct netif_tx_sring *)0, PAGE_SIZE)
> > +#define NET_RX_RING_SIZE __RING_SIZE((struct netif_rx_sring *)0, PAGE_SIZE)
> > +
> > +static inline void init_skb_shinfo(struct sk_buff *skb)
> > +{
> > +	atomic_set(&(skb_shinfo(skb)->dataref), 1);
> > +	skb_shinfo(skb)->nr_frags = 0;
> > +	skb_shinfo(skb)->frag_list = NULL;
> > +}
> 
> Could you use existing sk_buff_head instead of inventing your
> own skb queue?

Hmm, there is some standard skb_queue_tail happening.  I don't have a
clear idea what you mean.

> > +	u8 mac[ETH_ALEN];
> 
> Isn't mac address already stored in dev->dev_addr and/or dev->perm_addr?

Yes, I don't see the reason to keep in twice.  It's basically a temp
buffer, but it certainly appears we can eliminate it.

thanks,
-chris
