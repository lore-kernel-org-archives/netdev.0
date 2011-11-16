From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v5 07/10] forcedeth: implement
 ndo_get_stats64() API
Date: Wed, 16 Nov 2011 08:55:33 -0800
Message-ID: <20111116085533.0982001e@s6510.linuxnetplumber.net>
References: <cover.1321420513.git.david.decotigny@google.com>
	<dcc1ec263220b7bb1f7271933c30a8f89c19d991.1321420513.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dcc1ec263220b7bb1f7271933c30a8f89c19d991.1321420513.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Nov 2011 21:15:55 -0800
David Decotigny <david.decotigny@google.com> wrote:

> This commit implements the ndo_get_stats64() API for forcedeth. Since
> these stats are being updated from different contexts (process and
> timer), this commit adds protection (locking + atomic variables).
> 
> Tested:
>   - 16-way SMP x86_64 ->
>     RX bytes:7244556582 (7.2 GB)  TX bytes:181904254 (181.9 MB)
>   - pktgen + loopback: identical rx_bytes/tx_bytes and rx_packets/tx_packets

Rather than adding additional locking why not use a percpu structure
to hold statistics. See loopback, macvlan, veth, xen-netfront.

Or realize that the Tx side is single threaded by dev->xmit_lock already
and the Rx side is single threaded by NAPI.
