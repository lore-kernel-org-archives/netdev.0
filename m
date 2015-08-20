From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH, net-next] r8169: Disable some bits on pcie
Date: Thu, 20 Aug 2015 16:29:44 +0300
Message-ID: <55D5D648.6010407@cogentembedded.com>
References: <1440065553-15028-1-git-send-email-corcodel.marian@gmail.com>
 <55D5CEA0.2090900@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Corcodel Marian <corcodel.marian@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:33822 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbbHTN3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 09:29:46 -0400
Received: by laba3 with SMTP id a3so22592215lab.1
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 06:29:45 -0700 (PDT)
In-Reply-To: <55D5CEA0.2090900@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/20/2015 3:57 PM, Sergei Shtylyov wrote:

>> Disable legacy interrupt on pci express interface use msi
>>   disable some bits from pci express interface wich is not   need on this nic.
>>
>>
>> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
>>
>> diff --git a/drivers/net/ethernet/realtek/r8169.c
>> b/drivers/net/ethernet/realtek/r8169.c
>> index 6d16de3..b1fb54f 100644
>> --- a/drivers/net/ethernet/realtek/r8169.c
>> +++ b/drivers/net/ethernet/realtek/r8169.c
>> @@ -8164,6 +8164,13 @@ static int rtl_init_one(struct pci_dev *pdev, const
>> struct pci_device_id *ent)
>>       if (!pci_is_pcie(pdev))
>>           netif_info(tp, probe, dev, "not PCI Express\n");
>>
>> +    if (pci_is_pcie(pdev))
>> +        pci_write_config_word(pdev, PCI_COMMAND, ~(PCI_COMMAND_FAST_BACK |
>> PCI_COMMAND_WAIT |
>> +                    PCI_COMMAND_VGA_PALETTE | PCI_COMMAND_INVALIDATE |
>> PCI_COMMAND_SPECIAL));
>
>     Please start the continuation line under 'pdev' on the first line.

    Can all those bits indeed be set for a networking device? 
PCI_COMMAND_VGA_PALETTE is the most incredible...

>> +
>> +    if (pci_is_pcie(pdev))
>> +        pci_intx(pdev, 0);
>> +
>
>     Why two identical *if* statements? Please make it one.

    Ah, I missed the *if* at the top. You need just an *else* clause here.

MBR, Sergei
