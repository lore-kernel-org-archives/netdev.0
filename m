From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH v2 2/2] e1000: bundle xdp xmit routines
Date: Fri, 9 Sep 2016 20:56:39 -0700
Message-ID: <20160910035637.GA83872@ast-mbp.thefacebook.com>
References: <20160909212915.4001.25504.stgit@john-Precision-Tower-5810>
 <20160909212938.4001.40540.stgit@john-Precision-Tower-5810>
 <CALx6S35VCq9yPjcuhtx6jEJ78-WugkQZ6GSsqkcTr0Fa7edkVg@mail.gmail.com>
 <57D34D67.40804@gmail.com>
 <CALx6S36dH87e6TPxEBGsy0F-vD0fZzKyP8tbuuaAfLNSF1DGpw@mail.gmail.com>
 <57D35E08.8010204@gmail.com>
 <CALx6S36SM-wq6Fj8XK7GfMta1dVGr3RZ5uAgGdnxm7kgpVNFbw@mail.gmail.com>
 <20160910014032.GA83023@ast-mbp.thefacebook.com>
 <CALx6S36Xo4ZJJg5k2RT9rcT_1_zKRG1n_EOruU=JqvXBnq=E3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        William Tu <u9012063@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32924 "EHLO
        mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbcIJD4p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 23:56:45 -0400
Received: by mail-pa0-f44.google.com with SMTP id cm16so34165507pac.0
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 20:56:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S36Xo4ZJJg5k2RT9rcT_1_zKRG1n_EOruU=JqvXBnq=E3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 09, 2016 at 08:12:52PM -0700, Tom Herbert wrote:
> >> That probably means that the stack will always win out under load.
> >> Trying to used the same queue where half of the packets are well
> >> managed by a qdisc and half aren't is going to leave someone unhappy.
> >> Maybe in the this case where we have to share the qdisc we can
> >> allocate the skb on on returning XDP_TX and send through the normal
> >> qdisc for the device.
> >
> > I wouldn't go to such extremes for e1k.
> > The only reason to have xdp in e1k is to use it for testing
> > of xdp programs. Nothing else. e1k is, best case, 1Gbps adapter.
> 
> I imagine someone may want this for the non-forwarding use cases like
> early drop for DOS mitigation.

Sure and they will be doing it on the NICs that they have in their servers.
e1k is not that nic. xdp e1k is for debugging xdp programs in KVM only.
Performance of such xdp programs on e1k is irrelevant.
There is absolutely no need to complicate the driver and the patches.
All other drivers is a different story.
