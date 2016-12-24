From: Thomas Preisner <thomas.preisner+linux@fau.de>
Subject: Re: [PATCH] drivers: net: ethernet: 3com: fix return value
Date: Sat, 24 Dec 2016 13:02:36 +0100
Message-ID: <1482580958-15406-1-git-send-email-thomas.preisner+linux@fau.de>
References: <1482541554.16278.2.camel@dillow-glaptop.roam.corp.google.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kernel@i4.cs.fau.de, milan.stephan+linux@fau.de,
        thomas.preisner+linux@fau.de
To: dave@thedillows.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482541554.16278.2.camel@dillow-glaptop.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-12-24 at 02:06 +0100, David Dillow wrote:
>On Sat, 2016-12-24 at 00:00 +0100, Thomas Preisner wrote:
>> diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
>> index a0cacbe..9a3ab58 100644
>> --- a/drivers/net/ethernet/3com/typhoon.c
>> +++ b/drivers/net/ethernet/3com/typhoon.c
>> @@ -2404,6 +2404,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>>  
>>  	if(!is_valid_ether_addr(dev->dev_addr)) {
>>  		err_msg = "Could not obtain valid ethernet address, aborting";
>> +		err = -EIO;
>>  		goto error_out_reset;
>
>The change above is fine, but the other two should use the return value
>from the failing function call.
>
>
>> @@ -2413,6 +2414,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>>  	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
>>  	if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
>>  		err_msg = "Could not get Sleep Image version";
>> +		err = -EIO;
>>  		goto error_out_reset;
>>  	}
>>  
>> @@ -2455,6 +2457,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>>  
>>  	if(register_netdev(dev) < 0) {
>>  		err_msg = "unable to register netdev";
>> +		err = -EIO;
>>  		goto error_out_reset;
>>  	}
>>  

You are of course right. After you mentioning this we've looked into it a bit
further and realized that the return values of failing function calls are not
being used in various occasions inside of typhoon_init_one().
That's why we've created a second patch to fix this misbehavior (if it is one).
In case this was intended, feel free to ignore the second patch.

Patch 1:
Makes the function typhoon_init_one() return a negative error code instead of 0.

Patch 2 [Optional]:
Makes the function typhoon_init_one() return the return value of the
corresponding failing function calls instead of a "fixed" negative error code.

With regards (and merry christmas),
Milan and Thomas
