From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH 1/2] macb: Add 1588 support in Cadence GEM.
Date: Thu, 8 Sep 2016 21:06:25 +0200
Message-ID: <20160908190624.GA5237@netboy>
References: <1472820817-21874-1-git-send-email-andrei.pistirica@microchip.com>
 <20160906154809.GA7012@localhost.localdomain>
 <CAFcVECJxJgJUeO4=yudwTj5NkxDob5tCZaom9YTqWWmtt7ajFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrei Pistirica <andrei.pistirica@microchip.com>,
        netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>, davem@davemloft.net,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Harini Katakam <harini.katakam@xilinx.com>,
        Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        Anirudha Sarangi <anirudh@xilinx.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        alexandre.belloni@free-electrons.com, tbultel@pixelsurmer.com
To: Harini Katakam <harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAFcVECJxJgJUeO4=yudwTj5NkxDob5tCZaom9YTqWWmtt7ajFw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 08, 2016 at 10:22:43AM +0530, Harini Katakam wrote:
> >> +     /* get GEM internal time */
> >> +     sech = gem_readl(bp, TSH);
> >> +     secl = gem_readl(bp, TSL);
> >
> > Does reading TSH latch the time?  The TRM is silent about that, and
> > most other designs latch on reading the LSB.
> 
> No, it does not latch the time.
> When doing a read + adjust + write, this will
> mean there's room for some error.

It also means that you will have to handle when the TSL value
overflows into TSH.  That means reading TSH twice, once before and
once after reading TSL and retrying if needed.

The code as written above will produce apparent jumps backwards in
time, whenever the overflow occurs between the two read operations.

Thanks,
Richard
