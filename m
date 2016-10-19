From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next 00/15] ethernet: use core min/max MTU checking
Date: Tue, 18 Oct 2016 22:35:45 -0400
Message-ID: <20161019023545.GX14983@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
 <20161017.160341.529517225075047124.davem@davemloft.net>
 <20161017202943.GP14983@redhat.com>
 <20161018.113327.621225542297731341.davem@davemloft.net>
 <20161018222820.GW14983@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161018222820.GW14983@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2016 at 06:28:20PM -0400, Jarod Wilson wrote:
> On Tue, Oct 18, 2016 at 11:33:27AM -0400, David Miller wrote:
> > From: Jarod Wilson <jarod@redhat.com>
> > Date: Mon, 17 Oct 2016 16:29:43 -0400
> > 
> > > On Mon, Oct 17, 2016 at 04:03:41PM -0400, David Miller wrote:
> > >> From: Jarod Wilson <jarod@redhat.com>
> > >> Date: Mon, 17 Oct 2016 15:54:02 -0400
> > >> 
> > >> > For the most part, every patch does the same essential thing: removes the
> > >> > MTU range checking from the drivers' ndo_change_mtu function, puts those
> > >> > ranges into the core net_device min_mtu and max_mtu fields, and where
> > >> > possible, removes ndo_change_mtu functions entirely.
> > >> 
> > >> Jarod, please read my other posting.
> > > 
> > > Done, didn't see it until just after I'd hit send, have replied there as
> > > well.
> > > 
> > >> You've positively broken the maximum MTU for all of these drivers.
> > >> 
> > >> That's not cool.
> > >>
> > >> And this series fixing things doesn't make things better, because now
> > >> we've significanyly broken bisection for anyone running into this
> > >> regression.
> > > 
> > > Agreed, and my suggestion right now is to revert the 2nd patch from the
> > > prior series. I believe it can be resubmitted after all other callers of
> > > ether_setup() have been converted to have their own min/max_mtu.
> > > 
> > >> You should have arranged this in such a way that the drivers needing
> > >> > 1500 byte MTU were not impacted at all by your changes, but that
> > >> isn't what happened.
> > > 
> > > Yeah, I must admit to not looking closely enough at the state the first
> > > two patches left things in. It was absolutely my intention to not alter
> > > behaviour in any way, but I neglected to test sufficiently without this
> > > additional set applied.
> > 
> > So what I'm going to do now it simply just apply your current patch series
> > to net-next and hope this gets everything working again.
> 
> Unfortunately, no, it doesn't get *everything* working again, because...
> 
> direct ether_setup() callers:
> 
> drivers/misc/sgi-xp/xpnet.c
> drivers/net/geneve.c
> drivers/net/macvlan.c
> drivers/net/tun.c
> drivers/net/vxlan.c
> drivers/net/wan/hdlc.c
> drivers/net/wan/hdlc_fr.c
> drivers/net/wireless/ath/wil6210/netdev.c
> drivers/net/wireless/cisco/airo.c
> drivers/staging/wlan-ng/p80211netdev.c
> net/batman-adv/soft-interface.c
> net/bridge/br_device.c
> net/openvswitch/vport-internal_dev.c
> 
> alloc_etherdev*() callers:
> drivers/infiniband/hw/nes/nes_nic.c
> drivers/net/hyperv/netvsc_drv.c
> drivers/net/rionet.c
> drivers/net/usb/lan78xx.c
> drivers/net/usb/r8152.c
> drivers/net/usb/usbnet.c
> drivers/net/virtio_net.c
> drivers/net/vmxnet3/vmxnet3_drv.c
> drivers/net/wireless/atmel/atmel.c
> drivers/net/wireless/cisco/airo.c
> drivers/net/wireless/intel/ipw2x00/libipw_module.c
> net/atm/lec.c
> 
> I have additional patches for all of these that I haven't yet posted, so
> I'd still suggest backing out the one patch to keep the above working too
> until the subsequent patches are posted.

They're all posted now, just 6 more relatively small patches, though the
ones touching geneve and vxlan are a bit more involved than any others,
and could use a very close look (relevant people should all be cc'd).
Still wouldn't have any objection at all to backing out the patch that
touches min/max_mtu in ether_setup() though.

-- 
Jarod Wilson
jarod@redhat.com
