From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH v2] sh_eth: Optimization for RX excess judgement
Date: Mon, 8 Dec 2014 21:16:19 +0900
Message-ID: <CAH1o70LYFfU6X1+01hfnmzoyNKEGTCNFrKbVzGPwPd7PJQ4o1w@mail.gmail.com>
References: <1418035701-3871-1-git-send-email-ykaneko0929@gmail.com>
	<54858FCD.3080206@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <54858FCD.3080206@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Sergei,

2014-12-08 20:47 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
> On 12/8/2014 1:48 PM, Yoshihiro Kaneko wrote:
>
>> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
>
>
>> Both of 'boguscnt' and 'quota' have nearly meaning as the condition of
>> the reception loop.
>> In order to cut down redundant processing, this patch changes excess
>> judgement.
>
>
>> Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>> ---
>
>
>> This patch is based on net-next tree.
>
>
>> v2 [Yoshihiro Kaneko]
>> * re-spin for net-next.
>> * remove unneeded check of "quota".
>
>
>    This is not a complete list. :-/

Sorry, I'll update on the next time.

>
>>   drivers/net/ethernet/renesas/sh_eth.c | 10 +++++-----
>>   1 file changed, 5 insertions(+), 5 deletions(-)
>
>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>> b/drivers/net/ethernet/renesas/sh_eth.c
>> index dbe8606..266c9b2 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>
> [...]
>>
>> @@ -1501,6 +1499,8 @@ static int sh_eth_rx(struct net_device *ndev, u32
>> intr_status, int *quota)
>>                 sh_eth_write(ndev, EDRRR_R, EDRRR);
>>         }
>>
>> +       *quota -= limit - boguscnt + 1;
>> +
>
>
>    Sorry for the wrong previous suggestion, it clearly should have been -1,
> not +1. :-<

Oh, I agree.

Thanks,
Kaneko

>
> [...]
>
> WBR, Sergei
>
