From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tipc: Don't use iocb argument in socket
 layer
Date: Sat, 28 Feb 2015 16:59:47 -0500 (EST)
Message-ID: <20150228.165947.531668369319195087.davem@davemloft.net>
References: <1425035198-12547-1-git-send-email-ying.xue@windriver.com>
	<1425035198-12547-2-git-send-email-ying.xue@windriver.com>
	<A2BAEFC30C8FD34388F02C9B3121859D1C399393@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, viro@ZenIV.linux.org.uk, hch@lst.de,
	netdev@vger.kernel.org, erik.hugne@ericsson.com
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbbB1V7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 16:59:49 -0500
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D1C399393@eusaamb103.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 27 Feb 2015 13:30:40 +0000

>> struct socket *sock,
>>  			struct msghdr *m, size_t dsz)
>>  {
>> +	struct sock *sk = sock->sk;
>> +	int ret;
> 
> alternative method: 
> 
>                 bool has_lock = false;
>> +

Conditional locking inside of a function is always very
strongly discouraged.

Every function should have static, simple, consistent locking
requirements and side effects across calls.
