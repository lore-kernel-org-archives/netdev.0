From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: nfc: nci: fix potential NULL pointer dereference
Date: Mon, 12 Jun 2017 17:31:54 -0700
Message-ID: <28317503-e721-2564-a9ff-82182aa0644a@roeck-us.net>
References: <20170612220223.GA6326@embeddedgus>
 <20170612222155.GA18302@roeck-us.net>
 <20170612172805.Horde.AUST5RGJfhNVnchxoXV3U2C@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <sameo@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170612172805.Horde.AUST5RGJfhNVnchxoXV3U2C@gator4166.hostgator.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/12/2017 03:28 PM, Gustavo A. R. Silva wrote:
> Hi Guenter,
> 
> Please, see my comments below
> 
> Quoting Guenter Roeck <linux@roeck-us.net>:
> 
>> On Mon, Jun 12, 2017 at 05:02:23PM -0500, Gustavo A. R. Silva wrote:
>>> NULL check at line 76: if (conn_info) {, implies that pointer conn_info
>>> might be NULL, but this pointer is being previously dereferenced,
>>> which might cause a NULL pointer dereference.
>>>
>>> Add NULL check before dereferencing pointer conn_info in order to
>>> avoid a potential NULL pointer dereference.
>>>
>>> Addresses-Coverity-ID: 1362349
>>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>>> ---
>>>  net/nfc/nci/core.c | 11 +++++------
>>>  1 file changed, 5 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
>>> index 61fff42..d2198ce 100644
>>> --- a/net/nfc/nci/core.c
>>> +++ b/net/nfc/nci/core.c
>>> @@ -70,14 +70,13 @@ int nci_get_conn_info_by_dest_type_params(struct nci_dev *ndev, u8 dest_type,
>>>      struct nci_conn_info *conn_info;
>>>
>>>      list_for_each_entry(conn_info, &ndev->conn_info_list, list) {
>>
>> conn_info is set in list_for_each_entry() using container_of(),
>> which is never NULL. Plus, it is dereferenced there as well.
>> The check is unnecessary.
>>
> 
> Thanks for clarifying.
> 
>> Guenter
>>
>>> -        if (conn_info->dest_type == dest_type) {
>>> +        if (conn_info && conn_info->dest_type == dest_type) {
>>>              if (!params)
>>>                  return conn_info->conn_id;
>>> -            if (conn_info) {
> 
> So, this NULL check could be removed as it seems it is not useful at all ?
> 
Exactly.

>>> -                if (params->id == conn_info->dest_params->id &&
>>> -                    params->protocol == conn_info->dest_params->protocol)
>>> -                    return conn_info->conn_id;
>>> -            }
>>> +
>>> +            if (params->id == conn_info->dest_params->id &&
>>> +                params->protocol == conn_info->dest_params->protocol)
>>> +                return conn_info->conn_id;
>>>          }
>>>      }
>>>
> 
> Thank you
> -- 
> Gustavo A. R. Silva
> 
> 
> 
> 
> 
> 
> 
