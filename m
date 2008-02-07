From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [RFC] [IPV4][IPV6][TCP] remove skb->dev NULL assignation in tcp_v[4|6]_rcv
 functions
Date: Thu, 07 Feb 2008 12:56:59 +0100
Message-ID: <47AAF20B.1090705@fr.ibm.com>
References: <47AAE8C7.9090109@fr.ibm.com> <20080207.034525.74982838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:27010 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755384AbYBGMDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 07:03:03 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m17C2jQ1160530
	for <netdev@vger.kernel.org>; Thu, 7 Feb 2008 12:02:45 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m17C2jSf2330814
	for <netdev@vger.kernel.org>; Thu, 7 Feb 2008 13:02:45 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m17C2iph010597
	for <netdev@vger.kernel.org>; Thu, 7 Feb 2008 13:02:45 +0100
In-Reply-To: <20080207.034525.74982838.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> Date: Thu, 07 Feb 2008 12:17:27 +0100
> 
>> Subject: [RFC] remove skb->dev NULL assignation
>>
>> I was trying to figure out why in the tcp_v4_rcv/tcp_v6_rcv function,
>> the skb->dev field is set to NULL. There is certainly a good reason,
>> but I was not able to find it.
>>
>> Is it possible to remove this ?
>>
>> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> It is illegal to reference a device outside of the netif_receive_skb()
> code path without taking a reference to it.
> 
> Since we are queueing it to a socket, we have to NULL out the skb->dev
> since thee packets lifetime is being expanded outside of that allowed
> window.

Got it. Thank you very much.
