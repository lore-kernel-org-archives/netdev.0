From: Matt Mackall <mpm@selenic.com>
Subject: Re: netconsole: tulip: possible remote DoS? due to kernel freeze
 on heavy RX traffic after Order-1 allocation failure
Date: Thu, 05 Nov 2009 13:49:38 -0600
Message-ID: <1257450578.2873.609.camel@calx>
References: <20091105113106.GA4373@yumi.tdiedrich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758835AbZKETuJ@vger.kernel.org>
In-Reply-To: <20091105113106.GA4373@yumi.tdiedrich.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-11-05 at 12:31 +0100, Tobias Diedrich wrote:
> On one of my rootservers, which is using the tulip driver for the
> onboard network interface, I am seeing Order-1 allocation failures
> on heavy RX traffic, which usually hang the machine.
> As in I'm unable to ping it and after forcing a reboot using the
> management interface I don't see the allocation failure message in
> /var/log/kern.log, even though I saw (parts) of it over the
> netconsole.
> 
> Unfortunately the netconsole target is not on the LAN, but a
> different rootserver on the internet a few hops away, which means
> bursts of udp Packets are lossy and can get reordered...
> 
> I first thought this was introduced in 2.6.31, but it is only easier
> to trigger there.  Reducing vm.min_free_pages made it easy enough to
> trigger also on 2.6.30.
> 
> Example from netconsole log:
> |perl: page allocation failure. order:1, mode:0x20
> |Pid: 3541, comm: perl Tainted: G        W  2.6.30.9-tomodachi #16
> |Call Trace:
> | [<c013e56d>] ? __alloc_pages_internal+0x353/0x36f
> | [<c0154f2c>] ? cache_alloc_refill+0x2ab/0x544
> | [<c0355479>] ? dev_alloc_skb+0x11/0x25
> | [<c015526f>] ? __kmalloc_track_caller+0xaa/0xf9
> | [<c0354ae5>] ? __alloc_skb+0x48/0xff
> | [<c0355479>] ? dev_alloc_skb+0x11/0x25
> | [<c02d4ba9>] ? tulip_refill_rx+0x3c/0x115
> | [<c02d4fff>] ? tulip_poll+0x37d/0x416
> | [<c0359763>] ? net_rx_action+0x6b/0x12f
> | [<c0121ad7>] ? __do_softirq+0x4e/0xbf
> | [<c0121a89>] ? __do_softirq+0x0/0xbf
> | <IRQ>  [<c0107700>] ? do_IRQ+0x53/0x63
> | [<c0106610>] ? common_interrupt+0x30/0x38

I don't see anything in this trace to implicate netconsole? This is the
normal network receive path running out of input buffers then running
into memory fragmentation.

-- 
http://selenic.com : development and support for Mercurial and Linux
