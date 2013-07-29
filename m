From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [net-next 08/15] pci: expose pcie_link_speed and pcix_bus_speed arrays
Date: Mon, 29 Jul 2013 15:19:51 -0600
Message-ID: <CAErSpo50X1cDSo-o8UU5jAJpRudFY3+oCFKS7DbOYMhpNVxSqA@mail.gmail.com>
References: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1375102331-23905-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAErSpo5sVTveY54iodDuqLXqsUTqUXTfDLh14k3=okneHB+ikg@mail.gmail.com> <1375131833.5297.14.camel@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1375131833.5297.14.camel@jekeller-desk1.amr.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 29, 2013 at 3:03 PM, Keller, Jacob E
<jacob.e.keller@intel.com> wrote:
> On Mon, 2013-07-29 at 12:44 -0600, Bjorn Helgaas wrote:
>> On Mon, Jul 29, 2013 at 6:52 AM, Jeff Kirsher
>> <jeffrey.t.kirsher@intel.com> wrote:
>> > From: Jacob Keller <jacob.e.keller@intel.com>
>> >
>> > pcie_link_speed and pcix_bus_speed are arrays used by probe.c to correctly
>> > convert lnksta register values into the pci_bus_speed enum. These static arrays
>> > are useful outside probe for this purpose. This patch makes these defines into
>> > const arrays and exposes them with an extern header in linux/include/pci.h
>> >
>> > Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
>> > Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> > ---
>> >  drivers/pci/probe.c | 4 ++--
>> >  include/linux/pci.h | 3 +++
>> >  2 files changed, 5 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
>> > index 46ada5c..496c5b0 100644
>> > --- a/drivers/pci/probe.c
>> > +++ b/drivers/pci/probe.c
>> > @@ -513,7 +513,7 @@ static struct pci_host_bridge *pci_alloc_host_bridge(struct pci_bus *b)
>> >         return bridge;
>> >  }
>> >
>> > -static unsigned char pcix_bus_speed[] = {
>> > +const unsigned char pcix_bus_speed[] = {
>> >         PCI_SPEED_UNKNOWN,              /* 0 */
>> >         PCI_SPEED_66MHz_PCIX,           /* 1 */
>> >         PCI_SPEED_100MHz_PCIX,          /* 2 */
>> > @@ -532,7 +532,7 @@ static unsigned char pcix_bus_speed[] = {
>> >         PCI_SPEED_133MHz_PCIX_533       /* F */
>> >  };
>> >
>> > -static unsigned char pcie_link_speed[] = {
>> > +const unsigned char pcie_link_speed[] = {
>> >         PCI_SPEED_UNKNOWN,              /* 0 */
>> >         PCIE_SPEED_2_5GT,               /* 1 */
>> >         PCIE_SPEED_5_0GT,               /* 2 */
>> > diff --git a/include/linux/pci.h b/include/linux/pci.h
>> > index 0fd1f15..95ff993 100644
>> > --- a/include/linux/pci.h
>> > +++ b/include/linux/pci.h
>> > @@ -120,6 +120,9 @@ typedef int __bitwise pci_power_t;
>> >  /* Remember to update this when the list above changes! */
>> >  extern const char *pci_power_names[];
>> >
>> > +extern const unsigned char pcix_bus_speed[];
>> > +extern const unsigned char pcie_link_speed[];
>>
>> As far as I can tell, you didn't actually add anything that uses
>> pcix_bus_speed[].
>>
>
> I mostly added this for consistency...
>
>> You added a pcie_link_speed[] use only in drivers/pci/pci.c; maybe
>> this extern declaration could go in drivers/pci/pci.h to limit its
>> visibility?
>
> Pretty sure I use the pcie_link_speed in the ixgbe driver by including
> the linux/pci.h header...  Check patch 11/15 of this series where I
> actually use the values, so it would need to be in the linux/pci.h
> header.

I'm not sure I was copied on patch 11/15.  I assume it might be
"ixgbe: call pcie_get_mimimum_link to check if device has enough
bandwidth", and I see that patch uses the pci_bus_speed enum, so the
enum definitely needs to be in include/linux/pci.h.  But I don't see
the pcie_link_speed[] reference.

I did fetch your git tree and searched the diffs themselves but the
only use I saw was in pcie_get_minimum_link() in drivers/pci/pci.c.

Bjorn
