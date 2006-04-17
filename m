From: George Nychis <gnychis@cmu.edu>
Subject: Re: want to randomly drop packets based on percent
Date: Mon, 17 Apr 2006 19:04:33 -0400
Message-ID: <44441F01.5010002@cmu.edu>
References: <444345F9.4090100@cmu.edu>	<20060417091915.67e28361@localhost.localdomain>	<4444171B.90507@cmu.edu>	<20060417094634.7191fea5@localhost.localdomain>	<4443CAD1.9050701@cmu.edu> <20060417103211.24115952@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.andrew.cmu.edu ([128.2.10.81]:40621 "EHLO
	smtp.andrew.cmu.edu") by vger.kernel.org with ESMTP
	id S1751376AbWDQXEp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 19:04:45 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060417103211.24115952@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Stephen Hemminger wrote:

>O
>  
>
>>>>>>I wanted to insert artificial packet loss based on a percent so i found:
>>>>>>network emulab qdisc could do it, so i compiled support into the kernel 
>>>>>>and tried:
>>>>>>tc qdisc change dev eth0 root netem loss .1%
>>>>>>       
>>>>>>
>>>>>>            
>>>>>>
>>>            ^^^^^^
>>>
>>>You need to do add not change. Add will set the queue discipline
>>>to netem (default is pfifo_fast).  Change is for changing netem parameters
>>>after it is loaded.
>>>
>>> 
>>>
>>>      
>>>
>>bahhh I see... the wiki has "change" instead of add.  Now i'm running 
>>into another problem, I have an XCP qdisc that I have already added via:
>>tc qdisc add dev ath0 root xcp capacity 54Mbit size 500
>>
>>    
>>
>
>Wiki reads as a set of examples.  First uses, "add" after that "change".
>
>
>  
>
>>therefore when I also try to incorperate loss:
>>tcq disc add dev ath0 root netem loss .1%
>>
>>I get:
>>RTNETLINK answers: File exists
>>
>>Is it possible to use two qdiscs on the same interface?
>>
>>    
>>
>
>No, but netem is "classful" so you can put xcp inside netem.
>Look at the token bucket example on the wiki.
>
>  
>
Okay I'm slightly confused... I would like to have the traffic  traverse 
both the XCP qdisc and the netem qdisc... looking through the wiki it 
shows me how to classify two sets of traffic, but how do i push all 
traffic through both?
