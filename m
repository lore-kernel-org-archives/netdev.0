From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] [e1000] Lower the MSI unavailable message to INFO priority
Date: Wed, 16 May 2007 08:26:19 -0700
Message-ID: <464B229B.7060702@intel.com>
References: <200705152359.l4FNxPcS018779@tazenda.hos.anvin.org> <464A512C.9080104@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	e1000-devel@lists.sourceforge.net, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13260 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756332AbXEPP00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 11:26:26 -0400
In-Reply-To: <464A512C.9080104@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> H. Peter Anvin wrote:
>> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
>> index 637ae8f..089ae3f 100644
>> --- a/drivers/net/e1000/e1000_main.c
>> +++ b/drivers/net/e1000/e1000_main.c
>> @@ -307,7 +307,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
>>  	if (adapter->hw.mac_type >= e1000_82571) {
>>  		adapter->have_msi = TRUE;
>>  		if ((err = pci_enable_msi(adapter->pdev))) {
>> -			DPRINTK(PROBE, ERR,
>> +			DPRINTK(PROBE, INFO,
>>  			 "Unable to allocate MSI interrupt Error: %d\n", err);
>>  			adapter->have_msi = FALSE;
> 
> 
> Actually, it should not print any message at all.
> 
> pci_enable_msi() failure is a normal event (as you point out).  Even at 
> KERN_INFO level, the message is still misleading.

I've been reworking some of this code and there is even a pci_disable_msi() 
missing in case pci_request_irq failed. I'll post a patch to clean it up in a 
second.

Cheers,

Auke
