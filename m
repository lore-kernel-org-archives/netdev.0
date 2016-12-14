From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [v2] net:ethernet:cavium:octeon:octeon_mgmt: Handle return NULL
 error from devm_ioremap
Date: Wed, 14 Dec 2016 10:14:54 -0800
Message-ID: <f113cad3-e368-679a-c56b-3c8c57e1a07b@caviumnetworks.com>
References: <1481732732-6892-1-git-send-email-arvind.yadav.cs@gmail.com>
 <3c3d5968-bc41-e1b7-6fda-78e92e7a9d56@caviumnetworks.com>
 <0be48286-2656-84b4-4cd8-93bea5fbc6f0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: arvind Yadav <arvind.yadav.cs@gmail.com>, <peter.chen@nxp.com>,
        <fw@strlen.de>, <david.daney@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0be48286-2656-84b4-4cd8-93bea5fbc6f0@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/14/2016 10:06 AM, arvind Yadav wrote:
> Yes, I have seen this error. We have a device with very less memory.
> Basically it's OMAP2 board. We have to port Android L on this.
> It's has 3.10 kernel version. In this device, we were getting Page
> allocation failure.

This makes absolutely no sense to me.  OCTEON is a mips64 SoC with a ton 
of memory where ioremap can never fail, and it doesn't run Android, and 
you are talking about OMAP2.

Q1: Have you observed a failure on the device for which you are 
modifying the driver?

Q2: Have you tested the patch on hardware that uses the driver you are 
modifying by running network traffic through the Ethernet interface this 
driver controls?

If you cannot answer yes to both of those questions, then you should 
probably note in the changelog that the patch is untested.

David.


> Vmalloc size was not enough to run all application. So we have decide to
> increase vmalloc reserve space. once we increases Vmalloc space.
> We start getting ioremap falilure. Kernel is getting NULL-pointer
> dereference error.
>
> Here, It's just check to avoid any kernel crash because of ioremap failure.
> We can keep this check to avoid this kind of scenario.
>
> Thanks
> -Arvind
>
>
> On Wednesday 14 December 2016 11:02 PM, David Daney wrote:
>> On 12/14/2016 08:25 AM, Arvind Yadav wrote:
>>> Here, If devm_ioremap will fail. It will return NULL.
>>> Kernel can run into a NULL-pointer dereference.
>>> This error check will avoid NULL pointer dereference.
>>>
>> i
>> Have you ever seen this failure in the wild?
>>
>> How was the patch tested?
>>
>> Thanks,
>> David Daney
>>
>>
>>> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
>>> ---
>>>  drivers/net/ethernet/cavium/octeon/octeon_mgmt.c | 6 ++++++
>>>  1 file changed, 6 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
>>> b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
>>> index 4ab404f..33c2fec 100644
>>> --- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
>>> +++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
>>> @@ -1479,6 +1479,12 @@ static int octeon_mgmt_probe(struct
>>> platform_device *pdev)
>>>      p->agl = (u64)devm_ioremap(&pdev->dev, p->agl_phys, p->agl_size);
>>>      p->agl_prt_ctl = (u64)devm_ioremap(&pdev->dev, p->agl_prt_ctl_phys,
>>>                         p->agl_prt_ctl_size);
>>> +    if (!p->mix || !p->agl || !p->agl_prt_ctl) {
>>> +        dev_err(&pdev->dev, "failed to map I/O memory\n");
>>> +        result = -ENOMEM;
>>> +        goto err;
>>> +    }
>>> +
>>>      spin_lock_init(&p->lock);
>>>
>>>      skb_queue_head_init(&p->tx_list);
>>>
>>
>
