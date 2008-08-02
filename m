From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Sat, 02 Aug 2008 19:26:29 -0400
Message-ID: <4894ED25.6040200@hp.com>
References: <48929C5B.5030108@cn.fujitsu.com> <E1KOqf7-0004lB-00@gondolin.me.apana.org.au> <20080801.021825.51896743.davem@davemloft.net> <20080801092548.GA18424@gondor.apana.org.au> <20080801115041.GA19124@gondor.apana.org.au> <20080801131453.GA19851@gondor.apana.org.au> <489322A9.3080906@hp.com> <20080802003016.GA24295@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, yjwei@cn.fujitsu.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:14151 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbYHBX0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 19:26:34 -0400
In-Reply-To: <20080802003016.GA24295@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Aug 01, 2008 at 10:50:17AM -0400, Vlad Yasevich wrote:
>>> +	inet->pmtudisc = transport->param_flags & SPP_PMTUD_ENABLE ?
>>> +			 IP_PMTUDISC_DO : IP_PMTUDISC_DONT;
>> If you insist on doing this, you need to save the old value and restore
>> it after ip_queue_xmit(). 
>>
>> The reason is that PMTU discovery change on a specific transport or
>> association should not affect the socket, since there could be multiple
>> associations on a given socket.  Each association has it's own control.
> 
> Yes but they'll all pass through here so it'll get set to the
> appropriate value.
> 
> Cheers,

OK, I see what you mean.  Let me run some tests with this patch.  I doesn't
look like it will cause any issues, but I'd like to verify.

Thanks
-vlad
