From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 1/1] icmp: icmp_sk() should not use smp_processor_id()
 in preemptible code
Date: Sat, 23 Aug 2008 11:12:46 +0200
Message-ID: <48AFD48E.6050109@fr.ibm.com>
References: <20080821122040.GA2497@x200.localdomain> <1219413273-14281-1-git-send-email-den@openvz.org> <48AF4879.9070005@fr.ibm.com> <20080823004849.GA9678@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	adobriyan@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:53929 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbYHWJM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 05:12:57 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m7N9CtlG302074
	for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 09:12:55 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7N9CtFh2986102
	for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 11:12:55 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7N9CqB1027568
	for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 11:12:52 +0200
In-Reply-To: <20080823004849.GA9678@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Aug 23, 2008 at 01:15:05AM +0200, Daniel Lezcano wrote:
>> thanks for the fix. For my personal knowledge, why can we just use in 
>> the icmp_sk function:
>> 	{
>> 		struct sock *isk = net->ipv4.icmp_sk[get_cpu()];
>> 		put_cpu();
>> 		return isk;
>> 	}
>>
>> ?
> 
> Because then you can get rescheduled to another CPU while still
> using someone else's ICMP socket.

Obviously :)
Thanks Herbert.
