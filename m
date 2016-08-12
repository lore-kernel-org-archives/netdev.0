From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCHv2 3/4] pci: Determine actual VPD size on first access
Date: Fri, 12 Aug 2016 15:11:09 +1000
Message-ID: <1470978669.3015.155.camel@kernel.crashing.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>,
	Bjorn Helgaas <helgaas@kernel.org>,
	Hannes Reinecke <hare@suse.de>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Babu Moger <babu.moger@oracle.com>,
	Paul Mackerras <paulus@samba.org>, santosh@chelsio.com,
	Netdev <netdev@vger.kernel.org>
To: Alex Williamson <alex.williamson@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160811141700.4f4faabb@t450s.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-08-11 at 14:17 -0600, Alex Williamson wrote:
> 
> vfio isn't playing nanny here for the fun of it, part of the reason we
> have vpd access functions is because folks have discovered that vpd
> registers between PCI functions on multi-function devices may be
> shared.  So pounding on vpd registers for function 1 may adversely
> > affect someone else reading from a different function.

A lot more than that may be shared... the bus for example. lots of
devices have backdoors into their own BARs, one partition can make its
BARs overlap the neighbour function, ... dang !

In the end, PCI assignment at a granularity smaller than a bus cannot
be done in a fully air tight way and shouldn't be relied upon in
environemnt where the isolation between partitions matters.

The only exception here is SR-IOV of course since it's designed
specifically so that the VFs can't be messed with.

>   This is a case
> where I feel vfio needs to step in because if that's a user competing
> with the host or two users stepping on each other, well that's exactly
> what vfio tries to prevent.  A driver in userspace or a VM driver can't
> very well determine these sorts of interactions when it only has
> visibility to a subset of the functions and users and hardware folks
> would throw a fit if I extended iommu groups to encompass all the
> related devices rather than take the relatively simple step of
> virtualizing these accesses and occasionally quirking devices that are
> extra broken, as seems to be required here.  Thanks,

We may want some kind of "strict" vs. "relaxed" model here to
differenciate the desktop user wanting to give a function to his/her
windows partition and doesn't care about strict isolation vs. the cloud
data center.

Cheers,
Ben.
