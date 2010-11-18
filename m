From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: extended netdevice naming proposal
Date: Thu, 18 Nov 2010 00:39:55 +0000
Message-ID: <1290040795.30433.101.camel@localhost>
References: <20101117220659.GA12177@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	narendra_k@dell.com, jcm@redhat.com, notting@redhat.com
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20101117220659.GA12177@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-11-17 at 16:06 -0600, Matt Domsch wrote:
> While this _is_ the original bikeshedding problem, as long as I'm
> going to use biosdevname to change names for embedded NICs, perhaps I
> can be so bold as to change them for USB add-in cards too?
> 
> There are quite a few dimensions to the problem:
> * device location (onboard, PCI, other bus)
> * multiple ports on a single add-in card
> * with Network Partitioning (NPAR) and SR-IOV, the OS sees multiple
>   network interfaces (physical or virtual interfaces) but a single external port
> * the suffix .1234 currently used for vlans (ala vconfig)
> * A single PCI device may drive multiple external ports
> 
> As such, here is a naming proposal, aimed to keep within 15
> characters for most configurations.
> 
> (location)(slot)#(port)/(instance).(vlan)
> 
> location := NIC on Motherboard = net1, net2, net3, net4

"net", really?!  I can't say I care that much, but this just doesn't
seem like a helpful prefix.

>    (note: people hated the TLA collision with 'lom', so avoiding that here).
>          := PCI slot = pci1, pci2, pci3, pci4
>  these correspond to chassis labels, information is available in
>  $PIRQ, SMBIOS or ACPI, which biosdevname retrieves and uses.
> 
> For single- or multi-port cards in PCI slots, append #(port):
>    pci1#1, pci1#2, pci1#3, pci1#4  for 4 ports on a card in PCI slot 1

'#' might be problematic but I don't have any concrete evidence of that.

> There is currently no way to get this port info from BIOS.  Several people
> have suggested using adding a PCI capabilities field to expose this
> info in a standard way, but that's a ways off. Until then, biosdevname
> can guess (assume ascending MAC order on the single card).

You could try using the dev_id attribute first; it's supposed to be a
0-based index of a net device on a board.  It won't be unique in all
cases, e.g. if a NIC vendor has used a bridge chip to connect multiple
controllers on a single board or if the driver just doesn't set it.  So
you would need to fall back to MAC order in tha tcase.

> For NPAR/SR-IOV where the physical port is shared by several
> instances, append /(instance):
>    net1/1, net1/2 pci1#1/1, pci1#1/2,
>    pci1#1/2, pci1#1/3, ...
[...]

Surely VFs are normally passed through to a guest, in which case:
1. The host/console/dom0 won't create a net device for them.
2. The guest won't (and shouldn't) have such information about the
physical location of the PCI function.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

