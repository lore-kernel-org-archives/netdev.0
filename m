From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] Deadlock in af_packet/packet_rcv
Date: Tue, 30 Nov 2004 12:56:30 +0100
Message-ID: <41AC5FEE.8020707@tpack.net>
References: <20041125205503.GA18083@suse.de> <41AC3E2F.2030003@tpack.net> <20041130110110.GD16970@suse.de> <41AC5A26.6000400@tpack.net> <20041130114535.GF16970@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041130114535.GF16970@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Olaf Kirch wrote:
> On Tue, Nov 30, 2004 at 12:31:50PM +0100, Tommy Christensen wrote:
> 
>>I still don't agree with the conclusion, though. The spin_lock_bh()
>>is changed to a local_bh_disable() and an optional spin_lock().
>>That should not lead to what you are seeing!
> 
> 
> Well, the code in 2.6.9 has
> 
> #define HARD_TX_LOCK(dev, cpu) {                        \
> 	if ((dev->features & NETIF_F_LLTX) == 0) {      \
> 		spin_lock(&dev->xmit_lock);             \
> 		dev->xmit_lock_owner = cpu;             \
> 	}                                               \
> }
> 
> i.e. there's no local_bh_disable at all - adding the local_bh_disable
> was the whole point of my patch. Or did you refer to a different spinlock?

The local_bh_disable() is called earlier in dev_queue_xmit(), and
is held across the whole HARD_TX_LOCK/dev_queue_xmit_nit/
hard_start_xmit/HARD_TX_UNLOCK sequence.

-Tommy
