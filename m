From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Mon, 7 Oct 2013 21:48:01 +0100
Message-ID: <1381178881.1536.28.camel@bwh-desktop.uk.level5networks.com>
References: <cover.1380703262.git.agordeev@redhat.com>
	 <1380840585.3419.50.camel@bwh-desktop.uk.level5networks.com>
	 <20131004082920.GA4536@dhcp-26-207.brq.redhat.com>
	 <1380922156.3214.49.camel@bwh-desktop.uk.level5networks.com>
	 <20131005142054.GA11270@dhcp-26-207.brq.redhat.com>
	 <1381009586.645.141.camel@pasglop>
	 <20131006060243.GB28142@dhcp-26-207.brq.redhat.com>
	 <1381040386.645.143.camel@pasglop>
	 <20131006071027.GA29143@dhcp-26-207.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"Ralf Baechle" <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Andy King <acking-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, Jon Mason <jon.mason-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Matt Porter <mporter-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	<linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	<linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, <linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	<linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <iss_storagedev-VXdhtT5mjnY@public.gmane.org>,
	<linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	<linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
	Solarflare linux maintainers <linux-net-drivers@solarfla
To: Alexander Gordeev <agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131006071027.GA29143-hdGaXg0bp3uRXgp2RCiI5R/sF2h8X+2i0E9HWUfgJXw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-10-06 at 09:10 +0200, Alexander Gordeev wrote:
> On Sun, Oct 06, 2013 at 05:19:46PM +1100, Benjamin Herrenschmidt wrote:
> > On Sun, 2013-10-06 at 08:02 +0200, Alexander Gordeev wrote:
> > > In fact, in the current design to address the quota race decently the
> > > drivers would have to protect the *loop* to prevent the quota change
> > > between a pci_enable_msix() returned a positive number and the the next
> > > call to pci_enable_msix() with that number. Is it doable?
> > 
> > I am not advocating for the current design, simply saying that your
> > proposal doesn't address this issue while Ben's does.
> 
> There is one major flaw in min-max approach - the generic MSI layer
> will have to take decisions on exact number of MSIs to request, not
> device drivers.
[...

No, the min-max functions should be implemented using the same loop that
drivers are expected to use now.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
