From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH net-next v3 1/2] pci: Add Cavium PCI vendor id
Date: Mon, 18 May 2015 11:35:20 -0500
Message-ID: <CAErSpo61OUg7PS-rPpAMNBUg4MNtxUig21eWe0hewKpbdDrnEA@mail.gmail.com>
References: <1431747401-20847-1-git-send-email-aleksey.makarov@auriga.com>
 <1431747401-20847-2-git-send-email-aleksey.makarov@auriga.com>
 <CAErSpo4fLHEu_NOuy9CkrS9DOfSyCOkddPHEQz=pp6et8wa2AA@mail.gmail.com> <20150516.171444.245757401088795324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: aleksey.makarov@auriga.com, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Daney <david.daney@cavium.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150516.171444.245757401088795324.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[+cc Greg]

On Sat, May 16, 2015 at 4:14 PM, David Miller <davem@davemloft.net> wrote:
> From: Bjorn Helgaas <bhelgaas@google.com>
> Date: Sat, 16 May 2015 09:49:40 -0500
>
>> Hi Aleksey,
>>
>> On Fri, May 15, 2015 at 10:36 PM, Aleksey Makarov
>> <aleksey.makarov@auriga.com> wrote:
>>> Signed-off-by: Aleksey Makarov <aleksey.makarov@auriga.com>
>>> ---
>>>  include/linux/pci_ids.h | 2 ++
>>>  1 file changed, 2 insertions(+)
>>>
>>> diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
>>> index e63c02a..3633cc6 100644
>>> --- a/include/linux/pci_ids.h
>>> +++ b/include/linux/pci_ids.h
>>> @@ -2327,6 +2327,8 @@
>>>  #define PCI_DEVICE_ID_ALTIMA_AC9100    0x03ea
>>>  #define PCI_DEVICE_ID_ALTIMA_AC1003    0x03eb
>>>
>>> +#define PCI_VENDOR_ID_CAVIUM           0x177d
>>
>> Please read the note at the top of include/linux/pci_ids.h.  If this
>> definition is used in two or more drivers, mention that in the
>> changelog.  Otherwise, just use the bare hex value or a private
>> #define in your driver.
>
> It is referenced from two foo.c files in the same driver.
>
> I don't know what policy we want for situations like that.

The current policy (1d4a433fc4e9 ("PCI: Document pci_ids.h addition
policy.")) predates me and I don't know the whole rationale.  I can
see that it might reduce backporting pain for distros.

If two foo.c files in the same driver share the PCI ID, they likely
share other things as well, so there's likely a shared .h file where a
private PCI_VENDOR_ID_CAVIUM could go.

But this is a vendor ID (not a device ID), and it seems likely that
there will be other devices from Cavium, so maybe it would make sense
to apply the policy to device IDs, and go ahead and add vendor IDs to
pci_ids.h.

Bjorn
