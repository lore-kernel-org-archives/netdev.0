From: arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: Re: [v3] net: ethernet: cavium: octeon: octeon_mgmt: Handle return
 NULL error from devm_ioremap
Date: Thu, 15 Dec 2016 20:30:41 +0530
Message-ID: <e873ff5c-3f7f-3b14-b563-c6a3584f303d@gmail.com>
References: <1481742210-5609-1-git-send-email-arvind.yadav.cs@gmail.com>
 <41599714-309c-8590-b2b0-e468cffb57b5@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Daney <ddaney@caviumnetworks.com>, peter.chen@nxp.com,
        fw@strlen.de, david.daney@cavium.com, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <41599714-309c-8590-b2b0-e468cffb57b5@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

I did not tested this feature.  I have build it and flashed on hardware.
You can check below commit id. Which has similar check for ioremap.
1- Commit id - de9e397e40f56b9f34af4bf6a5bd7a75ea02456c
       In 'drivers/net/phy/mdio-octeon.c'

2- Commit id - 592569de4c247fe4f25db8369dc0c63860f9560b
       In 'drivers/gpio/gpio-octeon.c'

Thanks
Arvind

On Thursday 15 December 2016 12:58 AM, David Daney wrote:
> On 12/14/2016 11:03 AM, Arvind Yadav wrote:
>> Here, If devm_ioremap will fail. It will return NULL.
>> Kernel can run into a NULL-pointer dereference.
>> This error check will avoid NULL pointer dereference. t
>
> I have asked you twice already this question, but could not determine 
> from your response what the answer is:
>
> Q: Have you tested the patch on OCTEON based hardware that contains 
> the "octeon_mgmt" Ethernet ports?  Please answer either "yes" or "no".
>
>
> Thanks,
> David Daney
>
>
>>
>> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
>> ---
>>  drivers/net/ethernet/cavium/octeon/octeon_mgmt.c | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c 
>> b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
>> index 4ab404f..33c2fec 100644
>> --- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
>> +++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
>> @@ -1479,6 +1479,12 @@ static int octeon_mgmt_probe(struct 
>> platform_device *pdev)
>>      p->agl = (u64)devm_ioremap(&pdev->dev, p->agl_phys, p->agl_size);
>>      p->agl_prt_ctl = (u64)devm_ioremap(&pdev->dev, p->agl_prt_ctl_phys,
>>                         p->agl_prt_ctl_size);
>> +    if (!p->mix || !p->agl || !p->agl_prt_ctl) {
>> +        dev_err(&pdev->dev, "failed to map I/O memory\n");
>> +        result = -ENOMEM;
>> +        goto err;
>> +    }
>> +
>>      spin_lock_init(&p->lock);
>>
>>      skb_queue_head_init(&p->tx_list);
>>
>
