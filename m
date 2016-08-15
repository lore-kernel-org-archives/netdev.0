From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCHv2 3/4] pci: Determine actual VPD size on first access
Date: Tue, 16 Aug 2016 08:33:20 +1000
Message-ID: <1471300400.12231.130.camel@kernel.crashing.org>
References: <1452684335-46107-1-git-send-email-hare@suse.de>
	 <1452684335-46107-4-git-send-email-hare@suse.de>
	 <20160209210458.GB32530@localhost>
	 <bc3c39b1-cbff-99a5-8fe7-9add14f2c6f5@ozlabs.ru>
	 <CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
	 <1470787409.3015.81.camel@kernel.crashing.org>
	 <CAKgT0UcfznUD2LM08focv7Y+vqLFMhqNiK5o1TUSsJFFYSt2Gg@mail.gmail.com>
	 <1470873296.3015.117.camel@kernel.crashing.org>
	 <CAKgT0UcPh2RZazDL-cJbJkZFUJ03kTocn5H7WA=Kk_+S-CV_HA@mail.gmail.com>
	 <20160811141700.4f4faabb@t450s.home>
	 <1470978669.3015.155.camel@kernel.crashing.org>
	 <197F6532-FC5E-4D72-976D-4207BAD8D83E@intel.com>
	 <1471299799.12231.121.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Alex Williamson <alex.williamson@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexey Kardashevskiy <aik@ozlabs.ru>,
	Bjorn Helgaas <helgaas@kernel.org>,
	Hannes Reinecke <hare@suse.de>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Babu Moger <babu.moger@oracle.com>,
	Paul Mackerras <paulus@samba.org>,
	"santosh@chelsio.com" <santosh@chelsio.com>,
	Netdev <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471299799.12231.121.camel@kernel.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-08-16 at 08:23 +1000, Benjamin Herrenschmidt wrote:
> > I don't think desktop users appreciate hangs any more than anyone else, and  
> > that is one of the symptoms that can arise here without the vfio  
> > coordination.
> 
> And can happen with it as well.... 

Oh and your response was completely besides the point I was trying
to make, just some passive aggressive noise, thank you.

The point was that if you want the sort of safety that we are trying
to aim for, without additional HW support, you basically have to do
the isolation on a granularity no smaller than a bridge/bus (with the
notable exception of SR-IOV of course).

Otherwise guest *will* be able to harm each other (or the host) in
all sorts of ways if anything because devices will have MMIO backdoors
into their own BAR space, or can be made to DMA to a neighbour, etc...

This is the only safe thing to do (and we are enforcing that on POWER
with our IOMMU groups).

Now that being said, if you want to keep the ability to assign 2 functions
of a device to different guests for your average non-critical desktop user,
that's where you may want to consider two models.

Generally speaking, filtering things for "safety" won't work.

Filtering things to work around bugs in existing guests to avoid crashes
is a different kettle of fish and could be justified but keep in mind that
in most cases a malicious guest will be able to exploit those HW flaws.

Assuming that a device coming back from a guest is functional and not
completely broken and can be re-used without a full PERST or power cycle
is a wrong assumption. It may or may not work, no amount of "filtering"
will fix the fundamental issue. If your HW won't give you access to PERST
well ... blame Intel for not specifying a standard way to generate it in
the first place :-)

Cheers,
Ben.
