From: Juergen Gross <jgross@suse.com>
Subject: Re: [PATCH 1/2] xen/netfront: set default upper limit of tx/rx queues
 to 8
Date: Tue, 10 Jan 2017 16:02:44 +0100
Message-ID: <beec31a2-94a4-8244-ab4b-806773645976@suse.com>
References: <20170110133252.5346-1-jgross@suse.com>
 <20170110133252.5346-2-jgross@suse.com>
 <3ae4da4f-6a6a-db95-67a3-c0fba5524df1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, paul.durrant@citrix.com
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49088 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932881AbdAJPCs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 10:02:48 -0500
In-Reply-To: <3ae4da4f-6a6a-db95-67a3-c0fba5524df1@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/17 15:53, Boris Ostrovsky wrote:
> On 01/10/2017 08:32 AM, Juergen Gross wrote:
>> The default for the number of tx/rx queues of one interface is the
>> number of vcpus of the system today. As each queue pair reserves 512
>> grant pages this default consumes a ridiculous number of grants for
>> large guests.
>>
>> Limit the queue number to 8 as default. This value can be modified
>> via a module parameter if required.
>>
>> Signed-off-by: Juergen Gross <jgross@suse.com>
>> ---
>>  drivers/net/xen-netfront.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>> index a479cd9..490c865 100644
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
>> @@ -57,6 +57,7 @@
>>  #include <xen/interface/grant_table.h>
>>  
>>  /* Module parameters */
>> +#define MAX_QUEUES_DEFAULT 8
>>  static unsigned int xennet_max_queues;
>>  module_param_named(max_queues, xennet_max_queues, uint, 0644);
>>  MODULE_PARM_DESC(max_queues,
>> @@ -2164,11 +2165,12 @@ static int __init netif_init(void)
>>  
>>  	pr_info("Initialising Xen virtual ethernet driver\n");
>>  
>> -	/* Allow as many queues as there are CPUs if user has not
>> +	/* Allow as many queues as there are CPUs inut max. 8 if user has not
> 
> Based on comment change in the second patch: s/inut/but/ ? Also, comment
> style in both patches.

Typo: yes
Style: no. checkpatch tells me that the net directory doesn't follow
common kernel style.

> 
> Other than that, for both:
> 
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>

Thanks,

Juergen
