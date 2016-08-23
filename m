From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next 0/3] net/sched: iptunnel encap/decap/classify
 using TC
Date: Tue, 23 Aug 2016 12:05:57 +0300
Message-ID: <20160823090557.GA10223@office.localdomain>
References: <20160822143834.32422-1-amir@vadai.me>
 <CALx6S37=Y0-cNhKLhWfkZ2hCa0EMyo-phed5S3RmsPYGaVz+yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35597 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753622AbcHWKP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 06:15:58 -0400
Received: by mail-wm0-f65.google.com with SMTP id i5so17415199wmg.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 03:15:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S37=Y0-cNhKLhWfkZ2hCa0EMyo-phed5S3RmsPYGaVz+yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 03:23:45PM -0700, Tom Herbert wrote:
> On Mon, Aug 22, 2016 at 7:38 AM, Amir Vadai <amir@vadai.me> wrote:
> > Hi,
> >
> > This patchset introduces iptunnel support using the TC subsystem.
> >
> > In the decap flow, it enables the user to redirect packets from a shared tunnel
> > device and classify by outer and inner headers. The outer headers are extracted
> > from the metadata and used by the flower filter. A new action act_iptunnel,
> > releases the metadata.
> >
> > In the encap flow, act_iptunnel creates a metadata object to be used by the
> > shared tunnel device. The actual redirection to the tunnel device is done using
> > act_mirred.
> >
> > For example:
> > $ tc qdisc add dev vnet0 ingress
> > $ tc filter add dev vnet0 protocol ip parent ffff: \
> >     flower \
> >           ip_proto 1 \
> >         action iptunnel encap \
> >           src_ip 11.11.0.1 \
> >                 dst_ip 11.11.0.2 \
> >                 id 11 \
> >         action mirred egress redirect dev vxlan0
> >
> Is the device required to be a tunnel device? Consider that with LWT
> we can perform this sort of encapsulation without requiring a special
> device...
> 
> Tom
> 
Yes and no. This action is relevant only for a shared tunnel device.
like the one you get with:
$ ip link add vxlan0 type vxlan dstport 4789 external
A user can add metadata using this action and redirect to any netdev,
but only the shared tunnel netdev will do something with it.

Regarding LWT, in our use case we need to have classification in
addition to the routing, have both encap and decap operations and be
ready to add offloading to the API. For that, TC subsystem looked
the most suiteable.

Thanks,
Amir

[...]
