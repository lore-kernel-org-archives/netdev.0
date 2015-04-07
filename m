From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] netfilter: Pass socket pointer down through okfn().
Date: Tue, 07 Apr 2015 11:59:34 -0400 (EDT)
Message-ID: <20150407.115934.1965685795824815835.davem@davemloft.net>
References: <20150405.221904.606225054570296194.davem@davemloft.net>
	<1428417869.2928.1.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	pablo@netfilter.org, jiri@resnulli.us
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754107AbbDGP7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 11:59:36 -0400
In-Reply-To: <1428417869.2928.1.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 07 Apr 2015 16:44:29 +0200

> On So, 2015-04-05 at 22:19 -0400, David Miller wrote:
>> --- a/include/linux/netfilter.h
>> +++ b/include/linux/netfilter.h
>> @@ -54,7 +54,7 @@ struct nf_hook_state {
>>  	struct net_device *in;
>>  	struct net_device *out;
>>  	struct sock *sk;
>> -	int (*okfn)(struct sk_buff *);
>> +	int (*okfn)(struct sock *, struct sk_buff *);
>>  };
> 
> If we give okfn the signature int (*okfn)(struct nf_hook_state *); then
> we would not need to touch anything else to enhance this.
> 
> What do you think?

We do not want nf_hook_state being an argument for non-netfilter output
functions in the various protocols.

So this is a terrible idea.
