From: Thomas Preisner <thomas.preisner+linux@fau.de>
Subject: Re: Re: [PATCH v2 1/2] drivers: net: ethernet: 3com: fix return value
Date: Sun, 25 Dec 2016 01:30:20 +0100
Message-ID: <1482625822-19658-1-git-send-email-thomas.preisner+linux@fau.de>
References: <4200be74-f7e7-db6b-a258-8fd178fef369@cogentembedded.com>
Cc: dave@thedillows.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-kernel@i4.cs.fau.de,
        milan.stephan+linux@fau.de, thomas.preisner+linux@fau.de
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4200be74-f7e7-db6b-a258-8fd178fef369@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On Sat, 2016-12-24 at 20:06 +0100, Sergei Shtylyov wrote:
>Hello!
>
>On 12/24/2016 03:02 PM, Thomas Preisner wrote:
>
>> In a few cases the err-variable is not set to a negative error code if a
>> function call fails and thus 0 is returned instead.
>> It may be better to set err to the appropriate negative error code
>> before returning.
>>
>> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188841
>>
>> Reported-by: Pan Bian <bianpan2016@163.com>
>> Signed-off-by: Thomas Preisner <thomas.preisner+linux@fau.de>
>> Signed-off-by: Milan Stephan <milan.stephan+linux@fau.de>
>> ---
>>  drivers/net/ethernet/3com/typhoon.c | 7 +++++--
>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
>> index a0cacbe..c88b88a 100644
>> --- a/drivers/net/ethernet/3com/typhoon.c
>> +++ b/drivers/net/ethernet/3com/typhoon.c
>[...]
>> @@ -2411,7 +2412,8 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>>  	 * later when we print out the version reported.
>>  	 */
>>  	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
>> -	if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
>> +	err = typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp);
>> +	if(err < 0) {
>
>    Need a space between *if* and (. Run your patches thru 
>scripts/checkpatch.pl before posting, please.

Those spaces were actually left out purposely: The file in question (typhoon.c)
is missing those spaces between the statements (if, for, while) and the
following opening bracket pretty much always (except 2-3 times) and we figured
that it might be better to keep the coding style consistent since this might
aswell have been intended by the original author.

>
>>  		err_msg = "Could not get Sleep Image version";
>>  		goto error_out_reset;
>>  	}
>> @@ -2453,7 +2455,8 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>>  	dev->features = dev->hw_features |
>>  		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_RXCSUM;
>>
>> -	if(register_netdev(dev) < 0) {
>> +	err = register_netdev(dev);
>> +	if(err < 0) {
>
>    Same here.
>
>[...]
>
>MBR, Sergei

But of course we can provide you with a patchset including those spaces.

With Regards,
Milan and Thomas
