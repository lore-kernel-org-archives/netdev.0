From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Fw: [Bugme-new] [Bug 4566] New: B44 Randomly driver starts sending garbage and stops receiving
Date: Sun, 1 May 2005 00:28:41 +0200
Message-ID: <20050430222841.GA9172@xi.wantstofly.org>
References: <20050430142334.4fa8745d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, bonbons67@internet.lu
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050430142334.4fa8745d.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Apr 30, 2005 at 02:23:34PM -0700, Andrew Morton wrote:

> get following output (repeating at a high rate): 
> 22:33:01.018523 00:40:05:43:5e:fe > 01:80:c2:00:00:01, ethertype Unknown 
> (0x8808), length 60: 
>     0x0000: 0001 ffff 0000 0000 0000 0000 0000 0000 
>     0x0010: 0000 0000 0000 0000 0000 0000 0000 0000 
>     0x0020: 0000 0000 0000 0000 0000 0000 0000 
> dmesg does not produce any useful output about this. 

Isn't that a PAUSE frame?

Probably something in the b44 driver gets screwed so that it stops
processing RX traffic, the MAC's RX FIFO then fills up, and the
MAC (naturally) asserts flow control by periodically (in the range
of tens to hundreds of times per second) sending PAUSE frames to
its link partner as long as there's not enough space in its RX FIFO.

These PAUSE frames should not be seen by other hosts on the LAN,
though -- your switch should not autonegotiate flow control with
your b44 NIC if it doesn't support it.  (Or perhaps the b44 driver
enables flow control even though it hasn't been negotiated..)


--L
