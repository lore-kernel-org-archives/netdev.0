From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: nfc: nci: fix potential NULL pointer dereference
Date: Mon, 12 Jun 2017 17:28:05 -0500
Message-ID: <20170612172805.Horde.AUST5RGJfhNVnchxoXV3U2C@gator4166.hostgator.com>
References: <20170612220223.GA6326@embeddedgus>
 <20170612222155.GA18302@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Samuel Ortiz <sameo@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway23.websitewelcome.com ([192.185.49.219]:18425 "EHLO
        gateway23.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752619AbdFLW2I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 18:28:08 -0400
Received: from cm17.websitewelcome.com (cm17.websitewelcome.com [100.42.49.20])
        by gateway23.websitewelcome.com (Postfix) with ESMTP id 9B3D74905E
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 17:28:05 -0500 (CDT)
In-Reply-To: <20170612222155.GA18302@roeck-us.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guenter,

Please, see my comments below

Quoting Guenter Roeck <linux@roeck-us.net>:

> On Mon, Jun 12, 2017 at 05:02:23PM -0500, Gustavo A. R. Silva wrote:
>> NULL check at line 76: if (conn_info) {, implies that pointer conn_info
>> might be NULL, but this pointer is being previously dereferenced,
>> which might cause a NULL pointer dereference.
>>
>> Add NULL check before dereferencing pointer conn_info in order to
>> avoid a potential NULL pointer dereference.
>>
>> Addresses-Coverity-ID: 1362349
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>> ---
>>  net/nfc/nci/core.c | 11 +++++------
>>  1 file changed, 5 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
>> index 61fff42..d2198ce 100644
>> --- a/net/nfc/nci/core.c
>> +++ b/net/nfc/nci/core.c
>> @@ -70,14 +70,13 @@ int  
>> nci_get_conn_info_by_dest_type_params(struct nci_dev *ndev, u8  
>> dest_type,
>>  	struct nci_conn_info *conn_info;
>>
>>  	list_for_each_entry(conn_info, &ndev->conn_info_list, list) {
>
> conn_info is set in list_for_each_entry() using container_of(),
> which is never NULL. Plus, it is dereferenced there as well.
> The check is unnecessary.
>

Thanks for clarifying.

> Guenter
>
>> -		if (conn_info->dest_type == dest_type) {
>> +		if (conn_info && conn_info->dest_type == dest_type) {
>>  			if (!params)
>>  				return conn_info->conn_id;
>> -			if (conn_info) {

So, this NULL check could be removed as it seems it is not useful at all ?

>> -				if (params->id == conn_info->dest_params->id &&
>> -				    params->protocol == conn_info->dest_params->protocol)
>> -					return conn_info->conn_id;
>> -			}
>> +
>> +			if (params->id == conn_info->dest_params->id &&
>> +			    params->protocol == conn_info->dest_params->protocol)
>> +				return conn_info->conn_id;
>>  		}
>>  	}
>>

Thank you
