From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: Re: [PATCH] MIPS: NI 169445 board support
Date: Wed, 4 Jan 2017 10:38:36 -0600
Message-ID: <20170104163836.GA18069@nathan3500-linux-VM>
References: <1480693329-22265-1-git-send-email-nathan.sullivan@ni.com>
 <20161220163434.GA15962@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Ralf Baechle <ralf@linux-mips.org>, <linux-mips@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161220163434.GA15962@linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2016 at 05:34:34PM +0100, Ralf Baechle wrote:
> On Fri, Dec 02, 2016 at 09:42:09AM -0600, Nathan Sullivan wrote:
> > Date:   Fri, 2 Dec 2016 09:42:09 -0600
> > From: Nathan Sullivan <nathan.sullivan@ni.com>
> > To: ralf@linux-mips.org, mark.rutland@arm.com, robh+dt@kernel.org
> > CC: linux-mips@linux-mips.org, devicetree@vger.kernel.org,
> >  linux-kernel@vger.kernel.org, Nathan Sullivan <nathan.sullivan@ni.com>
> > Subject: [PATCH] MIPS: NI 169445 board support
> > Content-Type: text/plain
> > 
> > Support the National Instruments 169445 board.
> 
> Nathan,
> 
> I assume you're going to repost the changes Rob asked for in
> https://patchwork.linux-mips.org/patch/14641/#26924 and resubmit?
> 
> Thanks,
> 
>   Ralf

Hmm, I found the issue with the generic MIPS config and dwc_eth_qos.  The NIC
driver attempts to cache align a descriptor ring using the ___cacheline_aligned
attribute on the descriptor struct, in combination with a "skip" feature in
hardware.  However, the skip feature only has a three bit field, and the generic
MIPS config selects MIPS_L1_CACHE_SHIFT_7.  So, the line size is 128, and with a
64-bit bus, that means the NIC descriptor skip field would need to be set to
14 to align the 16-byte descriptors...

I guess it makes sense for a generic MIPS kernel to align everything for 128 byte
cache lines, and for me to fix the dwc_eth_qos driver to handle cases where the
line size is too big for the hardware skip feature, right?

Thanks,

   Nathan
