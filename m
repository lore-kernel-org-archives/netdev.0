From: Knut Omang <knut.omang@oracle.com>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Mon, 08 May 2017 15:04:02 +0200
Message-ID: <1494248642.10569.23.camel@oracle.com>
References: <20170504180216.7665-1-leon@kernel.org>
         <20170505085457.0029edc9@griffin> <20170505131754.GH22833@mtr-leonro.local>
         <20170506104826.GD2017@nanopsycho>
         <20170507063329.GL22833@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Jiri Benc <jbenc@redhat.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Ram Amrani <ram.amrani@cavium.com>,
        Bart Van Assche <Bart.VanAssche@sandisk.com>,
        Sagi Grimberg <sagi@grimberg.me>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Christoph Hellwig <hch@lst.de>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38843 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753964AbdEHNFC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 09:05:02 -0400
In-Reply-To: <20170507063329.GL22833@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-05-07 at 09:33 +0300, Leon Romanovsky wrote:
> On Sat, May 06, 2017 at 12:48:26PM +0200, Jiri Pirko wrote:
> > Fri, May 05, 2017 at 03:17:54PM CEST, leon@kernel.org wrote:
> > >On Fri, May 05, 2017 at 08:54:57AM +0200, Jiri Benc wrote:
> > >> On Thu,  4 May 2017 21:02:08 +0300, Leon Romanovsky wrote:
> > >> > In order to close object model, ensure reuse of existing code and make this
> > >> > tool usable from day one, we decided to implement wrappers over legacy sysfs
> > >> > prior to implementing netlink functionality. As a nice bonus, it will allow
> > >> > to use this tool with old kernels too.
> > >>
> > >> This sounds wrong. We don't support legacy ioctl interface for the 'ip'
> > >> command, either. I think rdma should be converted to netlink first and
> > >> the new tool should only use netlink.
> > >
> > >RDMA in slightly different situation than "ip" tool was. "ip" was implemented
> > >when tools like ifconfig existed. It allowed to old and new systems to be
> > >configured to some degree. In RDMA community, there are no similar tools like
> > >"ifconfig". Implementation in netlink-only interface will leave old systems without
> > >common tool at all.
> > >
> > >As an upstream-oriented person, I personally fine with that, but anyway would
> > >like to get wider agreement/disagreement on that, before removing sysfs
> > >parsing logic from the rdmatool.
> >
> > I tend to agree with Jiri Benc. I fear that supporting sysfs + netlink
> > api later on for the same things will make the code unnecessary complex.
> > Also, the legacy sysfs will most likely stay there forever so there will
> > be no actual motivation to port the existing things to the new netlink
> > api.
> >
> > For the prototyping purposes, I belive that what you did makes perfect
> > sense. But for the actual mergable version, my feeling is that we need
> > to strictly stick with new netlink rdma interface and just forget about
> > the old sysfs one. Distros would have to backport the new kernel
> > rdma netlink api.
> 
> Thanks,
> It looks like that most of the comments are in favor of netlink-only
> solution.

Leon, I like the thought bw comp support. After all this is a user level tool so it should
be possible to make a clean implementation that makes the old stuff easy to remove 
at some point. It will also attract users much sooner than if they have to have 
their own if-then-else logic around everything to be able to support old and new.

> > Yes, this will be little bit more painful at the beginning, but in the
> > long run, I believe it will save some severe headaches.
> >

IMHO, some headache will be there anyway, just a matter of how how far out it gets.

Knut
