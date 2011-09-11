From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Sun, 11 Sep 2011 12:44:49 +0300
Message-ID: <20110911094449.GF27096@redhat.com>
References: <20110908193332.GA2476@redhat.com>
 <CA8ECF75.33BFF%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	dragos.tatulea@gmail.com, arnd@arndb.de, dwang2@cisco.com,
	benve@cisco.com, kaber@trash.net, davem@davemloft.net,
	eric.dumazet@gmail.com, mchan@broadcom.com, kvm@vger.kernel.org
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13226 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753656Ab1IKJnz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Sep 2011 05:43:55 -0400
Content-Disposition: inline
In-Reply-To: <CA8ECF75.33BFF%roprabhu@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2011 at 08:00:53PM -0700, Roopa Prabhu wrote:
> 
> 
> 
> On 9/8/11 12:33 PM, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > On Thu, Sep 08, 2011 at 12:23:56PM -0700, Roopa Prabhu wrote:
> >>> 
> >>> I think the main usecase for passthru mode is to assign a SR-IOV VF to
> >>> a single guest.
> >>> 
> >> Yes and for the passthru usecase this patch should be enough to enable
> >> filtering in hw (eventually like I indicated before I need to fix vlan
> >> filtering too).
> > 
> > So with filtering in hw, and in sriov VF case, VFs
> > actually share a filtering table. How will that
> > be partitioned?
> 
> AFAIK, though it might maintain a single filter table space in hw, hw does
> know which filter belongs to which VF. And the OS driver does not need to do
> anything special. The VF driver exposes a VF netdev. And any uc/mc addresses
> registered with a VF netdev are registered with the hw by the driver. And hw
> will filter and send only pkts that the VF has expressed interest in.
> 
> No special filter partitioning in hw is required.
> 
> Thanks,
> Roopa

Yes, but what I mean is, if the size of the single filter table
is limited, we need to decide how many addresses is
each guest allowed. If we let one guest ask for
as many as it wants, it can lock others out.

-- 
MST
