From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH net-next] net-next/hinic: Fix MTU limitation
Date: Thu, 24 Aug 2017 19:41:21 +0300
Message-ID: <7e45a728-0f65-a193-5df1-d49da704f40a@huawei.com>
References: <1503580885-35180-1-git-send-email-aviad.krawczyk@huawei.com>
 <20170824151958.GL8022@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <zhaochen6@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824151958.GL8022@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/24/2017 6:19 PM, Andrew Lunn wrote:
> On Thu, Aug 24, 2017 at 09:21:25PM +0800, Aviad Krawczyk wrote:
>> Fix the hw MTU limitation by setting min/max_mtu
>>
>> Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
>> Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
>> ---
>>  drivers/net/ethernet/huawei/hinic/hinic_main.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
>> index ae7ad48..7a14963 100644
>> --- a/drivers/net/ethernet/huawei/hinic/hinic_main.c
>> +++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
>> @@ -980,6 +980,9 @@ static int nic_dev_init(struct pci_dev *pdev)
>>  	hinic_hwdev_cb_register(nic_dev->hwdev, HINIC_MGMT_MSG_CMD_LINK_STATUS,
>>  				nic_dev, link_status_event_handler);
>>  
>> +	netdev->min_mtu = ETH_MIN_MTU;
> 
> You don't need to set the min_mtu. See:
> 
> http://elixir.free-electrons.com/linux/latest/source/net/ethernet/eth.c#L354
> 
> 	Andrew
> 
> .
> 

Thanks for paying attention to this unuseful line, I don't need to set min mtu.
I added it by mistake, the target was to change the MTU limitation.
I will send the patch soon without this line(in few days, after we will test it)
