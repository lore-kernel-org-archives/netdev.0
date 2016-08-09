From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH v2 05/14] net: ethernet: ti: cpsw: don't check slave num
 in runtime
Date: Tue, 9 Aug 2016 15:08:38 +0300
Message-ID: <27ec9c9d-a0f4-ebeb-0d59-6f0e4ca5eead@linaro.org>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470480524-6851-6-git-send-email-ivan.khoronzhuk@linaro.org>
 <aa96e076-f5a9-df65-bf7e-e4b02df0a210@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <aa96e076-f5a9-df65-bf7e-e4b02df0a210@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 09.08.16 14:34, Grygorii Strashko wrote:
> On 08/06/2016 01:48 PM, Ivan Khoronzhuk wrote:
>> No need to check const slave num in runtime for every packet,
>> and ndev for slaves w/o ndev is anyway NULL. So remove redundant
>> check.
>>
>> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
>> ---
>>  drivers/net/ethernet/ti/cpsw.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index 70a9570..19aa4bb 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -498,8 +498,7 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
>>  				(func)(slave++, ##arg);			\
>>  	} while (0)
>>  #define cpsw_get_slave_ndev(priv, __slave_no__)				\
>> -	((__slave_no__ < priv->data.slaves) ?				\
>> -		priv->slaves[__slave_no__].ndev : NULL)
>> +		priv->slaves[__slave_no__].ndev
>
> So after this change it will be
> #define cpsw_get_slave_ndev(priv, __slave_no__) priv->slaves[__slave_no__].ndev
>
> Can we just drop cpsw_get_slave_ndev() macro?
Sure. Will drop it in v3.

>
>>  #define cpsw_get_slave_priv(priv, __slave_no__)				\
>>  	(((__slave_no__ < priv->data.slaves) &&				\
>>  		(priv->slaves[__slave_no__].ndev)) ?			\
>>
>
>

-- 
Regards,
Ivan Khoronzhuk
