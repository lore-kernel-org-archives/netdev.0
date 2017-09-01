From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: switchdev: Clear forward mark when
 transmitting packet
Date: Fri, 01 Sep 2017 10:12:00 -0700 (PDT)
Message-ID: <20170901.101200.1178632155073906923.davem@davemloft.net>
References: <20170901092225.31597-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mlxsw@mellanox.com, yotamg@mellanox.com, nikolay@cumulusnetworks.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	jiri@mellanox.com
To: idosch@mellanox.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170901092225.31597-1-idosch@mellanox.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Ido Schimmel <idosch@mellanox.com>
Date: Fri,  1 Sep 2017 12:22:25 +0300

> Commit 6bc506b4fb06 ("bridge: switchdev: Add forward mark support for
> stacked devices") added the 'offload_fwd_mark' bit to the skb in order
> to allow drivers to indicate to the bridge driver that they already
> forwarded the packet in L2.
> 
> In case the bit is set, before transmitting the packet from each port,
> the port's mark is compared with the mark stored in the skb's control
> block. If both marks are equal, we know the packet arrived from a switch
> device that already forwarded the packet and it's not re-transmitted.
> 
> However, if the packet is transmitted from the bridge device itself
> (e.g., br0), we should clear the 'offload_fwd_mark' bit as the mark
> stored in the skb's control block isn't valid.
> 
> This scenario can happen in rare cases where a packet was trapped during
> L3 forwarding and forwarded by the kernel to a bridge device.
> 
> Fixes: 6bc506b4fb06 ("bridge: switchdev: Add forward mark support for stacked devices")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Yotam Gigi <yotamg@mellanox.com>
> Tested-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Applied and queued up for -stable, thanks.
