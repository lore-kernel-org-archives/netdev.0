From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH v2 net] ravb: Remove clear unhandled interrupt
Date: Tue, 15 Dec 2015 01:30:14 +0900
Message-ID: <CAH1o70+eZbM1VqmKNb5UJEx2Jmjvr9RC=ojL4aCmpAsOLscUPg@mail.gmail.com>
References: <1450019545-32540-1-git-send-email-ykaneko0929@gmail.com>
	<566D9BFE.5010304@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <566D9BFE.5010304@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

2015-12-14 1:25 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
> On 12/13/2015 06:12 PM, Yoshihiro Kaneko wrote:
>
>    The subject doesn't seem to reflect what the patch is doing.
>
>
>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> AVB-DMAC Receive FIFO Warning interrupt is not enabled, so it is not
>> necessary to disable the interrupt in ndo_close().
>> On the other hand, this patch disables the interrupt in ndo_open() to
>> prevent the possibility that the interrupt is issued by the state that
>> a boot loader left.
>>
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>> ---
>>
>> This patch is based on the master branch of David Miller's networking
>> tree.
>>
>> v2 [Yoshihiro Kaneko]
>> * compile tested only
>> * As suggested by Sergei Shtylyov
>>    - clear RIC1 in ndo_open() to disable the interrupt regardless of
>>      a left state from a bootloader.
>>
>>
>>   drivers/net/ethernet/renesas/ravb_main.c | 4 +++-
>>   1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>> b/drivers/net/ethernet/renesas/ravb_main.c
>> index b69e0c2..5e34a88 100644
>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>> @@ -1228,6 +1228,9 @@ static int ravb_open(struct net_device *ndev)
>>                 goto out_free_irq2;
>>         ravb_emac_init(ndev);
>>
>> +       /* Disable unhandled interrupt */
>> +       ravb_write(ndev, 0, RIC1);
>> +
>
>
>    Oh, I thought the interrupt masks are programmed here but they are set in
> ravb_dmac_init() that this function calls. Please do it there instead (where
> it was originally done).

done.

>
> [...]
>
> MBR, Sergei
>

Thanks,
kaneko
