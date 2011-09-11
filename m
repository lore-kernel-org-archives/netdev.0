From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Sun, 11 Sep 2011 21:52:38 +0300
Message-ID: <20110911185238.GB4740@redhat.com>
References: <20110911093832.GD27096@redhat.com>
 <CA92031A.33DE1%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dragos.tatulea@gmail.com, arnd@arndb.de,
	dwang2@cisco.com, benve@cisco.com, kaber@trash.net, sri@us.ibm.com,
	davem@davemloft.net, eric.dumazet@gmail.com, mchan@broadcom.com,
	kvm@vger.kernel.org
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA92031A.33DE1%roprabhu@cisco.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 11, 2011 at 06:18:02AM -0700, Roopa Prabhu wrote:
> 
> 
> 
> On 9/11/11 2:38 AM, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > On Fri, Sep 09, 2011 at 09:33:33AM -0700, Roopa Prabhu wrote:
> >> 
> >> 
> >> 
> >> On 9/8/11 10:55 PM, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> >> 
> >>> On Thu, Sep 08, 2011 at 07:53:11PM -0700, Roopa Prabhu wrote:
> >>>>>> Phase 1: Goal: Enable hardware filtering for all macvlan modes
> >>>>>>     - In macvlan passthru mode the single guest virtio-nic connected will
> >>>>>>       receive traffic that he requested for
> >>>>>>     - In macvlan non-passthru mode all guest virtio-nics sharing the
> >>>>>>       physical nic will see all other guest traffic
> >>>>>>       but the filtering at guest virtio-nic
> >>>>> 
> >>>>> I don't think guests currently filter anything.
> >>>>> 
> >>>> I was referring to Qemu-kvm virtio-net in
> >>>> virtion_net_receive->receive_filter. I think It only passes pkts that the
> >>>> guest OS is interested. It uses the filter table that I am passing to
> >>>> macvtap in this patch.
> >>> 
> >>> This happens after userspace thread gets woken up and data
> >>> is copied there. So relying on filtering at that level is
> >>> going to be very inefficient on a system with
> >>> multiple active guests. Further, and for that reason, vhost-net
> >>> doesn't do filtering at all, relying on the backends
> >>> to pass it correct packets.
> >> 
> >> Ok thanks for the info. So in which case, phase 1 is best for PASSTHRU mode
> >> and for non-PASSTHRU when there is a single guest connected to a VF.
> >> For non-PASSTHRU multi guest sharing the same VF, Phase 1 is definitely
> >> better than putting the VF in promiscuous mode.
> >> But to address the concern you mention above, in phase 2 when we have more
> >> than one guest sharing the VF,
> > 
> > It's probably more interesting for a card without SRIOV support.
> > 
> If its an SRIOV card I am assuming people likely using PASSTHRU mode.
> Non-SRIOV cards will use any of the non-PASSTHRU mode.
> 
> 
> >> we will have to add filter lookup in macvlan
> >> to filter pkts for each guest.
> > 
> > Any chance to enable hardware filters for that?
> > 
> NAFAIK. Am not sure how you would do it too. Its still a single device from
> where the host receives traffic from.
> 
> Thanks,
> Roopa

VMDQ cards might let you program mac addresses for individula rings.


-- 
MST
