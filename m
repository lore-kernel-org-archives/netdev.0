From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 2/3] myri10ge: more Intel chipsets providing aligned PCIe
 completions
Date: Wed, 11 Apr 2007 20:39:18 +0200
Message-ID: <461D2B56.5050603@myri.com>
References: <461BE372.2000600@myri.com> <461BE3C3.3020800@myri.com> <461D04AC.4020306@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1808 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751308AbXDKSkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 14:40:20 -0400
In-Reply-To: <461D04AC.4020306@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
>> @@ -2526,6 +2530,18 @@
>>                  PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST
>>                  && bridge->device <=
>>                  PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST)
>> +                /* All Intel E3000/E3010 PCIE ports */
>> +                || (bridge->vendor == PCI_VENDOR_ID_INTEL
>> +                && (bridge->device ==
>> +                    PCI_DEVICE_ID_INTEL_E3000_PCIE
>> +                    || bridge->device ==
>> +                    PCI_DEVICE_ID_INTEL_E3010_PCIE))
>> +                /* All Intel 6310/6311/6321ESB PCIE ports */
>> +                || (bridge->vendor == PCI_VENDOR_ID_INTEL
>> +                && bridge->device >=
>> +                PCI_DEVICE_ID_INTEL_6300ESB_PCIEE1
>> +                && bridge->device <=
>> +                PCI_DEVICE_ID_INTEL_6300ESB_PCIEE4)
>>                  /* All Intel E5000 PCIE ports */
>>                  || (bridge->vendor == PCI_VENDOR_ID_INTEL
>>                  && bridge->device >=
>
> though I'm applying this, long term this should probably move out of
> myri driver

Right, we are worried about this already-too-long list. Even if we could
imagine having some dedicated functions/quirks or whatever to do this in
the PCI core, we are not sure somebody else will ever use this feature.
For now, we are exploring better ways to decide which firmware to use,
and we currently hope to remove the whitelist entirely in the near future.

Brice

