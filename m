From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: Fix a checksum issue on the receive path
Date: Fri, 08 Oct 2010 11:14:10 -0300
Message-ID: <4CAF2732.90703@linux.vnet.ibm.com>
References: <1286493453-21784-1-git-send-email-leitao@linux.vnet.ibm.com> <1286513130.6536.467.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:41586 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942Ab0JHOOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 10:14:20 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp05.br.ibm.com (8.14.4/8.13.1) with ESMTP id o98E8NUI021596
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 11:08:23 -0300
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o98EKSqN1069372
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 11:20:28 -0300
Received: from d24av03.br.ibm.com (loopback [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o98EEGd2018265
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 11:14:16 -0300
In-Reply-To: <1286513130.6536.467.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric

On 10/08/2010 01:45 AM, Eric Dumazet wrote:
> Just to be clear : packets with wrong checksums are not given to upper
> stack, so a tcpdump can not display them ? I am not sure many drivers do
> that.
Well, what my code does is: 1) if the current packet is a UDP/TCP, then 
the checksum is not necessary, since we would check the checksum on 
ehea_proc_rwqes(), specific at this part of the code:

                if (!ehea_check_cqe(cqe, &rq)) {
			// Send the packet to the up layers

And ehea_check_cqe() checks for wrong checksumed packets on:
	
         if ((cqe->status & EHEA_CQE_STAT_ERR_MASK) == 0)
                 return 0;


Botton line, TCP/UDP packets with wrong checksums are dropped by 
ehea_proc_rwqes(), others go to the up layer.

So, back to your question, you are saying that we shouldn't do that, 
meaning that we should send to the upper layers all packets ? even those 
that have the wrong checksum ?

Thanks
Breno
