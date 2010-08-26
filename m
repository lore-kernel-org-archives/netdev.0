From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 09:29:29 -0700
Message-ID: <20100826092929.72b61549@nehalam>
References: <4C763A67.5040107@dsn.okisemi.com>
	<20100826090504.30ce58e5@nehalam>
	<1282839372.1875.78.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282839372.1875.78.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Aug 2010 09:16:12 -0700
Joe Perches <joe@perches.com> wrote:

> On Thu, 2010-08-26 at 09:05 -0700, Stephen Hemminger wrote:
> > +	for (i = 0; i < 6; i++)
> > +		printk(KERN_INFO "%2.2x%c",
> > +			netdev->dev_addr[i], i == 5 ? '\n' : ':');
> > 
> > you just want:
> >          printk(KERN_INFO "%pM", netdev->dev_addr);
> > 
> > or better yet, convert to dev_printk
> 
> or perhaps better still convert to netdev_info
> 
> My message logging order preference:
> 
> if there's a netif_msg_<type> and a struct net_device
> 	netif_<level>		(struct private *, netif_msg_<type>,
> 				 struct net_device *, fmt, args...)
> if there's a struct net_device
> 	netdev_<level>		(struct net_device *, fmt, args...)
> if there's a struct device
> 	dev_<level>		(struct device *, fmt, args...)
> otherwise
> 	pr_<level>		(fmt, args...)
> 
> 

At this point in process, netdevice isn't registered so it
doesn't have a ethX name. so dev_info would be best.

-- 
