From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [net-next PATCH v3 2/3] e1000: add initial
 XDP support
Date: Wed, 14 Sep 2016 23:42:48 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81F90248@ORSMSX101.amr.corp.intel.com>
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
 <20160913215208.GA40872@ast-mbp.thefacebook.com>
 <151DF165-61A2-428A-BD24-04E7704F9724@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        William Tu <u9012063@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:40716 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755686AbcINXmu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 19:42:50 -0400
In-Reply-To: <151DF165-61A2-428A-BD24-04E7704F9724@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Rustad, Mark D
> Sent: Tuesday, September 13, 2016 3:41 PM
> To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>; Tom Herbert
> <tom@herbertland.com>; Brenden Blanco <bblanco@plumgrid.com>; Linux
> Kernel Network Developers <netdev@vger.kernel.org>; intel-wired-lan <intel-
> wired-lan@lists.osuosl.org>; William Tu <u9012063@gmail.com>; Jesper
> Dangaard Brouer <brouer@redhat.com>; Cong Wang
> <xiyou.wangcong@gmail.com>; David S. Miller <davem@davemloft.net>
> Subject: Re: [Intel-wired-lan] [net-next PATCH v3 2/3] e1000: add initial XDP
> support
> 
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
> > On Tue, Sep 13, 2016 at 07:14:27PM +0000, Rustad, Mark D wrote:
> >> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> >>
> >>> On Tue, Sep 13, 2016 at 06:28:03PM +0000, Rustad, Mark D wrote:
> >>>> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> >>>>
> >>>>> I've looked through qemu and it appears only emulate e1k and tg3.
> >>>>> The latter is still used in the field, so the risk of touching
> >>>>> it is higher.
> >>>>
> >>>> I have no idea what makes you think that e1k is *not* "used in the
> >>>> field".

I personally use a number of physical e1000 parts in my lab.  Primarily for an out of band control adapter, as it almost never changes so tends to be very stable, and it is rare that I have to test it so I'm not fighting with a control adapter that I am also testing the driver on.

> >>>> I grant you it probably is used more virtualized than not these days,
> >>>> but it
> >>>> certainly exists and is used. You can still buy them new at Newegg for
> >>>> goodness sakes!
> >>>
> >>> the point that it's only used virtualized, since PCI (not PCIE) have
> >>> been long dead.

Maybe for new server installations.  But modern motherboards often still have PCI, university / lab environments are slow to upgrade specialty test equipment that uses PCI and home users often don't want to get rid of their expensive high quality sound card, video capture card (or whatever.)  Plain old PCI is still in use.

> >>
> >> My point is precisely the opposite. It is a real device, it exists in real
> >> systems and it is used in those systems. I worked on embedded systems
> that
> >> ran Linux and used e1000 devices. I am sure they are still out there
> >> because
> >> customers are still paying for support of those systems.
> >>
> >> Yes, PCI(-X) is absent from any current hardware and has been for some
> >> years
> >> now, but there is an installed base that continues. What part of that
> >> installed base updates software? I don't know, but I would not just
> assume
> >> that it is 0. I know that I updated the kernel on those embedded systems
> >> that I worked on when I was supporting them. Never at the bleeding edge,
> >> but
> >> generally hopping from one LTS kernel to another as needed.
> >
> > I suspect modern linux won't boot on such old pci only systems for other
> > reasons not related to networking, since no one really cares to test
> > kernels there.
> 
> Actually it does boot, because although the motherboard was PCIe, the slots
> and the adapters in them were PCI-X. So the core architecture was not so
> stale.
> 
> > So I think we mostly agree. There is chance that this xdp e1k code will
> > find a way to that old system. What are the chances those users will
> > be using xdp there? I think pretty close to zero.
> 
> For sure they wouldn't be using XDP, but they could suffer regressions in a
> changed driver that might find its way there. That is the risk.
> 
> > The pci-e nics integrated into motherboards that pretend to be tg3
> > (though they're not at all build by broadcom) are significantly more
> > common.
> > That's why I picked e1k instead of tg3.
> 
> That may be true (I really don't know anything about tg3 so I certainly
> can't dispute it), so the risk could be smaller with e1k, but there is
> still a regression risk for real existing hardware. That is my concern.

And one of the patches in supporting this seems to have done just that.  I'll reply to the patch itself with details.
> 
> > Also note how this patch is not touching anything in the main e1k path
> > (because I don't have a hw to test and I suspect Intel's driver team
> > doesn't have it either)

Your suspicion is incorrect.  My lab has multiple boxes out on benches and at least one cabinet 3/4 full of ancient hardware, including a decent variety of e1000 cards (and even a number of e100 ones.)  I also keep a handful of test systems in my regression rack devoted to e1000, though those have dwindled (old hardware eventually dies) and is currently in need of a bit of work, which this patch set has encouraged me to get on to.

> >  to make sure there is no breakage on those
> > old systems. I created separate e1000_xmit_raw_frame() routine
> > instead of adding flags into e1000_xmit_frame() for the same reasons:
> > to make sure there is no breakage.
> > Same reasoning for not doing an union of page/skb as Alexander
> suggested.
> > I wanted minimal change to e1k that allows development xdp programs in
> kvm
> > without affecting e1k main path. If you see the actual bug in the patch,
> > please point out the line.
> 
> I can't say that I can, because I am not familiar with the internals of
> e1k. When I was using it, I never had cause to even look at the driver
> because it just worked. My attentions then were properly elsewhere.
> 
> My concern is with messing with a driver that probably no one has an active
> testbed routinely running regression tests.
> 
> Maybe a new ID should be assigned and the driver forked for this purpose.
> At least then only the virtualization case would have to be tested. Of
> course the hosts would have to offer that ID, but if this is just for
> testing that should be ok, or at least possible.
> 
> If someone with more internal knowledge of this driver has enough
> confidence to bless such patches, that might be fine, but it is a fallacy
> to think that e1k is *only* a virtualization driver today. Not yet anyway.
> Maybe around 2020.
> 
> That said, I can see that you have tried to keep the original code path
> pretty much intact. I would note that you introduced rcu calls into the
> !bpf path that would never have been done before. While that should be ok,
> I would really like to see it tested, at least for the !bpf case, on real
> hardware to be sure. I really can't comment on the workaround issue
> brought
> up by Eric, because I just don't know about them. At least that risk seems
> to only be in the bpf case.
> 
> --
> Mark Rustad, Networking Division, Intel Corporation
