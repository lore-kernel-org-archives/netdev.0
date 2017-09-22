From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH net-next 01/10] net: hns3: Support for dynamically
 assigning tx buffer to TC
Date: Fri, 22 Sep 2017 09:57:31 +0800
Message-ID: <8babe541-9409-7f66-e52b-922144c46fb0@huawei.com>
References: <1505992913-107256-1-git-send-email-linyunsheng@huawei.com>
 <1505992913-107256-2-git-send-email-linyunsheng@huawei.com>
 <20170921.184102.278153022575280817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <salil.mehta@huawei.com>,
        <lipeng321@huawei.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170921.184102.278153022575280817.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, David

On 2017/9/22 9:41, David Miller wrote:
> From: Yunsheng Lin <linyunsheng@huawei.com>
> Date: Thu, 21 Sep 2017 19:21:44 +0800
> 
>> @@ -1324,23 +1324,28 @@ static int hclge_alloc_vport(struct hclge_dev *hdev)
>>  	return 0;
>>  }
>>  
>> -static int  hclge_cmd_alloc_tx_buff(struct hclge_dev *hdev, u16 buf_size)
>> +static int  hclge_cmd_alloc_tx_buff(struct hclge_dev *hdev)
>>  {
>>  /* TX buffer size is unit by 128 byte */
>>  #define HCLGE_BUF_SIZE_UNIT_SHIFT	7
>>  #define HCLGE_BUF_SIZE_UPDATE_EN_MSK	BIT(15)
>>  	struct hclge_tx_buff_alloc *req;
>> +	struct hclge_priv_buf *priv;
>>  	struct hclge_desc desc;
>> +	u32 buf_size;
>>  	int ret;
>>  	u8 i;
>>  
>>  	req = (struct hclge_tx_buff_alloc *)desc.data;
>>  
>>  	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_TX_BUFF_ALLOC, 0);
>> -	for (i = 0; i < HCLGE_TC_NUM; i++)
>> +	for (i = 0; i < HCLGE_TC_NUM; i++) {
>> +		priv = &hdev->priv_buf[i];
>> +		buf_size = priv->tx_buf_size;
>>  		req->tx_pkt_buff[i] =
>>  			cpu_to_le16((buf_size >> HCLGE_BUF_SIZE_UNIT_SHIFT) |

buf_size is used here

>>  				     HCLGE_BUF_SIZE_UPDATE_EN_MSK);
>> +	}
>>  
>>  	ret = hclge_cmd_send(&hdev->hw, &desc, 1);
>>  	if (ret) {
> 
> Local variable 'buf_size' is assigned but never used in this function.
> And with 'buf_size' removed, 'priv' also becomes unused.

> 
> If it gets used in a later patch, add it in that later patch.
> 
> You can also declare the variables locally in the basic block of
> the for() loop.

You are right. Will do it if there is more comment coming, thanks for
reviewing .

> 
> .
> 
