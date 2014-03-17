From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] sh_eth: ensure pm_runtime cannot suspend the device during
 init
Date: Mon, 17 Mar 2014 13:07:12 +0000
Message-ID: <5326F380.2000106@codethink.co.uk>
References: <1395056275-5005-1-git-send-email-ben.dooks@codethink.co.uk> <5326F215.7010604@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5326F215.7010604@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/03/14 13:01, Sergei Shtylyov wrote:
> Hello.
>
> On 17-03-2014 15:37, Ben Dooks wrote:
>
>> The pm_rumtime work queue is causing the device to be suspended during
>> initialisation, thus the initialisation may not be able to access
>> registers
>> properly. As the code is called from a work queue, it is possible that
>> this
>> is not seen from certain configurations/builds due to the asynchronos
>> nature of the code.
>
>> Use pm_runtime_get_sync() and pm_runtime_put_sync() to ensure that the
>> pm system does not suspend it during the probe() call and remove the
>> now unnecessary pm_runtime_resume() call.
>
>> This fixes the external abort that can cause /sbin/init or other such
>> init processed to die.
>
>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>> Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
>> ---
>>   drivers/net/ethernet/renesas/sh_eth.c | 3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>> b/drivers/net/ethernet/renesas/sh_eth.c
>> index 4f76b5e..f1cfd64 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
>> @@ -2961,6 +2961,7 @@ static int sh_eth_drv_probe(struct
>> platform_device *pdev)
>>       pr_info("Base address at 0x%x, %pM, IRQ %d.\n",
>>           (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
>>
>> +    pm_runtime_put_sync(&pdev->dev);
>
>     I think you forgot to also do that on error cleanup path.
>
>>       platform_set_drvdata(pdev, ndev);
>>
>>       return ret;
>
> WBR, Sergei

Thanks, will check this.



-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
