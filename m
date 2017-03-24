From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Fri, 24 Mar 2017 08:25:11 +0100
Message-ID: <20170324072511.GC8192@localhost>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost>
 <20170323162145.GB8192@localhost>
 <20170323190733.GA30056@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56256 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753285AbdCXHZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 03:25:59 -0400
Content-Disposition: inline
In-Reply-To: <20170323190733.GA30056@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 23, 2017 at 08:07:33PM +0100, Richard Cochran wrote:
> On Thu, Mar 23, 2017 at 05:21:45PM +0100, Miroslav Lichvar wrote:
> > A better approach might be a control message that would provide the
> > original interface index together with the length of the packet, so
> > the application could transpose the HW timestamp and map the HW
> > interface to the PHC.
> 
> This sounds better than trying to auto-magically transpose and correct
> for link speed.
> 
> BTW, isn't there already a control message for "original interface
> index"?

There is the PACKET_ORIGDEV option, but it works only with packet
sockets, and it doesn't look to me like it could be easily turned into
a SO_ORIGDEV option. If there was such an option and also a SO_ORIGLEN
option, I think that would work nicely for me.

> > The two values could be saved in the skb_shared_info structure. Now
> > my question is if they could be useful also for other things than
> > timestamping
> 
> such as?

I'm not sure. What people do with PACKET_ORIGDEV and would it make
sense with other sockets? Googling "PACKET_ORIGDEV" shows
implementations of some low-level protocols.

> > and if it should be a new socket option which would work
> > on any socket independently from timestamping, or if it should rather
> > be a new flag for the SO_TIMESTAMPING option. If the latter, would it
> > make sense to put them in the skb_shared_hwtstamps structure and
> > modify all drivers to set the values when a HW timestamp is captured
> > instead of adding more code to __netif_receive_skb_core() or similar?
> 
> This information is solely for a highly specialized NTP application.
> No normal program would ever need this, AFAICT.  So, if possible,
> getting the original frame length should be done in a way that doesn't
> affect users that don't need it.

Ok. I'll put the two fields to skb_shared_hwtstamps, taking the place
of the old syststamp field, and try to avoid adding any code to paths
not specific to timestamping.

Thanks,

-- 
Miroslav Lichvar
