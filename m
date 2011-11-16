From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v5 07/10] forcedeth: implement
 ndo_get_stats64() API
Date: Wed, 16 Nov 2011 17:14:54 +0000
Message-ID: <1321463694.2709.1.camel@bwh-desktop>
References: <cover.1321420513.git.david.decotigny@google.com>
	 <dcc1ec263220b7bb1f7271933c30a8f89c19d991.1321420513.git.david.decotigny@google.com>
	 <20111116085533.0982001e@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Decotigny <david.decotigny@google.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111116085533.0982001e@s6510.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-11-16 at 08:55 -0800, Stephen Hemminger wrote:
> On Tue, 15 Nov 2011 21:15:55 -0800
> David Decotigny <david.decotigny@google.com> wrote:
> 
> > This commit implements the ndo_get_stats64() API for forcedeth. Since
> > these stats are being updated from different contexts (process and
> > timer), this commit adds protection (locking + atomic variables).
> > 
> > Tested:
> >   - 16-way SMP x86_64 ->
> >     RX bytes:7244556582 (7.2 GB)  TX bytes:181904254 (181.9 MB)
> >   - pktgen + loopback: identical rx_bytes/tx_bytes and rx_packets/tx_packets
> 
> Rather than adding additional locking why not use a percpu structure
> to hold statistics. See loopback, macvlan, veth, xen-netfront.

percpu is stupid for a single-queue driver.

> Or realize that the Tx side is single threaded by dev->xmit_lock already
> and the Rx side is single threaded by NAPI.

Right.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
