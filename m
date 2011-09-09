From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Fri, 9 Sep 2011 08:55:30 +0300
Message-ID: <20110909055530.GA4647@redhat.com>
References: <20110908182509.GB469@redhat.com>
 <CA8ECDA7.33BFA%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dragos.tatulea@gmail.com, arnd@arndb.de,
	dwang2@cisco.com, benve@cisco.com, kaber@trash.net, sri@us.ibm.com,
	davem@davemloft.net, eric.dumazet@gmail.com, mchan@broadcom.com,
	kvm@vger.kernel.org
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA8ECDA7.33BFA%roprabhu@cisco.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 08, 2011 at 07:53:11PM -0700, Roopa Prabhu wrote:
> >> Phase 1: Goal: Enable hardware filtering for all macvlan modes
> >>     - In macvlan passthru mode the single guest virtio-nic connected will
> >>       receive traffic that he requested for
> >>     - In macvlan non-passthru mode all guest virtio-nics sharing the
> >>       physical nic will see all other guest traffic
> >>       but the filtering at guest virtio-nic
> > 
> > I don't think guests currently filter anything.
> > 
> I was referring to Qemu-kvm virtio-net in
> virtion_net_receive->receive_filter. I think It only passes pkts that the
> guest OS is interested. It uses the filter table that I am passing to
> macvtap in this patch.

This happens after userspace thread gets woken up and data
is copied there. So relying on filtering at that level is
going to be very inefficient on a system with
multiple active guests. Further, and for that reason, vhost-net
doesn't do filtering at all, relying on the backends
to pass it correct packets.

-- 
MST
