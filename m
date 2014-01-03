From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [net-next] pci_regs.h: Add PCI bus link speed and width defines
Date: Fri, 3 Jan 2014 15:15:57 -0700
Message-ID: <CAErSpo7K3OBuTEZrXmhQ3iXtLf3M5JNnEqmAvaceroJ46VAOKg@mail.gmail.com>
References: <1388234173-31654-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <20140102.192133.1585340046080167370.davem@davemloft.net> <CAEuXFEw=A0mppxtgzpmnh3feLiKYb+LJQvFRMrW3C4h+jHpO2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	NetDEV list <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Bjorn Helgaas <bjorn.helgaas@hp.com>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAEuXFEw=A0mppxtgzpmnh3feLiKYb+LJQvFRMrW3C4h+jHpO2Q@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 3, 2014 at 2:53 PM, Jesse Brandeburg
<jesse.brandeburg@gmail.com> wrote:
> +linux-pci

Thanks, Jesse.

> <and see note below>
>
> On Thu, Jan 2, 2014 at 4:21 PM, David Miller <davem@davemloft.net> wrote:
>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Date: Sat, 28 Dec 2013 04:36:13 -0800
>>
>>> Add missing PCI bus link speed 8.0 GT/s and bus link widths of
>>> x1, x2, x4 and x8.
>>>
>>> CC: <linux-kernel@vger.kernel.org>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>
>> Can a PCI person please ACK this?  This is a prerequisite for some
>> networking driver changes Jeff would like to push to me.

The additions look correct to me, and I don't object to them per se, so:

Acked-by: Bjorn Helgaas <bhelgaas@google.com>

However, I do raise my eyebrows a bit at drivers that poke around in
the PCIe capability.  I would prefer to have PCI core interfaces that
handle that instead.  But I haven't seen Jeff's changes yet.

>>> ---
>>>  include/uapi/linux/pci_regs.h | 5 +++++
>>>  1 file changed, 5 insertions(+)
>>>
>>> diff --git a/include/uapi/linux/pci_regs.h b/include/uapi/linux/pci_regs.h
>>> index 4a98e85..c870c2a 100644
>>> --- a/include/uapi/linux/pci_regs.h
>>> +++ b/include/uapi/linux/pci_regs.h
>>> @@ -489,7 +489,12 @@
>>>  #define  PCI_EXP_LNKSTA_CLS  0x000f  /* Current Link Speed */
>>>  #define  PCI_EXP_LNKSTA_CLS_2_5GB 0x0001 /* Current Link Speed 2.5GT/s */
>>>  #define  PCI_EXP_LNKSTA_CLS_5_0GB 0x0002 /* Current Link Speed 5.0GT/s */
>>> +#define  PCI_EXP_LNKSTA_CLS_8_0GB 0x0003 /* Current Link Speed 8.0GT/s */
>>>  #define  PCI_EXP_LNKSTA_NLW  0x03f0  /* Negotiated Link Width */
>>> +#define  PCI_EXP_LNKSTA_NLW_X1       0x0010  /* Current Link Width x1 */
>>> +#define  PCI_EXP_LNKSTA_NLW_X2       0x0020  /* Current Link Width x2 */
>>> +#define  PCI_EXP_LNKSTA_NLW_X4       0x0040  /* Current Link Width x4 */
>>> +#define  PCI_EXP_LNKSTA_NLW_X8       0x0080  /* Current Link Width x8 */
>>>  #define  PCI_EXP_LNKSTA_NLW_SHIFT 4  /* start of NLW mask in link status */
>>>  #define  PCI_EXP_LNKSTA_LT   0x0800  /* Link Training */
>>>  #define  PCI_EXP_LNKSTA_SLC  0x1000  /* Slot Clock Configuration */
>
> also note that these defines from this patch are already partially
> defined in drivers/pci/probe.c but likely need to move into a header
> file and be consolidated throughout the kernel.  That said I don't see
> any issue with adding these as a separate set of defines in
> uapi/linux/pci_regs.h
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
