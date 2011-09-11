From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Sun, 11 Sep 2011 22:03:25 +0300
Message-ID: <20110911190325.GC4740@redhat.com>
References: <20110911094449.GF27096@redhat.com>
 <CA920319.33DE1%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	dragos.tatulea@gmail.com, arnd@arndb.de, dwang2@cisco.com,
	benve@cisco.com, kaber@trash.net, davem@davemloft.net,
	eric.dumazet@gmail.com, mchan@broadcom.com, kvm@vger.kernel.org
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760310Ab1IKTCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Sep 2011 15:02:38 -0400
Content-Disposition: inline
In-Reply-To: <CA920319.33DE1%roprabhu@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 11, 2011 at 06:18:01AM -0700, Roopa Prabhu wrote:
> 
> 
> 
> On 9/11/11 2:44 AM, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> >> 
> >> AFAIK, though it might maintain a single filter table space in hw, hw does
> >> know which filter belongs to which VF. And the OS driver does not need to do
> >> anything special. The VF driver exposes a VF netdev. And any uc/mc addresses
> >> registered with a VF netdev are registered with the hw by the driver. And hw
> >> will filter and send only pkts that the VF has expressed interest in.
> >> 
> >> No special filter partitioning in hw is required.
> >> 
> >> Thanks,
> >> Roopa
> > 
> > Yes, but what I mean is, if the size of the single filter table
> > is limited, we need to decide how many addresses is
> > each guest allowed. If we let one guest ask for
> > as many as it wants, it can lock others out.
> 
> Yes true. In these cases ie when the number of unicast addresses being
> registered is more than it can handle, The VF driver will put the VF  in
> promiscuous mode (Or at least its supposed to do. I think all drivers do
> that).
> 
> 
> Thanks,
> Roopa

Right, so that works at least but likely performs worse
than a hardware filter. So we better allocate it in
some fair way, as a minimum. Maybe a way for
the admin to control that allocation is useful.

-- 
MST
