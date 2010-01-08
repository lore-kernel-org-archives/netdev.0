From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3 appears to be sick in 2.6.33
Date: Fri, 8 Jan 2010 11:42:22 -0800
Message-ID: <20100108194222.GA8386@xw6200.broadcom.net>
References: <201001071156.31892.dmitry.torokhov@gmail.com>
 <20100108013600.GA2711@core.coreip.homeip.net>
 <20100108180915.GA8218@xw6200.broadcom.net>
 <201001081025.50298.dmitry.torokhov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jfeeney@redhat.com
To: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1059 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888Ab0AHTmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2010 14:42:39 -0500
In-Reply-To: <201001081025.50298.dmitry.torokhov@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 08, 2010 at 10:25:50AM -0800, Dmitry Torokhov wrote:
> On Friday 08 January 2010 10:09:15 am Matt Carlson wrote:
> > On Thu, Jan 07, 2010 at 05:36:00PM -0800, Dmitry Torokhov wrote:
> > > On Thu, Jan 07, 2010 at 04:14:54PM -0800, Dmitry Torokhov wrote:
> > > > On Thu, Jan 07, 2010 at 03:53:09PM -0800, Matt Carlson wrote:
> > > > > On Thu, Jan 07, 2010 at 02:45:43PM -0800, Dmitry Torokhov wrote:
> > > > > > On Thursday 07 January 2010 02:24:44 pm Eric Dumazet wrote:
> > > > > > > Le 07/01/2010 21:48, Matt Carlson a ?crit :
> > > > > > > > Nothing jumps to mind.  Let me see if I can repro this here.
> > > > > > > >
> > > > > > > > On Thu, Jan 07, 2010 at 11:56:31AM -0800, Dmitry Torokhov wrote:
> > > > > > > >> Hi,
> > > > > > > >>
> > > > > > > >> Ever since I moved post 2.6.32 tg3 seems to be very sick in my
> > > > > > > >> Latitude D630, it discards most of the packages for some
> > > > > > > >> reason:
> > > > > > > >>
> > > > > > > >> [root@dtor-d630 ~]# ethtool -S eth0 | grep rx_
> > > > > > > >>      rx_octets: 35886
> > > > > > > >>      rx_fragments: 0
> > > > > > > >>      rx_ucast_packets: 9
> > > > > > > >>      rx_mcast_packets: 93
> > > > > > > >>      rx_bcast_packets: 237
> > > > > > > >>      rx_fcs_errors: 0
> > > > > > > >>      rx_align_errors: 0
> > > > > > > >>      rx_xon_pause_rcvd: 0
> > > > > > > >>      rx_xoff_pause_rcvd: 0
> > > > > > > >>      rx_mac_ctrl_rcvd: 0
> > > > > > > >>      rx_xoff_entered: 0
> > > > > > > >>      rx_frame_too_long_errors: 0
> > > > > > > >>      rx_jabbers: 0
> > > > > > > >>      rx_undersize_packets: 0
> > > > > > > >>      rx_in_length_errors: 0
> > > > > > > >>      rx_out_length_errors: 0
> > > > > > > >>      rx_64_or_less_octet_packets: 0
> > > > > > > >>      rx_65_to_127_octet_packets: 0
> > > > > > > >>      rx_128_to_255_octet_packets: 0
> > > > > > > >>      rx_256_to_511_octet_packets: 0
> > > > > > > >>      rx_512_to_1023_octet_packets: 0
> > > > > > > >>      rx_1024_to_1522_octet_packets: 0
> > > > > > > >>      rx_1523_to_2047_octet_packets: 0
> > > > > > > >>      rx_2048_to_4095_octet_packets: 0
> > > > > > > >>      rx_4096_to_8191_octet_packets: 0
> > > > > > > >>      rx_8192_to_9022_octet_packets: 0
> > > > > > > >>      rx_discards: 304
> > > > > > > >>      rx_errors: 0
> > > > > > > >>      rx_threshold_hit: 0
> > > > > > > >>
> > > > > > > >> The above on last night pull from Linux (so 2.6.33+).
> > > > > > > >>
> > > > > > > >> Everything works fine if I use wireless or another wired card
> > > > > > > >> (Realtek in cardbus slot):
> > > > > > > >>
> > > > > > > >> [root@dtor-d630 ~]# lspci | grep -ri net
> > > > > > > >> 04:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> > > > > > > >> RTL-8139/8139C/8139C+ (rev 10)
> > > > > > > >> 09:00.0 Ethernet controller: Broadcom Corporation NetXtreme
> > > > > > > >> BCM5755M Gigabit Ethernet PCI Express (rev 02)
> > > > > > > >> 0c:00.0 Network controller: Intel Corporation PRO/Wireless
> > > > > > > >> 3945ABG [Golan] Network Connection (rev 02)
> > > > > > > >>
> > > > > > > >> [root@dtor-d630 ~]# ethtool eth0
> > > > > > > >> Settings for eth0:
> > > > > > > >>         Supported ports: [ TP ]
> > > > > > > >>         Supported link modes:   10baseT/Half 10baseT/Full
> > > > > > > >>                                 100baseT/Half 100baseT/Full
> > > > > > > >>                                 1000baseT/Half 1000baseT/Full
> > > > > > > >>         Supports auto-negotiation: Yes
> > > > > > > >>         Advertised link modes:  10baseT/Half 10baseT/Full
> > > > > > > >>                                 100baseT/Half 100baseT/Full
> > > > > > > >>                                 1000baseT/Half 1000baseT/Full
> > > > > > > >>         Advertised auto-negotiation: Yes
> > > > > > > >>         Speed: 1000Mb/s
> > > > > > > >>         Duplex: Full
> > > > > > > >>         Port: Twisted Pair
> > > > > > > >>         PHYAD: 1
> > > > > > > >>         Transceiver: internal
> > > > > > > >>         Auto-negotiation: on
> > > > > > > >>         Supports Wake-on: g
> > > > > > > >>         Wake-on: g
> > > > > > > >>         Current message level: 0x000000ff (255)
> > > > > > > >>         Link detected: yes
> > > > > > > >>
> > > > > > > >> Any ideas? Thanks!
> > > > > > >
> > > > > > > My laptop is a D630, and running 2.6.33-rc3 with no special
> > > > > > > problems on tg3
> > > > > >
> > > > > > This is wierd... It all works well with Fedora 12 kernel and .32 so
> > > > > > hardware is fine here. I think it also worked when I plugged it
> > > > > > into my home router (will try it again tonight). But in the office
> > > > > > it just does not want to work. It's like it just does not like the
> > > > > > addresses that we use here...
> > > > >
> > > > > Is the problem related to link speed?  I see that Eric was running at
> > > > > 100Mbps.  Your ethtool output above shows that you are running at
> > > > > 1Gbps.
> > > >
> > > > Indeed I have 100Mbps at home and 1Gb in the office.. I amy try playing
> > > > with it some more if you want but that patch you sent seems to have
> > > > fixed the issue for me...
> > > >
> > > > Except that sice I started using tg3 in couple of hours the box locked
> > > > up completely once and panicked twice; of course it happened in X so no
> > > > traces whatsoever. Maybe a coincidence though, I am running with nvidia
> > > > driver...
> > >
> > > No, something is definitely going on. I can work for a long time using
> > > the Realtek card but if I switch to tg3 then pretty quickly network gets
> > > stuck again and in a minute or so the box panics. Last time that
> > > happened I switched to the text console and managed to captute an oops
> > > (attached) but there is nothing really conclusive there...
> > >
> > > Thanks.
> > 
> > I looked over all the patches I submitted between tg3 versions 3.102
> > and 3.105.  Long story short, I didn't see anything particularly
> > suspicious.
> > 
> > Could you try dropping in the tg3.c and tg3.h from the 2.6.32 kernel
> > into your 2.6.33 source tree and see if you encounter the same problem?
> > 
> 
> skb_dma_map/unmap are gone from 2.6.33 so direct drop does not work :(

Ah.  I may have found the problem.  Can you apply the below patch on top
of the patch you already applied and see if this fixes the problem?

---------

[PATCH] tg3: Fix std rx prod ring handling

There are some tg3 devices that require the driver to post new rx
buffers in smaller increments.  Commit
4361935afe3abc3e5a93006b99197fac1fabbd50, "tg3: Consider
rx_std_prod_idx a hw mailbox" changed how the driver tracks the rx
producer ring updates, but it does not make any special considerations
for the above-mentioned devices.  For those devices, it is possible for
the driver to hit the special case path, which updates the hardware
mailbox register but skips updating the shadow software mailbox member.
If the special case path represents the final mailbox update for this
ISR iteration, the hardware and software mailbox values will be out of
sync.  Ultimately, this will cause the driver to use a stale mailbox
value on the next iteration, which will appear to the hardware as a
large rx buffer update.  Bad things ensue.

The fix is to update the software shadow mailbox member when the special
case path is taken.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5c77e6a..4e8b87d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4693,8 +4693,9 @@ next_pkt:
 		(*post_ptr)++;
 
 		if (unlikely(rx_std_posted >= tp->rx_std_max_post)) {
-			u32 idx = *post_ptr % TG3_RX_RING_SIZE;
-			tw32_rx_mbox(TG3_RX_STD_PROD_IDX_REG, idx);
+			tpr->rx_std_prod_idx = std_prod_idx % TG3_RX_RING_SIZE;
+			tw32_rx_mbox(TG3_RX_STD_PROD_IDX_REG,
+				     tpr->rx_std_prod_idx);
 			work_mask &= ~RXD_OPAQUE_RING_STD;
 			rx_std_posted = 0;
 		}
-- 
1.6.4.4


