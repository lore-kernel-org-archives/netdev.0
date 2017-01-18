From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Wed, 18 Jan 2017 11:31:27 -0700
Message-ID: <20170118183127.GC14198@obsidianresearch.com>
References: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
 <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com>
 <20170118173327.GF32481@mtr-leonro.local>
 <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Leon Romanovsky <leonro@mellanox.com>,
        Ariel Almog <arielalmogworkemails@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:36431 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751896AbdARSe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 13:34:26 -0500
Content-Disposition: inline
In-Reply-To: <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 07:50:26PM +0200, Or Gerlitz wrote:
> On Wed, Jan 18, 2017 at 7:33 PM, Leon Romanovsky wrote:
> > On Wed, Jan 18, 2017 at 06:48:21PM +0200, Or Gerlitz wrote:
> >> On Wed, Jan 18, 2017 at 5:19 PM, Ariel Almog
> >> <arielalmogworkemails@gmail.com> wrote:
> 
> >>> As of today, there is no single, simple, tool that allows monitoring
> >>> and configuration of RDMA stack.
> 
> >> Before tool, what kernel UAPI you thought to use?
> 
> > I'm aware of the following options:
> > 1) netlink
> > 2) RDMA ABI https://www.spinics.net/lists/linux-rdma/msg43960.html
> > 3) ioctl
> > 4) write/read
> >
> > The items 1 and 2 are preferred options and one of the main goals
> > for this RFC is to chose between them.
> >
> > For example, RDMA ABI has native support of querying and discovering
> > device capabilities via merge tree feature.
> 
> To make it clear, when you wrote ABI in your initial email, I tend to
> think it was sort of unclear to the netdev crowd that you are talking
> on new UAPI which is now under the works for the IB subsystem, so with
> my netdev community member hat, I got confused... anyway

I think it depends on what this tool is supposed to cover, but based
on the description, I would start with netlink-only.

The only place verbs covers a similar ground is in 'device
capabilities' - for some of that you might want to open a new-uAPI
verbs fd, but even the capability data from that would not be
totally offensive to be accessed over netlink.

IMHO netlink should cover almost everything found in sysfs today.

I'm also deeply skeptical about driver-specific stuff at this layer,
that sounds like a way to make a big mess.

Jason
