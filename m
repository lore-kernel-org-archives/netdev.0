From: Beniamino Galvani <b.galvani@gmail.com>
Subject: Re: [PATCH net-next] net: stmmac: add BQL support
Date: Wed, 31 Dec 2014 00:13:31 +0100
Message-ID: <20141230231331.GA22637@gmail.com>
References: <1419778631-23067-1-git-send-email-b.galvani@gmail.com>
 <CAA93jw7XMK0foH_Hf9PHitV+Xhwxu15xATFv-jnn8_1Tv+kFCA@mail.gmail.com>
 <20141228214059.GA25570@gmail.com>
 <CAA93jw4GeWOqeZu5SjOYhhORiH6XCrv7uPTjrgE9O1QWESCxqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:60092 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaL3XNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 18:13:47 -0500
Content-Disposition: inline
In-Reply-To: <CAA93jw4GeWOqeZu5SjOYhhORiH6XCrv7uPTjrgE9O1QWESCxqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2014 at 09:42:01AM -0800, Dave Taht wrote:
> On Sun, Dec 28, 2014 at 1:48 PM, Beniamino Galvani <b.galvani@gmail.com> wrote:
> > On Sun, Dec 28, 2014 at 08:25:40AM -0800, Dave Taht wrote:
> >> On Sun, Dec 28, 2014 at 6:57 AM, Beniamino Galvani <b.galvani@gmail.com> wrote:
> >> > Add support for Byte Queue Limits to the STMicro MAC driver.
> >>
> >> Thank you!
> >>
> >> > Tested on a Amlogic S805 Cortex-A5 board, where the use of BQL
> >> > slightly decreases the ping latency from ~10ms to ~3ms when the
> >> > 100Mbps link is saturated by TCP streams. No difference is
> >> > observed at 1Gbps.
> >>
> >> I see the plural. With TSQ in place it is hard (without something like
> >> the rrul test driving multiple streams) to drive a driver to
> >> saturation with small numbers of flows. This was with pfifo_fast, not
> >> sch_fq, at 100mbit?
> >
> > Hi Dave,
> >
> > yes, this was with pfifo_fast and I used 4 iperf TCP streams. The total
> > throughput didn't seem to increase adding more streams.
> 
> >>
> >> Can this board actually drive a full gigabit in the first place? Until
> >> now most of the low end arm boards I have seen only came with
> >> a 100mbit mac, and the gig ones lacking offloads seemed to peak
> >> out at about 600mbit.
> >
> > I measured a throughput of 650mbit in rx and 600mbit in tx.
> 
> You might want to try the rrul test which tests both directions and
> latency at the same time.

I will try it, thanks.

> 
> In my case I have been trying to find a low-cost chip that could do soft
> rate limiting (htb) + fq_codel at up to 300mbit/sec, as that is about
> the peak speed
> we will be getting from cable modems, and these are horribly overbuffered,
> at these speeds too, with 1.2sec of bidirectional latency observed at
> 120mbit/12mbit.
> 
> I'm open to crazy ideas like trying to find a use for the gpu, etc, to
> get there.
> 
> >
> >>
> >> Under my christmas tree landed a quad core A5 (odroid-c1), also an
> >> xgene and zedboard - both of the latter are a-needing BQL,
> >> and I haven't booted the udroid yet. Hopefully it is the
> >> same driver you just improved.
> >
> > I'm using the odroid-c1 too, with this tree based on the recent
> > Amlogic mainline work:
> >
> >   https://github.com/bengal/linux/tree/meson8b
> 
> Oh, cool, thx!
> 
> > Unfortunately at the moment the support for the board is very basic
> > (for example, SMP is not working yet) but it's enough to do some NIC
> > tests.
> 
> Good to know. Have you looked at xmit_more yet?
> 
> http://lwn.net/Articles/615238/

I don't know if I have implemented it correctly, but I found that the
improvement with xmit_more is so small to be barely observable, maybe
because the cost for starting the hardware transmission is very low
(it's a single mmio write).

Beniamino
