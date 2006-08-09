From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH][IPV6]: Make sure fib6_rule_lookup doesn't return NULL
Date: Wed, 09 Aug 2006 09:31:15 +0300
Message-ID: <44D98133.8040707@tcs.hut.fi>
References: <44D90AA0.1000408@tcs.hut.fi>	<20060808221651.GS14627@postel.suug.ch> <20060808.164345.91207648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:33031 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1030546AbWHIGbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 02:31:16 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060808.164345.91207648.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Wed, 9 Aug 2006 00:16:51 +0200
> 
>> * Ville Nuorvala <vnuorval@tcs.hut.fi> 2006-08-09 01:05
>>>     [IPV6]: Make sure fib6_rule_lookup doesn't return NULL
>>>     
>>>     The callers of fib6_rule_lookup don't expect it to return NULL,
>>>     therefore it must return ip6_null_entry whenever fib_rule_lookup fails.
>>>     
>>>     Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
>> I think it would be a lot cleaner to return an error code
>> like fib_lookup() and save the atomic operations. We only
>> destroy the dst again anyway in case of a failure.
> 
> Yes, the current scheme is a poor substitute for IS_ERR/PTR_ERR.

But the ip6_null_entry not always discarded after a failed route lookup!
On a forwarding router it triggers the ICMPv6 Destination Unreachable
message to the sender.

Regards,
Ville
