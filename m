From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 10:00:15 -0700
Message-ID: <47ED241F.9080003@sun.com>
References: <47EC3182.7080005@sun.com>
 <20080327.170235.53674739.davem@davemloft.net> <47EC399E.90804@sun.com>
 <20080327.173418.18777696.davem@davemloft.net>
 <20080328012234.GA20465@gondor.apana.org.au> <47EC50BA.6080908@sun.com>
 <1206700389.4429.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:44036 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319AbYC1RBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 13:01:46 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m2SH1jQB016547
	for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 10:01:45 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JYG001019QB3D00@fe-sfbay-09.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Fri,
 28 Mar 2008 10:01:45 -0700 (PDT)
In-reply-to: <1206700389.4429.34.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Thu, 2008-27-03 at 18:58 -0700, Matheos Worku wrote:
>
>   
>> In general, while the TX serialization  improves performance in terms to 
>> lock contention, wouldn't it reduce throughput since only one guy is 
>> doing the actual TX at any given time.  Wondering if it would be 
>> worthwhile to have an  enable/disable option specially for multi queue TX.
>>     
>
> Empirical evidence so far says at some point the bottleneck is going to
> be the wire i.e modern CPUs are "fast enough" that sooner than later
> they will fill up the DMA ring of transmitting driver and go back to
> doing other things. 
>   

> It is hard to create the condition you seem to have come across. I had access to a dual core opteron but found it very hard with parallel UDP
> sessions to keep the TX CPU locked in that region (while the other 3
> were busy pumping packets). My folly could have been that i had a Gige
> wire and maybe a 10G would have recreated the condition. 
> If you can reproduce this at will, can you try to reduce the number of
> sending TX u/iperfs and see when it begins to happen?
> Are all the iperfs destined out of the same netdevice?
>   
I am using 10G nic at this time. With the same driver, I haven't come 
across  the lockup on 1G nic though I haven't really tried to reproduce 
it.   Regarding the number of connection it takes to create the 
situation, I have noticed the lockup at 3 or more udp connections.  
Also, with TSO disabled, I have came across it with lots of TCP connections.


> [Typically the TX path on the driver side is inefficient either because
> of coding (ex: unnecessary locks) or expensive IO. But this has not
> mattered much thus far (given fast enough CPUs).
>   
That could be true  though oprofile is not providing obvious clues, 
alteast not yet.
> It all could be improved by reducing the per packet operations the
> driver incurs -  as an example, the CPU (to the driver) could batch a
> set of packet to the device then kick the device DMA once for the batch
> etc.]
>   
Regards
matheos

> cheers,
> jamal
>
>   

