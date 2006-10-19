From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] [NET] Size listen hash tables using backlog hint
Date: Wed, 18 Oct 2006 21:54:08 -0700
Message-ID: <453704F0.4010707@osdl.org>
References: <45345999.4000300@psc.edu>	<20061016.223513.35356292.davem@davemloft.net>	<200610171458.37636.dada1@cosmosbay.com> <20061018.203109.63997999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39124 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030299AbWJSEyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 00:54:41 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061018.203109.63997999.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Eric Dumazet Hi <dada1@cosmosbay.com>
> Date: Tue, 17 Oct 2006 14:58:37 +0200
>
>   
>> reqsk_queue_alloc() goal is to use a power of two size for the whole
>> listen_sock structure, to avoid wasting memory for large backlogs,
>> meaning the hash table nr_table_entries is not anymore a power of
>> two. (Hence one AND (nr_table_entries - 1) must be replaced by
>> MODULO nr_table_entries)
>>     
>
> Modulus can be very expensive for some small/slow cpus.  Please round
> down to a power-of-2 instead of up if you think the wastage really
> matters.
>   

Reminds me, anyone know why GCC is too stupid to convert modulus of a 
constant power of 2
into a mask operation?

