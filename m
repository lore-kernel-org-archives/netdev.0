From: Bob Tracy <rct@gherkin.frus.com>
Subject: Re: [BUG] 3.12.0-rcX IPv6 panic
Date: Mon, 28 Oct 2013 23:00:17 -0500
Message-ID: <20131029040017.GA27979@gherkin.frus.com>
References: <20131021131846.GA5769@gherkin.frus.com>
 <20131021155252.GA24158@order.stressinduktion.org>
 <20131021234041.GA12350@gherkin.frus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131021234041.GA12350@gherkin.frus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 21, 2013 at 06:40:41PM -0500, Bob Tracy wrote:
> On Mon, Oct 21, 2013 at 05:52:52PM +0200, Hannes Frederic Sowa wrote:
> > On Mon, Oct 21, 2013 at 08:18:46AM -0500, Bob Tracy wrote:
> > > Actually, a regression: the 3.11 kernel is rock-solid stable on my
> > > Alpha.
> > > 
> > > Beginning with 3.12.0-rc1, I can reliably trigger a kernel panic by
> > > executing the gogo6.net "gw6c" IPv6 client program.  If the networking
> > > layer is active, an "Oops" will eventually (within a day) occur regardless
> > > of whether I attempt to run "gw6c".  3.12.0-rcX is stable as long as I
> > > leave networking completely disabled.  The error has persisted up through
> > > -rc6.  Apologies for not mentioning this earlier, but the state of my
> > > PWS-433au has been questionable, and I wanted to make sure I had a
> > > legitimate bug sighting.
> > > 
> > > I'll have to transcribe the panic backtrace by hand: nothing makes it
> > > into any of the system logs :-(.  I *can* recall that every backtrace
> > > I've seen thus far has included one of the skb_copy() variants near the
> > > top of the list (first or second function).
> > 
> > Try to capture the panic via serial console. Otherwise a picture
> > would give us a first hint. Please watch out for lines like
> > skb_(over|under)_panic.
> 
> I'll get a screen capture of some kind for you within the next day or
> so.
> 
> > gw6c is a tunnel client? Can you post ip -6 tunnel ls?
> 
> Assuming you meant "show [NAME]" (no "ls" option for the tunnel object),
> that yields the following with "gw6c" running on a 3.11.0 kernel:
> 
> smirkin:~# ip -6 tunnel show sit1
> sit1: any/ipv6 remote 4056:5874:: local 4500:0:0:4000:4029:: encaplimit 0 hoplimit 0 tclass 0x00 flowlabel 0x00000 (flowinfo 0x00000000)
> 
> I'm running the gw6c client in gateway mode: the Alpha is my IPv6
> gateway/firewall.

Update: no significant change for 3.12.0-rc7.  Can still reliably panic
the system by running "gw6c" to set up the IPv6 tunnel.  Here's a hand-
transcribed backtrace: I hope it's sufficient...  I would have included
the stack/register dump, but about half of it had scrolled off the top
of the screen.

skb_copy_and_csum_bits+0x88/0x380
icmp_glue_bits+0x48/0xce0
__ip_append_data+0x8f4/0xb40
ip_append_data+0xb0/0x130
icmp_glue_bits+0x0/0xe0
icmp_glue_bits+0x0/0xe0  (yes: repeated once)
icmp_push_reply+0x6c/0x190
icmp_send+0x3fc/0x4c0
ip_local_deliver_finish+0x20c/0x2e0
ip_rcv_finish+0x1d8/0x3d0
nf_ct_attach+0x32/0x40
ip_rcv_finish_0x148/0x3d0
__netif_receive_skb_core+0x27c/0x890
process_backlog+0xb8/0x1a0
net_rx_action+0xc8/0x210
__do_softirq+0x1a0/0x230
do_softirq+0x5c/0x70
irq_exit+0x68/0x80
handle_irq+0x90/0xf0
miata_srm_device_interrupt+0x30/0x50
do_entInt+0x1cc/0x1f0
__do_fault+0x3e0/0x5e0
ret_from_sys_call+0x0/0x10
entMM+0x9c/0xc0
do_page_fault+0x0/0x500
do_page_fault+0x48/0x500
entMM+0x9c/0xc0
filp_close+0x6c/0xe0
filp_close+0x98/0xe0
filp_close+0x6c/0xe0
filp_close+0x98/0xe0
__close_fd+0xb8/0xe0

Code: 44640003 e4600010 203ffff2 a77de680 b67e0010 47f10410 <b0340000> 47ff0411

--Bob
