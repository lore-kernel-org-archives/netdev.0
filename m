From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Thu, 27 Mar 2008 18:58:18 -0700
Message-ID: <47EC50BA.6080908@sun.com>
References: <47EC3182.7080005@sun.com>
 <20080327.170235.53674739.davem@davemloft.net> <47EC399E.90804@sun.com>
 <20080327.173418.18777696.davem@davemloft.net>
 <20080328012234.GA20465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	jarkao2@gmail.com, netdev@vger.kernel.org, hadi@cyberus.ca
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:42363 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023AbYC1B7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 21:59:32 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m2S1xTFD013171
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 18:59:30 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JYF0020145PVJ00@fe-sfbay-10.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Thu,
 27 Mar 2008 18:59:29 -0700 (PDT)
In-reply-to: <20080328012234.GA20465@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Mar 27, 2008 at 05:34:18PM -0700, David Miller wrote:
>   
>> The first cpu will get into __qdisc_run(), but the other
>> ones will just q->enqueue() and exit since the first cpu
>> has indicated it is processing the qdisc.
>>     
>
> Indeed.  Since I created the problem it's only fair that I get
> to fix it too :)
>
> [NET]: Add preemption point in qdisc_run
>
> The qdisc_run loop is currently unbounded and runs entirely
> in a softirq.  This is bad as it may create an unbounded softirq
> run.
>
> This patch fixes this by calling need_resched and breaking out
> if necessary.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> Thanks,
>   
Great.

In general, while the TX serialization  improves performance in terms to 
lock contention, wouldn't it reduce throughput since only one guy is 
doing the actual TX at any given time.  Wondering if it would be 
worthwhile to have an  enable/disable option specially for multi queue TX.

Regards
Matheos

