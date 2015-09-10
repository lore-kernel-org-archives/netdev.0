From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH] igb: don't unmap hw_addr if its NULL
Date: Thu, 10 Sep 2015 14:28:03 -0400
Message-ID: <55F1CBB3.6060309@redhat.com>
References: <1441858049-44827-1-git-send-email-jarod@redhat.com> <9AC147AD-6D52-4A7D-BE5B-3A40F8D22B1A@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35490 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbbIJS2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2015 14:28:07 -0400
In-Reply-To: <9AC147AD-6D52-4A7D-BE5B-3A40F8D22B1A@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rustad, Mark D wrote:
>> On Sep 9, 2015, at 9:07 PM, Jarod Wilson<jarod@redhat.com>  wrote:
>>
>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
>> index e174fbb..a5e0022 100644
>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>> @@ -2823,7 +2823,8 @@ static void igb_remove(struct pci_dev *pdev)
>>
>> 	igb_clear_interrupt_scheme(adapter);
>>
>> -	pci_iounmap(pdev, hw->hw_addr);
>> +	if (hw->hw_addr)
>> +		pci_iounmap(pdev, hw->hw_addr);
>> 	if (hw->flash_address)
>> 		iounmap(hw->flash_address);
>> 	pci_release_selected_regions(pdev,
>
> I don't think that this is entirely the right solution. In ixgbe we
> have a separate pointer, io_addr, used to manage the resource, so that
> the space can be freed even after hw_addr is cleared. With the approach
> above, the pci_iounmap will not ever be called on the space. You can see
> how ixgbe is doing it.

Ah, you're right, that had crossed my mind briefly as well. I've got a 
revised version here now that adds an io_addr to igb_adapter and uses 
that for unmap. I'll post it after I double-check that it builds and 
functions as expected.

-- 
Jarod Wilson
jarod@redhat.com
