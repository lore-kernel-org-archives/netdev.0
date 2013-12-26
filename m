From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v3 08/19] ozwpan: slight optimization of addr compare
Date: Thu, 26 Dec 2013 16:35:54 +0800
Message-ID: <52BBEA6A.40000@huawei.com>
References: <52BA50E9.1080203@huawei.com> <52BAB983.3090201@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Rupesh Gujare <rupesh.gujare@atmel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<devel@driverdev.osuosl.org>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BAB983.3090201@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/12/25 18:54, Sergei Shtylyov wrote:
> Hello.
> 
> On 25-12-2013 7:28, Ding Tianhong wrote:
> 
>> Use possibly more efficient ether_addr_equal
>> instead of memcmp.
> 
>> Cc: Rupesh Gujare <rupesh.gujare@atmel.com>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Cc: devel@driverdev.osuosl.org
>> Cc: linux-kernel@vger.kernel.org
>> Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>   drivers/staging/ozwpan/ozcdev.c  | 2 +-
>>   drivers/staging/ozwpan/ozproto.c | 5 +++--
>>   2 files changed, 4 insertions(+), 3 deletions(-)
> 
>> diff --git a/drivers/staging/ozwpan/ozcdev.c b/drivers/staging/ozwpan/ozcdev.c
>> index 6ce0af9..c363f66 100644
>> --- a/drivers/staging/ozwpan/ozcdev.c
>> +++ b/drivers/staging/ozwpan/ozcdev.c
>> @@ -448,7 +448,7 @@ int oz_cdev_start(struct oz_pd *pd, int resume)
>>       }
>>       spin_lock(&g_cdev.lock);
>>       if ((g_cdev.active_pd == NULL) &&
>> -        (memcmp(pd->mac_addr, g_cdev.active_addr, ETH_ALEN) == 0)) {
>> +        (ether_addr_equal(pd->mac_addr, g_cdev.active_addr))) {
> 
>    There's no point in enclosing function call into parens.
> 
> WBR, Sergei
> 

ok, thanks.

Regards
Ding
> 
> 
