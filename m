From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH][next] net: hinic: fix comparison of a uint16_t type with
 -1
Date: Thu, 24 Aug 2017 09:54:03 +0100
Message-ID: <d37c85d8-3954-e7b7-e569-f18c2b062966@canonical.com>
References: <20170823153936.22857-1-colin.king@canonical.com>
 <58f312cc-5f24-83b6-d12d-c66e4fd4dad2@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58f312cc-5f24-83b6-d12d-c66e4fd4dad2@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24/08/17 09:48, Aviad Krawczyk wrote:
> On 8/23/2017 6:39 PM, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> The comparison of hw_ioctxt.rx_buf_sz_idx == -1 is always false because
>> rx_buf_sz_idx is a uint16_t. Fix this by explicitly casting -1 to uint16_t.
>>
>> Detected by CoverityScan, CID#1454559 ("Operands don't affect result")
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>> ---
>>  drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
>> index 09dec6de8dd5..71e26070fb7f 100644
>> --- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
>> +++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
>> @@ -352,7 +352,7 @@ static int set_hw_ioctxt(struct hinic_hwdev *hwdev, unsigned int rq_depth,
>>  		}
>>  	}
>>  
>> -	if (hw_ioctxt.rx_buf_sz_idx == -1)
>> +	if (hw_ioctxt.rx_buf_sz_idx == (uint16_t)-1)
>>  		return -EINVAL;
>>  
>>  	hw_ioctxt.sq_depth  = ilog2(sq_depth);
>>
> 
> Many thanks, Colin.
> I prefer to avoid casting when possible, what do you think about replacing the condition by:
> 
> if (rx_buf_sz_table[i].sz != HINIC_RX_BUF_SZ)
> 	return -EINVAL;
> 

Does that work as expected when rx_buf_sz_table[i].sz == -1?
