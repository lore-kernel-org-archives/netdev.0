From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch 7/11] net: Use bigrefs for net_device.refcount
Date: Tue, 13 Sep 2005 09:46:12 -0700
Message-ID: <20050913094612.7e8d611b@localhost.localdomain>
References: <20050913155112.GB3570@localhost.localdomain>
	<20050913161012.GI3570@localhost.localdomain>
	<20050913092659.791bddec@localhost.localdomain>
	<4326FFC2.7030803@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	dipankar@in.ibm.com, bharata@in.ibm.com, shai@scalex86.org,
	Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964874AbVIMQqL@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4326FFC2.7030803@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Sep 2005 09:35:14 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Stephen Hemminger wrote:
> > On Tue, 13 Sep 2005 09:10:12 -0700
> > Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
> > 
> > 
> >>The net_device has a refcnt used to keep track of it's uses.
> >>This is used at the time of unregistering the network device
> >>(module unloading ..) (see netdev_wait_allrefs) .
> >>For loopback_dev , this refcnt increment/decrement  is causing
> >>unnecessary traffic on the interlink for NUMA system
> >>affecting it's performance.  This patch improves tbench numbers by 6% on a
> >>8way x86 Xeon (x445).
> >>
> > 
> > 
> > Since when is bringing a network device up/down performance critical?
> 
> We grab and drop a reference for each poll of a device, roughly.
> 
> See dev_hold in _netif_rx_schedule(struct net_device *dev)
> in include/netdevice.h, for instance.

Yeah, that would be an issue, especially since the rest of that
path is nicely per-cpu
