From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH v3 2/3] e1000: add initial XDP support
Date: Mon, 12 Sep 2016 18:28:16 -0700
Message-ID: <20160913012815.GB25756@ast-mbp.thefacebook.com>
References: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
 <20160912221351.5610.29043.stgit@john-Precision-Tower-5810>
 <1473720399.18970.91.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160912230745.GA24171@ast-mbp.thefacebook.com>
 <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S35CE+ZYbGm96Y5YKnTqU0zfhg9_h0VSpD3ot8xB-scdFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
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
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36815 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750975AbcIMB2U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 21:28:20 -0400
Received: by mail-pa0-f49.google.com with SMTP id id6so56066316pad.3
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 18:28:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35CE+ZYbGm96Y5YKnTqU0zfhg9_h0VSpD3ot8xB-scdFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 05:03:25PM -0700, Tom Herbert wrote:
> On Mon, Sep 12, 2016 at 4:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2016-09-12 at 16:07 -0700, Alexei Starovoitov wrote:
> >
> >> yep. there are various ways to shoot yourself in the foot with xdp.
> >> The simplest program that drops all the packets will make the box unpingable.
> >
> > Well, my comment was about XDP_TX only, not about XDP_DROP or driving a
> > scooter on 101 highway ;)
> >
> > This XDP_TX thing was one of the XDP marketing stuff, but there is
> > absolutely no documentation on it, warning users about possible
> > limitations/outcomes.
> >
> > BTW, I am not sure mlx4 implementation even works, vs BQL :
> >
> > mlx4_en_xmit_frame() does not call netdev_tx_sent_queue(),
> > but tx completion will call netdev_tx_completed_queue() -> crash
> >
> > Do we have one test to validate that a XDP_TX implementation is actually
> > correct ?
> >
> Obviously not for e1000 :-(. We really need some real test and
> performance results and analysis on the interaction between the stack
> data path and XDP data path.

no. we don't need it for e1k and we cannot really do it.
<broken record mode on> this patch is for debugging of xdp programs only.

> The fact that these changes are being
> passed of as something only needed for KCM is irrelevant, e1000 is a
> well deployed a NIC and there's no restriction that I see that would
> prevent any users from enabling this feature on real devices.

e1k is not even manufactured any more. Probably the only place
where it can be found is computer history museum.
e1000e fairs slightly better, but it's a different nic and this
patch is not about it.
