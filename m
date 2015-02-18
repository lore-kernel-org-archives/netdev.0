From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2 1/3] Ethernet packet sniffer: Device tree binding and
 vendor prefix
Date: Wed, 18 Feb 2015 12:11:50 +0000
Message-ID: <20150218121150.GA29429@leverpostej>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk>
 <0a86907642a97e5bd880f69299664232fcffaf9d.1424181053.git.stathis.voukelatos@linn.co.uk>
 <20150217145124.GM8994@leverpostej>
 <54E36AAC.7010308@linn.co.uk>
 <20150217163527.GR8994@leverpostej>
 <54E376AF.80602@linn.co.uk>
 <20150217173000.GT8994@leverpostej>
 <54E45E06.2020609@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"abrestic@chromium.org" <abrestic@chromium.org>
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54E45E06.2020609@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 18, 2015 at 09:40:22AM +0000, Stathis Voukelatos wrote:
> 
> 
> On 17/02/15 17:30, Mark Rutland wrote:
> 
> >> It is the frequency of the timestamp values supplied to the sniffer
> >> module. It is used by the driver to convert to nanoseconds.
> >> I was trying to be somewhat generic here and not assume that it
> >> is necessarily the same as the 'tstamp' clock below, in which case we
> >> could indeed obtain it using the common clock framework.
> >
> > In what cases would it _not_ be the same? From your description this is
> > that clock, no?
> >
> 
> Counters can often have a divider applied to their input clock and
> therefore run at a scaled down frequency. This is not the case in the
> first SoC where the sniffer is used, so for simplicity I can modify as
> you suggest and remove that field from the DT.

The common clock bindings have fixed-factor-clock for handling dividers,
so I believe you should be able to use that.

You mentioned that the counter was a block external to the sniffer. Does
it have any configuration interface (e.g. to reset the counter)? We may
need to model it in the DT if so (and describe the clock as feeding into
it rather than into the sniffer).

> >> Yes, but the sniffer module is hard-wired to a certain Ethernet Mii
> >> interface. We can add an entry to tie it to an Ethernet controller, but
> >> apart of a sanity check I am not sure what else the S/W can do.
> >
> > Fundamentally, the use-case for this is monitoring an ethernet
> > interface. So regardless of which kernel framework this plumbs into,
> > there needs to be a way to go from ethN to whatever this is exposed as.
> >
> > Exposing a completely separate interface makes no sense. Singleton stuff
> > like that inevitably gets broken as someone later builds a board with
> > multiple instances of some similar IP block.
> >
> > So I would imagine that either the link between interface and monitoring
> > interface would be described somewhere in the filesystem, or there'd be
> > a syscall/ioctl/whatever to go from an interface to the appropriate
> > monitoring interface.
> >
> > That all depends on exactly how this gets exposed in the end, however.
> >
> 
> After the first version of the patch was submitted, the feedback from 
> the netdev list was to expose it as a network interface as this would
> allow it to be accessed by standard user space monitoring tools.
> It definitely makes sense to link it to the associated ethernet netdev,
> but I am not sure if there is a framework in the kernel to do it at
> the driver level?

Unfortunately I'm not familiar enough with the net code; hopefully
someone else can point us in the right direction.

Thanks,
Mark.
