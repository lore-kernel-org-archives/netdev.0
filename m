From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 3/3] sock-diag: Report shutdown for inet and unix sockets
Date: Tue, 23 Oct 2012 21:53:02 +0400
Message-ID: <5086D97E.2060503@parallels.com>
References: <5086C36B.6060508@parallels.com>	<5086C5A6.7050101@parallels.com> <20121023.134236.1262093514433122608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:21758 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933131Ab2JWRxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 13:53:09 -0400
In-Reply-To: <20121023.134236.1262093514433122608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2012 09:42 PM, David Miller wrote:
> From: Pavel Emelyanov <xemul@parallels.com>
> Date: Tue, 23 Oct 2012 20:28:22 +0400
> 
>> +static inline int shutdown_mask2u(int mask)
>> +{
>> +	/*
>> +	 * map
>> +	 * 	RCV_SHUTDOWN -> SHUT_RD
>> +	 * 	SEND_SHUTDOWN -> SHUT_WR
>> +	 * 	SHUTDOWN_MASK -> SHUT_RDWR
>> +	 */
>> +
>> +	return mask - 1;
>> +}
> 
> This is horrible.
> 
> You're returning "-1" when the socket hasn't been shutdown in any way.
> 
> Do this:
> 
> 1) Use a '1' based encoding like the kernel codes so that '0' means
>    no shutdown, as any sane interface would.  That's why we use that
>    representation internally.
> 
> 2) Get rid of all of this extension crap, and just report this value
>    in the pad byte.  In older kernels it will just be zero, which is
>    fine.

The response message of inet-diag never had any pad bytes, I'll have to
add the new attrtype (the unix-diag response has one, but I plan to add
attrtype there too for uniformity).

Thanks,
Pavel
