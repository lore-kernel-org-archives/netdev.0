From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 12 Aug 2012 16:55:44 +0300
Message-ID: <20120812135544.GB6003@redhat.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
 <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
 <87boitz044.fsf@xmission.com>
 <20120805185031.GA18640@redhat.com>
 <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com>
 <20120812102240.GG1421@redhat.com>
 <5027AC88.2020509@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751990Ab2HLN47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2012 09:56:59 -0400
Content-Disposition: inline
In-Reply-To: <5027AC88.2020509@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 12, 2012 at 04:15:52PM +0300, Or Gerlitz wrote:
> On 12/08/2012 13:22, Michael S. Tsirkin wrote:
> >>>>>- IGMP/MAC snooping in a driver is just too hairy.
> >>
> >>>mmm, any rough idea/direction how to do that otherwise?
> >Sure, even two ways, ideally you'd do both:)
> >A. fix macvtap
> >1. Use netdev_for_each_mc_addr etc to get multicast addresses
> >2. teach macvtap to fill that in (it currently floods multicasts
> >    for guest to guest communication so we ned to fix it anyway)
> >
> >B. fix bridge
> >    teach bridge to work for VMs without using promisc mode
> 
> I wasn't sure to fully follow... need some more bits of info, the
> macvtap fix
> relates only to IGMP snooping, correct? as for the bridge fix, does
> this somehow
> relates to ARP snooping we do in the driver? how?
> 
> Or.

I didn't realize you do ARP snooping. Why?

I know you mangle outgoing ARP packets, this will go
away if you maintain a mapping in SM accessible to all guests.

-- 
MST
