From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Wed, 8 Sep 2010 07:55:45 -0700
Message-ID: <20100908075545.79023fa9@nehalam>
References: <4C81019E.1010808@dsn.okisemi.com>
	<4C8123D6.8020001@suse.cz>
	<003901cb4f5d$bf977c80$66f8800a@maildom.okisemi.com>
	<4C879AAB.6000905@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	ML netdev <netdev@vger.kernel.org>,
	MeeGo <meego-dev@meego.com>, Maxime Bizon <mbizon@freebox.fr>,
	LKML <linux-kernel@vger.kernel.org>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	John Linn <john.linn@xilinx.com>,
	Joe Perches <joe@perches.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C879AAB.6000905@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 08 Sep 2010 16:16:11 +0200
Jiri Slaby <jslaby@suse.cz> wrote:

> >>> +
> >>> + rxdr->count = max(ring->rx_pending, (u32) PCH_GBE_MIN_RXD);
> >>> + rxdr->count = min(rxdr->count, (u32) PCH_GBE_MAX_RXD);  
> >>
> >> clamp()
> >> And why you need the cast?  
> > 
> > [masa]
> > Since warning appears at the time of a make.  
> 
> OK, then you have type error which you should fix instead. Perhaps
> define the constnts with U suffix?

Better yet:
	rxdr->count = clamp_val(ring->rx_pending,
				PCH_GBE_MIN_RXD,
				PCH_GBE_MAX_RXD);
