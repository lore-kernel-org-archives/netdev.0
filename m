From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-2.6.26 2/2] Do not allocate unneeded memory for dev->priv
   alignment.
Date: Tue, 08 Apr 2008 12:42:27 +0400
Message-ID: <47FB2FF3.90104@openvz.org>
References: <47FA4C50.3080405@openvz.org> <47FA5D62.5040806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35981 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751553AbYDHITU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 04:19:20 -0400
In-Reply-To: <47FA5D62.5040806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Pavel Emelyanov wrote, On 04/07/2008 06:31 PM:
> ...
> 
>> ---
>>  net/core/dev.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 7aa0112..80e103a 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -4000,7 +4000,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
>>  	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
>>  		     (sizeof(struct net_device_subqueue) * (queue_count - 1))) &
>>  		     ~NETDEV_ALIGN_CONST;
>> -	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
>> +	if (sizeof_priv)
>> +		alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
>>  
>>  	p = kzalloc(alloc_size, GFP_KERNEL);
>>  	if (!p) {
> 
> 
> IMHO this second "+ NETDEV_ALIGN_CONST" is needed here because of "~NETDEV_ALIGN_CONST".

Hmm, AFAIC, the net_device alignment is done earlier, while this one
makes sense in case the priv pointer alignment.

> Regards,
> Jarek P.
> 

