From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 10:02:05 -0700
Message-ID: <1282842125.1875.124.camel@Joe-Laptop>
References: <4C763A67.5040107@dsn.okisemi.com>
	 <20100826090504.30ce58e5@nehalam> <1282839372.1875.78.camel@Joe-Laptop>
	 <20100826092929.72b61549@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
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
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100826092929.72b61549@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-08-26 at 09:29 -0700, Stephen Hemminger wrote:
> On Thu, 26 Aug 2010 09:16:12 -0700
> Joe Perches <joe@perches.com> wrote:
> > My message logging order preference:
> > if there's a netif_msg_<type> and a struct net_device
> > 	netif_<level>		(struct private *, netif_msg_<type>,
> > 				 struct net_device *, fmt, args...)
> > if there's a struct net_device
> > 	netdev_<level>		(struct net_device *, fmt, args...)
> > if there's a struct device
> > 	dev_<level>		(struct device *, fmt, args...)
> > otherwise
> > 	pr_<level>		(fmt, args...)
> At this point in process, netdevice isn't registered so it
> doesn't have a ethX name. so dev_info would be best.

Yes, likely true.

Ideally netdev_<level> is used after register_netdev.
The default "eth%d" is printed after alloc_netdev
but before register_netdev.

Before commmit 256df2f3879efdb2e9808bdb1b54b16fbb11fa38
when netdev_<level>s were converted to functions, they
would also dereference a NULL pointer if used before
register_netdev.
