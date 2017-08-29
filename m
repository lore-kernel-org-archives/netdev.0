From: =?gb2312?B?0c+6o8ur?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH] be2net: Fix some u16 fields appropriately
Date: Tue, 29 Aug 2017 09:04:57 +0800
Message-ID: <979AB2E6-7D90-4C6B-B43F-1D17EE621D05@cmss.chinamobile.com>
References: <1503818685-32068-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <20170828.161924.1286298670313299855.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: 8BIT
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828.161924.1286298670313299855.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On 2017年8月29日, at 上午7:19, David Miller <davem@davemloft.net> wrote:
> 
> From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> Date: Sun, 27 Aug 2017 15:24:45 +0800
> 
>> In be_tx_compl_process, frag_index declared as u32, so it's better to
>> declare last_index as u32 also.
>> 
>> CC: Ajit Khaparde <ajit.khaparde@broadcom.com>
>> Fixes: b0fd2eb28bd4 ("be2net: Declare some u16 fields as u32 to improve
>> performance")
>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> 
> That is not a legitimate reason for making this change.
> 
>> @@ -255,7 +255,7 @@ struct be_tx_stats {
>> /* Structure to hold some data of interest obtained from a TX CQE */
>> struct be_tx_compl_info {
>> 	u8 status;		/* Completion status */
>> -	u16 end_index;		/* Completed TXQ Index */
>> +	u32 end_index;		/* Completed TXQ Index */
>> };
>> 
>> struct be_tx_obj {
> 
> The ->end_index comes solely from:
> 
> 	txcp->end_index = GET_TX_COMPL_BITS(wrb_index, compl);
> 
> Which is precisely a 16-bit value.
> 
> I'm not applying this, sorry.
> 

Hi David,

The GET_TX_COMPL_BITS comes from amap_get which also returns a 32-bit value:

  6 static inline u32 amap_get(void *ptr, u32 dw_offset, u32 mask, u32 offset)
  5 {
  4     u32 *dw = (u32 *) ptr;
  3     return mask & (*(dw + dw_offset) >> offset);
  2 }
  1
869 #define AMAP_GET_BITS(_struct, field, ptr)              \
  1         amap_get(ptr,                       \
  2             offsetof(_struct, field)/32,            \
  3             amap_mask(sizeof(((_struct *)0)->field)),   \
  4             AMAP_BIT_OFFSET(_struct, field))
