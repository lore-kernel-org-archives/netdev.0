From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can/sja1000: driver for PEAK PCAN PCI/PCIe
	cards
Date: Fri, 09 Sep 2011 17:20:18 +0200
Message-ID: <4E6A2EB2.5070601@grandegger.com>
References: <4E692080.9020801@grandegger.com> <4E6A25EE.3000501@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-g4cQ8AsIbFbL9ATBNaCtXw@public.gmane.org,
	Thomas Wiedemann <Thomas.Wiedemann-8kCRUXUQ4vU@public.gmane.org>
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E6A25EE.3000501-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Oliver,

On 09/09/2011 04:42 PM, Oliver Hartkopp wrote:
> Hello Wolfgang,
> 
> many thanks for providing this patch!
> 
> On 09/08/11 22:07, Wolfgang Grandegger wrote:
> 
>> This patch adds the "peak_pci" driver for the PCAN PCI/PCIe cards (1, 2, 3
>> or 4 channels) from PEAK Systems (http://www.peak-system.com).
> 
> 
> Yes - that fits, but ...
> 
> 
>> +#define PEAK_PCI_VENDOR_ID	0x001C	/* The PCI device and vendor IDs */
>> +#define PEAK_PCI_DEVICE_ID	0x0001	/* for PCI / PCIe slot cards */
>> +#define PEAK_PCIE_DEVICE_ID	0x0002	/* for PCIExpress cards */
>> +
>> +static const u16 peak_pci_icr_masks[] = {0x02, 0x01, 0x40, 0x80};
>> +
>> +static DEFINE_PCI_DEVICE_TABLE(peak_pci_tbl) = {
>> +	{PEAK_PCI_VENDOR_ID, PEAK_PCI_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
>> +	{PEAK_PCI_VENDOR_ID, PEAK_PCIE_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
>> +	{0,}
>> +};
> 
> 
> The problem is the support of the PCAN ExpressCard (device ID 0x0002) here.
> 
> This commit
> 
>    https://lists.berlios.de/pipermail/socketcan-commit/2010-June/000814.html
> 
> should be reverted, as you can use the PCAN-ExpressCard (IPEH-00300[12]) only
> with a hardware patch, as we need some I2C initialisations to enable the CAN
> transceiver (and the funky status LEDs). See at:
> 
> http://anonscm.debian.org/gitweb/?p=collab-maint/peak-linux-driver.git;a=blob;f=driver/src/pcan_pciec.c;h=87ce0bda41aa0a6dda8284d48237b1ef7c678e11;hb=HEAD#l36

OK, I see, I will revert then. I already realized the I2C stuff for the
PCAN-ExpressCard. Obviously Thomas does not use that card but a PCIe
slot cards

> I'll also test your driver on Monday.

Thanks,

Wolfgang.
