From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH v3 2/3] e1000: add initial XDP
 support
Date: Tue, 13 Sep 2016 14:52:10 -0700
Message-ID: <20160913215208.GA40872@ast-mbp.thefacebook.com>
References: <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S35CE+ZYbGm96Y5YKnTqU0zfhg9_h0VSpD3ot8xB-scdFQ@mail.gmail.com>
 <20160913012815.GB25756@ast-mbp.thefacebook.com>
 <CALx6S36u+tQUEVhu0BaLZ6-_0=GSMwxd4m89-H+brVZ-rr-U2g@mail.gmail.com>
 <20160913171340.GA37341@ast-mbp.thefacebook.com>
 <1473788252.18970.177.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160913175926.GA38737@ast-mbp.thefacebook.com>
 <36ECC79A-0810-4D06-A72D-702AD9901E83@intel.com>
 <20160913182959.GA38950@ast-mbp.thefacebook.com>
 <AB6E7248-F1A3-4C9C-9249-7F25E51BA1E4@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        William Tu <u9012063@gmail.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33627 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754885AbcIMVwR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 17:52:17 -0400
Received: by mail-pf0-f172.google.com with SMTP id g202so67655922pfb.0
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 14:52:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AB6E7248-F1A3-4C9C-9249-7F25E51BA1E4@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 13, 2016 at 07:14:27PM +0000, Rustad, Mark D wrote:
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
> >On Tue, Sep 13, 2016 at 06:28:03PM +0000, Rustad, Mark D wrote:
> >>Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> >>
> >>>I've looked through qemu and it appears only emulate e1k and tg3.
> >>>The latter is still used in the field, so the risk of touching
> >>>it is higher.
> >>
> >>I have no idea what makes you think that e1k is *not* "used in the field".
> >>I grant you it probably is used more virtualized than not these days,
> >>but it
> >>certainly exists and is used. You can still buy them new at Newegg for
> >>goodness sakes!
> >
> >the point that it's only used virtualized, since PCI (not PCIE) have
> >been long dead.
> 
> My point is precisely the opposite. It is a real device, it exists in real
> systems and it is used in those systems. I worked on embedded systems that
> ran Linux and used e1000 devices. I am sure they are still out there because
> customers are still paying for support of those systems.
> 
> Yes, PCI(-X) is absent from any current hardware and has been for some years
> now, but there is an installed base that continues. What part of that
> installed base updates software? I don't know, but I would not just assume
> that it is 0. I know that I updated the kernel on those embedded systems
> that I worked on when I was supporting them. Never at the bleeding edge, but
> generally hopping from one LTS kernel to another as needed.

I suspect modern linux won't boot on such old pci only systems for other
reasons not related to networking, since no one really cares to test kernels there.
So I think we mostly agree. There is chance that this xdp e1k code will
find a way to that old system. What are the chances those users will
be using xdp there? I think pretty close to zero.

The pci-e nics integrated into motherboards that pretend to be tg3
(though they're not at all build by broadcom) are significantly more common.
That's why I picked e1k instead of tg3.

Also note how this patch is not touching anything in the main e1k path
(because I don't have a hw to test and I suspect Intel's driver team
doesn't have it either) to make sure there is no breakage on those
old systems. I created separate e1000_xmit_raw_frame() routine
instead of adding flags into e1000_xmit_frame() for the same reasons:
to make sure there is no breakage.
Same reasoning for not doing an union of page/skb as Alexander suggested.
I wanted minimal change to e1k that allows development xdp programs in kvm
without affecting e1k main path. If you see the actual bug in the patch,
please point out the line.
