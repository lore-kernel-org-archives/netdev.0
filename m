From: l00371289 <linyunsheng@huawei.com>
Subject: Re: [PATCH NET] net/hns:bugfix of ethtool -t phy self_test
Date: Tue, 20 Jun 2017 11:18:48 +0800
Message-ID: <f526345d-b0a4-1c45-8472-81c6c548950c@huawei.com>
References: <1497605091-94725-1-git-send-email-linyunsheng@huawei.com>
 <7500513f-e263-838c-12a1-4343f7281f1a@gmail.com>
 <20170619215435.GA13704@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <huangdaode@hisilicon.com>,
        <xuwei5@hisilicon.com>, <liguozhu@hisilicon.com>,
        <Yisen.Zhuang@huawei.com>, <gabriele.paoloni@huawei.com>,
        <john.garry@huawei.com>, <linuxarm@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <yankejian@huawei.com>, <tremyfr@gmail.com>,
        <xieqianqian@huawei.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619215435.GA13704@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Andrew

On 2017/6/20 5:54, Andrew Lunn wrote:
> On Mon, Jun 19, 2017 at 02:00:43PM -0700, Florian Fainelli wrote:
>> On 06/16/2017 02:24 AM, Lin Yun Sheng wrote:
>>> This patch fixes the phy loopback self_test failed issue. when
>>> Marvell Phy Module is loaded, it will powerdown fiber when doing
>>> phy loopback self test, which cause phy loopback self_test fail.
>>>
>>> Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
>>> ---
>>>  drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 16 ++++++++++++++--
>>>  1 file changed, 14 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
>>> index b8fab14..e95795b 100644
>>> --- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
>>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
>>> @@ -288,9 +288,15 @@ static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
>>
>> The question really is, why is not this properly integrated into the PHY
>> driver and PHYLIB such that the only thing the Ethernet MAC driver has
>> to call is a function of the PHY driver putting it in self-test?
> 
> This whole driver pokes various PHY registers, rather than use
> phylib. And it does so without taking the PHY lock. 
I will consider using phylib as much as possible, thanks.

It also assumes it
> is a Marvell PHY and i don't see anywhere it actually verifies this.
When it said Marvell Phy , I meant Marvell Phy with fibre support.
I will send anther patch to only setting bit in Fiber Control when
it is a Marvell Phy with fibre support.

Thanks for reply.
Best Regards
Yunsheng Lin
> 
> This is all broken.
> 
>      Andrew
> 
> .
> 
