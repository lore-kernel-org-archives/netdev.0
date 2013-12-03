From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4_core: destroy workqueue when driver fails to
 register
Date: Tue, 3 Dec 2013 09:36:34 +0800
Message-ID: <20131203013634.GA7485@weiyang.vnet.ibm.com>
References: <1385948684-7284-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <CAJZOPZLfiBR_ibMXpsec2U59hxoaqQoBVDOcGkr20mqtM5NYow@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:59213 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917Ab3LCBgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 20:36:43 -0500
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 3 Dec 2013 07:06:40 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 7309D1258051
	for <netdev@vger.kernel.org>; Tue,  3 Dec 2013 07:07:39 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB31aWUt53739704
	for <netdev@vger.kernel.org>; Tue, 3 Dec 2013 07:06:32 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB31aZsj020226
	for <netdev@vger.kernel.org>; Tue, 3 Dec 2013 07:06:35 +0530
Content-Disposition: inline
In-Reply-To: <CAJZOPZLfiBR_ibMXpsec2U59hxoaqQoBVDOcGkr20mqtM5NYow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 02, 2013 at 10:11:52PM +0200, Or Gerlitz wrote:
>On Mon, Dec 2, 2013 at 3:44 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>> When driver registration fails, we need to clean up the resources allocated
>> before. mlx4_core missed to destroy the workqueue allocated.
>
>please use "missed destroying" instead of "missed to destroy"
>
>>
>> This patch destroies the workqueue when registration fails.
>
>please s/destroies/destroys/

Ah, sorry for my poor English, will send another one.

>
>>
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/main.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>> index 5789ea2..01fc651 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>> @@ -2635,6 +2635,8 @@ static int __init mlx4_init(void)
>>                 return -ENOMEM;
>>
>>         ret = pci_register_driver(&mlx4_driver);
>> +       if (ret < 0)
>> +               destroy_workqueue(mlx4_wq);
>>         return ret < 0 ? ret : 0;
>>  }
>>
>> --
>> 1.7.5.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Richard Yang
Help you, Help me
