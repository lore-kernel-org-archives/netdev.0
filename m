From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: [patch] e100: early reset fix
Date: Tue, 23 Nov 2004 14:22:43 -0800
Message-ID: <468F3FDA28AA87429AD807992E22D07E0363FCF7@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Ronciak, John" <john.ronciak@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Jeff Garzik" <jgarzik@pobox.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Andrew Morton" <akpm@osdl.org>, <sfeldma@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andy:

Please forward this patch to Linus for inclusion into 2.6.10. We missed
our internal driver release window and will have to wait another ~ 6
weeks before we release another version of e100.

Thanks,
Ganesh.

>-----Original Message-----
>From: Andrew Morton [mailto:akpm@osdl.org]
>Sent: Monday, November 22, 2004 5:42 PM
>To: sfeldma@pobox.com
>Cc: Ronciak, John; Venkatesan, Ganesh; Brandeburg, Jesse; Jeff Garzik
>Subject: Re: [patch] e100: early reset fix
>
>Scott Feldman <sfeldma@pobox.com> wrote:
>>
>> On Mon, 2004-11-22 at 01:52, Andrew Morton wrote:
>> > Gents, what do we think of the below fix?
>>
>> This keeps just one reset, and adds a comment so someone doesn't
>> rearrange things later.
>>
>> Signed-off-by: Scott Feldman <sfeldma@pobox.com>
>
>It works, of course.   You want me to feed it into Linus for 2.6.10?
>
>> --------------
>>
>> --- linux-2.6.10-rc2/drivers/net/e100.c	2004-11-22
11:15:50.180163536 -
>0800
>> +++ linux-2.6.10-rc2/drivers/net/e100.c.mod	2004-11-22
>11:41:23.893003744 -0800
>> @@ -2204,8 +2204,6 @@ static int __devinit e100_probe(struct p
>>  		goto err_out_disable_pdev;
>>  	}
>>
>> -	pci_set_master(pdev);
>> -
>>  	if((err = pci_set_dma_mask(pdev, 0xFFFFFFFFULL))) {
>>  		DPRINTK(PROBE, ERR, "No usable DMA configuration,
>aborting.\n");
>>  		goto err_out_free_res;
>> @@ -2226,6 +2224,15 @@ static int __devinit e100_probe(struct p
>>  	else
>>  		nic->flags &= ~ich;
>>
>> +	e100_get_defaults(nic);
>> +
>> +	/* Reset the device before pci_set_master() in case device is in
some
>> +	 * funky state and has an interrupt pending - hint: we don't
have the
>> +	 * interrupt handler registered yet. */
>> +	e100_hw_reset(nic);
>> +
>> +	pci_set_master(pdev);
>> +
>>  	spin_lock_init(&nic->cb_lock);
>>  	spin_lock_init(&nic->cmd_lock);
>>
>> @@ -2241,8 +2248,6 @@ static int __devinit e100_probe(struct p
>>  		goto err_out_iounmap;
>>  	}
>>
>> -	e100_get_defaults(nic);
>> -	e100_hw_reset(nic);
>>  	e100_phy_init(nic);
>>
>>  	if((err = e100_eeprom_load(nic)))
