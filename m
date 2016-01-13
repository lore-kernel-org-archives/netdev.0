From: Weidong Wang <wangweidong1@huawei.com>
Subject: Re: bgmac: fix a missing check for build_skb
Date: Wed, 13 Jan 2016 19:31:59 +0800
Message-ID: <569635AF.4070204@huawei.com>
References: <5695BF41.2040002@huawei.com> <1452674087.4516.3.camel@redhat.com> <5696262D.3040803@huawei.com> <56962DAF.9040807@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paolo Abeni <pabeni@redhat.com>,
	David Miller <davem@davemloft.net>, <zajec5@gmail.com>,
	<hauke@hauke-m.de>, Joe Perches <joe@perches.com>,
	<peter.senna@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56962DAF.9040807@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/1/13 18:57, Felix Fietkau wrote:
> On 2016-01-13 11:25, Weidong Wang wrote:
>> On 2016/1/13 16:34, Paolo Abeni wrote:
>>> On Wed, 2016-01-13 at 11:06 +0800, Weidong Wang wrote:
>>>> when build_skb failed, it may occure a NULL pointer.
>>>> So add a 'NULL check' for it.
>>>>
>>>> Signed-off-by: Weidong Wang <wangweidong1@huawei.com>
>>>> ---
>>>>  drivers/net/ethernet/broadcom/bgmac.c | 5 +++++
>>>>  1 file changed, 5 insertions(+)
>>>>
>>>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
>>>> index 21e3c38..d75180a 100644
>>>> --- a/drivers/net/ethernet/broadcom/bgmac.c
>>>> +++ b/drivers/net/ethernet/broadcom/bgmac.c
>>>> @@ -466,6 +466,11 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
>>>>  			len -= ETH_FCS_LEN;
>>>>
>>>>  			skb = build_skb(buf, BGMAC_RX_ALLOC_SIZE);
>>>> +			if (unlikely(skb)) {
>>>
>>> Should that be instead:
>>>
>>> if (unlikely(!skb)) {
>>>
>>> ?
>>>
>>
>> What to instead of it?
> Your patch has a logic error (missing the !), and it's breaking the
> ethernet driver completely instead of fixing anything.
> Did you even test this?
> 

Yep, you are right.
Sorry for that.
I just review the source code without any test.
I should resent it again.

> Dave, why did you apply this patch so fast without any chance of review?
> 
> - Felix
> 
> .
> 

Regards,
Weidong
