From: Simon Farnsworth <simon.farnsworth@onelan.com>
Subject: Re: r8169 chips on some Intel D945GSEJT boards fail to work after
 PXE boot
Date: Wed, 07 Oct 2009 11:39:52 +0100
Message-ID: <4ACC6FF8.1030504@onelan.com>
References: <4ABA535E.2010801@onelan.com> <20090923205723.GA28058@electric-eye.fr.zoreil.com> <4ABB5435.6040609@onelan.com> <20090930220702.GA15415@electric-eye.fr.zoreil.com> <20091006215601.GA10692@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claranet-outbound-smtp01.uk.clara.net ([195.8.89.34]:44322 "EHLO
	claranet-outbound-smtp01.uk.clara.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755115AbZJGKkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 06:40:49 -0400
In-Reply-To: <20091006215601.GA10692@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
>> @@ -2200,6 +3075,11 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>>  	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
>>  	if (!tp->pcie_cap && netif_msg_probe(tp))
>>  		dev_info(&pdev->dev, "no PCI Express capability\n");
>> +	else {
>> +		pci_write_config_word(pdev, tp->pcie_cap + PCI_EXP_DEVSTA,
>> +				      PCI_EXP_DEVSTA_CED | PCI_EXP_DEVSTA_NFED |
>> +				      PCI_EXP_DEVSTA_FED | PCI_EXP_DEVSTA_URD);
>> +	}
>>  
>>  	RTL_W16(IntrMask, 0x0000);
>>  
> 
> Can you check if this part of the patch is required to fix
> your issue ?
> 
> I'd rather avoid including it under the 8168d support banner
> if it is not needed.
> 
I can confirm that I don't need that hunk.
-- 
Simon Farnsworth

