From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 8 Sep 2010 22:17:49 +0530
Message-ID: <OF70542242.6CAA236A-ON65257798.0044A4E0-65257798.005C0E7C@in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <20100908081011.GC23051@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100908081011.GC23051@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 09/08/2010 01:40:11 PM:

>
_______________________________________________________________________________

> >                        UDP (#numtxqs=8)
> > N#      BW1     BW2   (%)      SD1     SD2   (%)
> > __________________________________________________________
> > 4       29836   56761 (90.24)   67      63    (-5.97)
> > 8       27666   63767 (130.48)  326     265   (-18.71)
> > 16      25452   60665 (138.35)  1396    1269  (-9.09)
> > 32      26172   63491 (142.59)  5617    4202  (-25.19)
> > 48      26146   64629 (147.18)  12813   9316  (-27.29)
> > 64      25575   65448 (155.90)  23063   16346 (-29.12)
> > 128     26454   63772 (141.06)  91054   85051 (-6.59)
> > __________________________________________________________
> > N#: Number of netperf sessions, 90 sec runs
> > BW1,SD1,RSD1: Bandwidth (sum across 2 runs in mbps), SD and Remote
> >               SD for original code
> > BW2,SD2,RSD2: Bandwidth (sum across 2 runs in mbps), SD and Remote
> >               SD for new code. e.g. BW2=40716 means average BW2 was
> >               20358 mbps.
> >
>
> What happens with a single netperf?
> host -> guest performance with TCP and small packet speed
> are also worth measuring.

Guest -> Host (single netperf):
I am getting a drop of almost 20%. I am trying to figure out
why.

Host -> guest (single netperf):
I am getting an improvement of almost 15%. Again - unexpected.

Guest -> Host TCP_RR: I get an average 7.4% increase in #packets
for runs upto 128 sessions. With fewer netperf (under 8), there
was a drop of 3-7% in #packets, but beyond that, the #packets
improved significantly to give an average improvement of 7.4%.

So it seems that fewer sessions is having negative effect for
some reason on the tx side. The code path in virtio-net has not
changed much, so the drop in some cases is quite unexpected.

Thanks,

- KK

