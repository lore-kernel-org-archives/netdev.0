From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: sctp use-uninitialized warning in net-2.6.25
Date: Fri, 18 Jan 2008 21:17:56 -0500
Message-ID: <47915DD4.7090109@hp.com>
References: <20080116135957.4eb54958.akpm@linux-foundation.org>	<20080118.044911.64979691.davem@davemloft.net>	<4790CDC8.6060000@hp.com> <20080118.153715.167557482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:21810 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758900AbYASCSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 21:18:04 -0500
In-Reply-To: <20080118.153715.167557482.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Fri, 18 Jan 2008 11:03:20 -0500
> 
>> We can do that, or move the declaration to the only block that uses it.
>> Like this:
>  ...
>> @@ -466,6 +465,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
>>  	if (!sctp_verify_init(asoc, chunk->chunk_hdr->type,
>>  			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
>>  			      &err_chunk)) {
>> +		sctp_error_t error;
>>  
>>  		SCTP_INC_STATS(SCTP_MIB_ABORTEDS);
>>
> 
> It's still potentially used uninitialized.
> 
> It will only get set if err_chunk is non-zero.
> 
> But even if err_chunk is zero, we try to use this
> variable.
> 
> That's the whole problem, simply moving the variable to
> a different scope is not going to fix anything.
> 

Hmm... in the code I am looking at, it's set in both zero and
non-zero cases so it does solve the issue.

So does initializing it to NO_ERROR like you did.

-vlad


