From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 2/3] tcp: Initial repair mode
Date: Thu, 29 Mar 2012 13:53:25 +0400
Message-ID: <4F743115.4000600@parallels.com>
References: <4F732FE1.9040906@parallels.com>  <4F73302C.9030209@parallels.com> <1332967158.2624.42.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:24575 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932559Ab2C2Jxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2012 05:53:36 -0400
In-Reply-To: <1332967158.2624.42.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2012 12:39 AM, Ben Hutchings wrote:
> On Wed, 2012-03-28 at 19:37 +0400, Pavel Emelyanov wrote:
> [...]
>> * Ability to forcibly bind a socket to a port
>>
>> The sk->sk_reuse is set to 2 denoting, that the socket is question
>> should be bound as if all the others in the system are configured
>> with the SO_REUSEADDR option.
> 
> Shouldn't this constant be named?

Agree, I will fix this up.

> [...]
>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
> [...]
>> +	case TCP_REPAIR_QUEUE:
>> +		if (!tp->repair)
>> +			err = -EPERM;
>> +		else if (val <= TCP_QUEUES_NR)
> 
> Off-by-one.

Oops :( Thanks for noticing!

>> +			tp->repair_queue = val;
>> +		else
>> +			err = -EINVAL;
>> +		break;
> [...]
> 
