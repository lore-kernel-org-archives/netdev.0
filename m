From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH V2 net 03/20] net/ena: fix queues number calculation
Date: Mon, 5 Dec 2016 20:25:30 +0200
Message-ID: <73d7e724-c251-ff46-49f1-4525478b7bb5@annapurnalabs.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
 <1480857578-5065-4-git-send-email-netanel@annapurnalabs.com>
 <20161205041130.GD4310@u54ee753d2d1854bda401.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org, dwmw@amazon.com, zorik@annapurnalabs.com,
        alex@annapurnalabs.com, saeed@annapurnalabs.com, msw@amazon.com,
        aliguori@amazon.com, nafea@annapurnalabs.com
To: Matt Wilson <msw@amzn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f180.google.com ([209.85.210.180]:34812 "EHLO
        mail-wj0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751573AbcLESZf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:25:35 -0500
Received: by mail-wj0-f180.google.com with SMTP id tg4so42860490wjb.1
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 10:25:34 -0800 (PST)
In-Reply-To: <20161205041130.GD4310@u54ee753d2d1854bda401.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/05/2016 06:11 AM, Matt Wilson wrote:
> On Sun, Dec 04, 2016 at 03:19:21PM +0200, Netanel Belgazal wrote:
>> The ENA driver tries to open a queue per vCPU.
>> To determine how many vCPUs the instance have it uses num_possible_cpus
>> while it should have use num_online_cpus instead.
> use () when referring to functions: num_possible_cpus(), num_online_cpus().

Ack
>
>> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> Reviewed-by: Matt Wilson <msw@amazon.com>
>
>> ---
>>   drivers/net/ethernet/amazon/ena/ena_netdev.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
>> index 397c9bc..224302c 100644
>> --- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
>> +++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
>> @@ -2667,7 +2667,7 @@ static int ena_calc_io_queue_num(struct pci_dev *pdev,
>>   		io_sq_num = get_feat_ctx->max_queues.max_sq_num;
>>   	}
>>   
>> -	io_queue_num = min_t(int, num_possible_cpus(), ENA_MAX_NUM_IO_QUEUES);
>> +	io_queue_num = min_t(int, num_online_cpus(), ENA_MAX_NUM_IO_QUEUES);
>>   	io_queue_num = min_t(int, io_queue_num, io_sq_num);
>>   	io_queue_num = min_t(int, io_queue_num,
>>   			     get_feat_ctx->max_queues.max_cq_num);
