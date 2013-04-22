From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 08/14] pci: Add SRIOV helper function to determine
 if VFs are assigned to guest
Date: Mon, 22 Apr 2013 09:13:26 -0700
Message-ID: <517561A6.6030506@intel.com>
References: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com> <1366451353-24714-9-git-send-email-jeffrey.t.kirsher@intel.com> <1366515088.2209.15.camel@jtkirshe-mobl> <20130421051423.GA4052@shangw.(null)>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Bjorn Helgaas <bhelgaas@google.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20130421051423.GA4052@shangw.(null)>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/20/2013 10:14 PM, Gavin Shan wrote:
> On Sat, Apr 20, 2013 at 08:31:28PM -0700, Jeff Kirsher wrote:
>> On Sat, 2013-04-20 at 02:49 -0700, Jeff Kirsher wrote:
>>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>>
>>> This function is meant to add a helper function that will determine if a PF
>>> has any VFs that are currently assigned to a guest.  We currently have been
>>> implementing this function per driver, and going forward I would like to avoid
>>> that by making this function generic and using this helper.
>>>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Adding linux-pci mailing list and Bjorn to the CC.
>>
>> Bjorn- David Miller needs a signoff by PCI maintainer. 
>>
>>> ---
>>>  drivers/pci/iov.c   | 41 +++++++++++++++++++++++++++++++++++++++++
>>>  include/linux/pci.h |  5 +++++
>>>  2 files changed, 46 insertions(+)
>>>
>>> diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
>>> index ee599f2..fd99720 100644
>>> --- a/drivers/pci/iov.c
>>> +++ b/drivers/pci/iov.c
>>> @@ -729,6 +729,47 @@ int pci_num_vf(struct pci_dev *dev)
>>>  EXPORT_SYMBOL_GPL(pci_num_vf);
>>>  
>>>  /**
>>> + * pci_vfs_assigned - returns number of VFs are assigned to a guest
>>> + * @dev: the PCI device
>>> + *
>>> + * Returns number of VFs belonging to this device that are assigned to a guest.
>>> + * If device is not a physical function returns -ENODEV.
>>> + */
>>> +int pci_vfs_assigned(struct pci_dev *dev)
>>> +{
>>> +	struct pci_dev *vfdev;
>>> +	unsigned int vfs_assigned = 0;
>>> +	unsigned short dev_id;
>>> +
>>> +	/* only search if we are a PF */
>>> +	if (!dev->is_physfn)
>>> +		return -ENODEV;
> I think it's more reasonable to return zero here?

I suppose that is true, it would be more in keeping with how pci_num_vf
works so I will make that change.

Thanks,

Alex
