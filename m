From: Baruch Even <baruch@ev-en.org>
Subject: Re: netif_rx packet dumping
Date: Thu, 03 Mar 2005 21:26:58 +0000
Message-ID: <42278122.6000000@ev-en.org>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Injong Rhee <rhee@eos.ncsu.edu>, John Heffner <jheffner@psc.edu>,
        "David S. Miller" <davem@davemloft.net>,
        Yee-Ting Li <Yee-Ting.Li@nuim.ie>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050303123811.4d934249@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Both BIC TCP 1.1 and TCP-H include patches to disable the queue
> throttling behaviour of netif_rx. The existing throttling algorithm
> causes all packets to be dumped (until queue emptys) when the packet
> backlog reaches netdev_max_backog. I suppose this is some kind of DoS
> prevention mechanism. The problem is that this dumping action creates
> mulitple packet loss that forces TCP back to slow start.
> 
> But, all this is really moot for the case of any reasonably high speed
> device because of NAPI. netif_rx is not even used for any device that uses NAPI. 
> The NAPI code path uses net_receive_skb and the receive queue management is done
> by the receive scheduling (dev->quota) of the rx_scheduler.
> 
> My question is why did BIC TCP and TCP-H turn off the throttling?
> Was it because they were/are using older 2.4 devices without NAPI.

NAPI was not used because it caused skews in the performance, I haven't 
tested it myself, just passing hearsay.

I have patches for the SACK processing to improve performance which 
should reduce the problems with the queues, but they are for 2.6.6 and 
forward porting them to 2.6.11 is quite a bit of work (too much was 
changed in conflicting areas). I hope to get to work on this soon.

The bad effect of the queue throttling was mostly the killed ack clock 
and the fact that recovery was only when timeout happened. Preferably 
only the packets that don't fit should be dropped, but the queue 
emptying should not be waited for.

Baruch
