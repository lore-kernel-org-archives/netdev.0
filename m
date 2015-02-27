From: Stefan Assmann <sassmann@kpanic.de>
Subject: Re: [E1000-devel] i40e: crash on NMI by continuous module reload
Date: Fri, 27 Feb 2015 15:16:09 +0100
Message-ID: <54F07C29.8010805@kpanic.de>
References: <54F07630.1010802@kpanic.de> <54F078DF.5020100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: nick <xerofoify@gmail.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from app1b.xlhost.de ([84.200.252.162]:53190 "EHLO app1b.xlhost.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750777AbbB0OQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2015 09:16:16 -0500
In-Reply-To: <54F078DF.5020100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27.02.2015 15:02, nick wrote:

[...]

>>     i40e: Fix a bug where Rx would stop after some time
>> [...]
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> index f7464e8..ff6d94d 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> [...]
>> @@ -9169,6 +9178,13 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>>  	if (err)
>>  		dev_info(&pf->pdev->dev, "set phy mask fail, aq_err %d\n", err);
>>
>> +	msleep(75);
>> +	err = i40e_aq_set_link_restart_an(&pf->hw, true, NULL);
>> +	if (err) {
>> +		dev_info(&pf->pdev->dev, "link restart failed, aq_err=%d\n",
>> +			 pf->hw.aq.asq_last_status);
>> +	}
>> +
>>  	/* The main driver is (mostly) up and happy. We need to set this state
>>  	 * before setting up the misc vector or we get a race and the vector
>>  	 * ends up disabled forever.
>>
>> With this hunk removed the driver successfully unloaded/reloaded a
>> couple of hundred times. Would it be safe to just remove this hunk?
>> I haven't seen any negative effects by removing this yet.
>>
>>   Stefan
>>
> Stefan,
> I wouldn't remove them yet as this does look like a valid idea to check to see if the link is 
> restarting successfully. On the other hand can you try removing the msleep line as this one is
> most likely causing the issue due to sleeping for some long in a probe function is generally a
> bad idea.
> Thanks,
> Nick

Thanks Nick for the quick reply. I tested removing the msleep but that
didn't make a difference. You actually need to remove the complete hunk
to get a stable driver reload.

  Stefan
