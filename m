From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Wed, 8 Feb 2017 11:26:23 +0100
Message-ID: <20170208102623.GC11233@localhost>
References: <20170207140144.GA11233@localhost>
 <CAHoNx59VwLbACPp_3a5doyi=Y1hUqU5oVvJqxpsv777W2g+Z8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: sdncurious <sdncurious@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39986 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752511AbdBHKiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 05:38:25 -0500
Content-Disposition: inline
In-Reply-To: <CAHoNx59VwLbACPp_3a5doyi=Y1hUqU5oVvJqxpsv777W2g+Z8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 12:37:15PM -0800, sdncurious wrote:
> On Tue, Feb 7, 2017 at 6:01 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > 6) new SO_TIMESTAMPING option to get PHC index with HW timestamps
> >
> >    With bridges, bonding and other things it's difficult to determine
> >    which PHC timestamped the packet. It would be very useful if the
> >    PHC index was provided with each HW timestamp.
> >
> >    I'm not sure what would be the best place to put it. I guess the
> >    second timespec in scm_timestamping could be reused for this, but
> >    that sounds like a gross hack. Do we need to define a new struct?
> 
> What is the use case for this. even if the delay though the PHY's how
> would that be compensated ?

The idea was that applications like NTP servers and clients wouldn't
have to care about interfaces and how they map together with addresses
to PHCs over time. Currently, I use the interface index from
IP_PKTINFO to get the PHC, but that doesn't work with bridges and
other virtual interfaces. Another possibility would be an option to
modify the behavior of IP_PKTINFO to save the index of the real
interface. I'm not sure how would that compare in difficulty to
extending SCM_TIMESTAMPING with PHC index.

-- 
Miroslav Lichvar
