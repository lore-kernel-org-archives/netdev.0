From: Beniamino Galvani <b.galvani@gmail.com>
Subject: Re: [PATCH net-next] net: stmmac: add BQL support
Date: Sun, 28 Dec 2014 22:48:35 +0100
Message-ID: <20141228214059.GA25570@gmail.com>
References: <1419778631-23067-1-git-send-email-b.galvani@gmail.com>
 <CAA93jw7XMK0foH_Hf9PHitV+Xhwxu15xATFv-jnn8_1Tv+kFCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAA93jw7XMK0foH_Hf9PHitV+Xhwxu15xATFv-jnn8_1Tv+kFCA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 28, 2014 at 08:25:40AM -0800, Dave Taht wrote:
> On Sun, Dec 28, 2014 at 6:57 AM, Beniamino Galvani <b.galvani@gmail.com> wrote:
> > Add support for Byte Queue Limits to the STMicro MAC driver.
> 
> Thank you!
> 
> > Tested on a Amlogic S805 Cortex-A5 board, where the use of BQL
> > slightly decreases the ping latency from ~10ms to ~3ms when the
> > 100Mbps link is saturated by TCP streams. No difference is
> > observed at 1Gbps.
> 
> I see the plural. With TSQ in place it is hard (without something like
> the rrul test driving multiple streams) to drive a driver to
> saturation with small numbers of flows. This was with pfifo_fast, not
> sch_fq, at 100mbit?

Hi Dave,

yes, this was with pfifo_fast and I used 4 iperf TCP streams. The total
throughput didn't seem to increase adding more streams.

> 
> Can this board actually drive a full gigabit in the first place? Until
> now most of the low end arm boards I have seen only came with
> a 100mbit mac, and the gig ones lacking offloads seemed to peak
> out at about 600mbit.

I measured a throughput of 650mbit in rx and 600mbit in tx.

> 
> Under my christmas tree landed a quad core A5 (odroid-c1), also an
> xgene and zedboard - both of the latter are a-needing BQL,
> and I haven't booted the udroid yet. Hopefully it is the
> same driver you just improved.

I'm using the odroid-c1 too, with this tree based on the recent
Amlogic mainline work:

  https://github.com/bengal/linux/tree/meson8b

Unfortunately at the moment the support for the board is very basic
(for example, SMP is not working yet) but it's enough to do some NIC
tests.

Beniamino
