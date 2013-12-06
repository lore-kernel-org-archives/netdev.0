From: Yijing Wang <wangyijing@huawei.com>
Subject: Re: [PATCH 2/2] net/fddi: Replace local marco with PCI standard macro
Date: Fri, 6 Dec 2013 11:06:28 +0800
Message-ID: <52A13F34.2010403@huawei.com>
References: <1386243482-32856-1-git-send-email-wangyijing@huawei.com> <alpine.LFD.2.10.1312052154190.1599@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hanjun Guo <guohanjun@huawei.com>
To: "Maciej W. Rozycki" <macro@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.10.1312052154190.1599@eddie.linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/12/6 6:06, Maciej W. Rozycki wrote:
> On Thu, 5 Dec 2013, Yijing Wang wrote:
> 
>> Replace local marco DFX_BUS_PCI with PCI standard marco
>> dev_is_pci().
> 
>  Typos above: marco -> macro

Sorry for the mistake, David, should i need to resend this patch to fix this typo error?

> 
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> ---
>>  drivers/net/fddi/defxx.c |   20 +++++++-------------
>>  1 files changed, 7 insertions(+), 13 deletions(-)
>>
>> diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
>> index 0b40e1c..0344f71 100644
>> --- a/drivers/net/fddi/defxx.c
>> +++ b/drivers/net/fddi/defxx.c
>> @@ -241,12 +241,6 @@ static char version[] =
>>   */
>>  #define NEW_SKB_SIZE (PI_RCV_DATA_K_SIZE_MAX+128)
>>  
>> -#ifdef CONFIG_PCI
>> -#define DFX_BUS_PCI(dev) (dev->bus == &pci_bus_type)
>> -#else
>> -#define DFX_BUS_PCI(dev) 0
>> -#endif
>> -
>>  #ifdef CONFIG_EISA
>>  #define DFX_BUS_EISA(dev) (dev->bus == &eisa_bus_type)
>>  #else
>> @@ -436,7 +430,7 @@ static void dfx_port_read_long(DFX_board_t *bp, int offset, u32 *data)
>>  static void dfx_get_bars(struct device *bdev,
>>  			 resource_size_t *bar_start, resource_size_t *bar_len)
>>  {
>> -	int dfx_bus_pci = DFX_BUS_PCI(bdev);
>> +	int dfx_bus_pci = dev_is_pci(bdev);
>>  	int dfx_bus_eisa = DFX_BUS_EISA(bdev);
>>  	int dfx_bus_tc = DFX_BUS_TC(bdev);
>>  	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
> 
> Acked-by: Maciej W. Rozycki <macro@linux-mips.org>
> 
>   Maciej
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
> 


-- 
Thanks!
Yijing
