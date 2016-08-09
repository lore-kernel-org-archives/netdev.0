From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH v2 02/14] net: ethernet: ti: cpsw: remove redundant check
 in napi poll
Date: Tue, 9 Aug 2016 15:10:02 +0300
Message-ID: <dbdd5e2d-8aef-34e4-2ef5-1a35edadbf2c@linaro.org>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470480524-6851-3-git-send-email-ivan.khoronzhuk@linaro.org>
 <c3f81cb3-2a1c-89e5-b2f0-a67e220fb5ca@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c3f81cb3-2a1c-89e5-b2f0-a67e220fb5ca@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 09.08.16 14:29, Grygorii Strashko wrote:
> On 08/06/2016 01:48 PM, Ivan Khoronzhuk wrote:
>> No need to check number of handled packets, when in most cases (> 99%)
>> it's not 0. It can be 0 only in rare cases, even in this case
>> it's not bad to print just 0.
>>
>> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
>> ---
>>  drivers/net/ethernet/ti/cpsw.c | 8 ++------
>>  1 file changed, 2 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index 8972bf6..85ee9f5 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -793,9 +793,7 @@ static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
>>  		}
>>  	}
>>
>> -	if (num_tx)
>> -		cpsw_dbg(priv, intr, "poll %d tx pkts\n", num_tx);
>> -
>> +	cpsw_dbg(priv, intr, "poll %d tx pkts\n", num_tx);
>
> I think, this dbg log can be just dropped as it seems not very useful.
> This also will allow to drop patch [PATCH v2 12/14] net: ethernet: ti: cpsw: fix int dbg message
That was my first thought, but I worried about someone can use it.
If no one has objection, I'll drop the patch 12 and delete "poll" print at all.

>
>>  	return num_tx;
>>  }
>>
>> @@ -814,9 +812,7 @@ static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
>>  		}
>>  	}
>>
>> -	if (num_rx)
>> -		cpsw_dbg(priv, intr, "poll %d rx pkts\n", num_rx);
>> -
>> +	cpsw_dbg(priv, intr, "poll %d rx pkts\n", num_rx);
>
> Same here.
>
>>  	return num_rx;
>>  }
>>
>>
>
>

-- 
Regards,
Ivan Khoronzhuk
