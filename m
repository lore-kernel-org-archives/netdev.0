From: Stephen Hemminger <shemminger@osdl.org>
Subject: netif_rx packet dumping
Date: Thu, 3 Mar 2005 12:38:11 -0800
Message-ID: <20050303123811.4d934249@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Injong Rhee <rhee@eos.ncsu.edu>, John Heffner <jheffner@psc.edu>,
        "David
 S. Miller" <davem@davemloft.net>,
        Yee-Ting Li <Yee-Ting.Li@nuim.ie>, Baruch
 Even <baruch@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Both BIC TCP 1.1 and TCP-H include patches to disable the queue
throttling behaviour of netif_rx. The existing throttling algorithm
causes all packets to be dumped (until queue emptys) when the packet
backlog reaches netdev_max_backog. I suppose this is some kind of DoS
prevention mechanism. The problem is that this dumping action creates
mulitple packet loss that forces TCP back to slow start.

But, all this is really moot for the case of any reasonably high speed
device because of NAPI. netif_rx is not even used for any device that uses NAPI. 
The NAPI code path uses net_receive_skb and the receive queue management is done
by the receive scheduling (dev->quota) of the rx_scheduler.

My question is why did BIC TCP and TCP-H turn off the throttling?
Was it because they were/are using older 2.4 devices without NAPI.
