From: jamal <hadi@cyberus.ca>
Subject: Re: network lockup with latest BK (LLTX?)
Date: 14 Sep 2004 10:53:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095173628.1030.3.camel@jzny.localdomain>
References: <20040914142447.GA5615@krispykreme>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20040914142447.GA5615@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Yep LLTX, use patch posted by Andi yesterday.

cheers,
jamal

On Tue, 2004-09-14 at 10:24, Anton Blanchard wrote:
> Hi,
> 
> I have a machine with a number of e1000 adapters in it. It locked up
> while I was bringing up the network interfaces. I have attached
> backtraces of all relevant cpus.
> 
> There are a bunch of cpus in arp_xmit -> dev_queue_xmit, these all
> appear to be stuck on the dev->queue_lock. Looking closer, all cpus
> other than cpu 4 are stuck on the same spinlock. And since we store the
> cpu number in our spinlocks, we know that this lock is owned by cpu4.
> 
> Looking at cpu4:
> 
> pfifo_fast_dequeue+0x58/0x78
