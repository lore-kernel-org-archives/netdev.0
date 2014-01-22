From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/5] bonding: The fail_over_mac should be set
 only in ACTIVE_BACKUP mode
Date: Wed, 22 Jan 2014 09:59:06 +0800
Message-ID: <52DF25EA.90405@huawei.com>
References: <52DE4161.3050801@huawei.com> <20332.1390350326@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:11507 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbaAVB7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 20:59:33 -0500
In-Reply-To: <20332.1390350326@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/22 8:25, Jay Vosburgh wrote:
> Ding Tianhong <dingtianhong@huawei.com> wrote:
> 
>> According the bonding.txt, the option fail_over_mac only affect for
>> AB mode, but in currect code, the parameter could be set to active
>> or follow in every mode, this will cause bonding could not set all
>> slaves of an RR or XOR mode to the same MAC address at enslavement
>> time, so reset fail_over_mac to 0 if the mode is not ACTIVE_BACKUP.
> 
> 	The correct way to fix this in general is to permit setting an
> option at any time, but only have it take effect in active-backup mode.
> This minimizes ordering requirements when setting options.
> 
ok

> 	I would instead modify the bond enslave and removal processing
> to check the mode in addition to fail_over_mac when setting a slave's
> MAC during enslavement.  The change active slave processing already only
> calls the fail_over_mac function when in active-backup mode.  This
> should also be a simpler change set.
> 
agree, the current modify actually more redundant.

>> Fix the wrong variables for pr_err().
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_main.c | 8 +++++---
>> 1 file changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 3220b48..ecff04e 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -4307,12 +4307,14 @@ static int bond_check_params(struct bond_params *params)
>> 						      fail_over_mac_tbl);
>> 		if (fail_over_mac_value == -1) {
>> 			pr_err("Error: invalid fail_over_mac \"%s\"\n",
>> -			       arp_validate == NULL ? "NULL" : arp_validate);
>> +			       fail_over_mac == NULL ? "NULL" : fail_over_mac);
> 
> 	This part is ok.
> 
>> 			return -EINVAL;
>> 		}
>>
>> -		if (bond_mode != BOND_MODE_ACTIVEBACKUP)
>> -			pr_warning("Warning: fail_over_mac only affects active-backup mode.\n");
>> +		if (bond_mode != BOND_MODE_ACTIVEBACKUP) {
>> +			pr_warning("Warning: fail_over_mac only affects active-backup mode, set it to 0.\n");
>> +			fail_over_mac_value = BOND_FOM_NONE;
>> +		}
> 
> 	This part is not.
> 
> 	I would additionally NAK patches 2, 3, and 4 (noting that 4
> inhibits the change to fail_over_mac, but not the warning message that
> we're changing it).
> 
> 	Patch 5 is ok, although it really has nothing to do with
> fail_over_mac.
> 
> 	-J
> 

The whole patchset need to be rebuild, thanks for reviewing.

Regards
Ding

>> 	} else {
>> 		fail_over_mac_value = BOND_FOM_NONE;
>> 	}
>> -- 
>> 1.8.0
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 
> 
> 
