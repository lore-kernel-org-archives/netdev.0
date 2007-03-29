From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: netpoll question
Date: Wed, 28 Mar 2007 18:08:08 -0700
Message-ID: <460B1178.9070701@osdl.org>
References: <1175119380.28767.4.camel@stevo-laptop>	 <460AFA3B.6090009@mvista.com> <1175130033.28767.19.camel@stevo-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>, netdev@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42645 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753214AbXC2EiR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 00:38:17 -0400
In-Reply-To: <1175130033.28767.19.camel@stevo-laptop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> On Wed, 2007-03-28 at 16:28 -0700, Mark Huth wrote:
>   
>> Steve Wise wrote:
>>     
>>> Hey all,
>>>
>>> I have netpoll question.  How does netpoll work with MSI/X, NAPI, and
>>> nics that setup multiple RSS style receive queues for a single port?
>>> >From what I can tell, if you're doing something like netdump using
>>> netpoll for IO, then you might never process incoming packets that get
>>> posted to the rx queues not associated with the main netdevice structure
>>> because netpoll only calls the poll() function for the main netdev
>>> struct.  Not the dummy netdevs setup for multiple rx queues.  
>>>
>>> Is this the case or am I confused?
>>>
>>> Thanks,
>>>
>>>
>>> Steve
>>>       
>> You are correct.  Netpoll needs a bit of work, especially on the receive 
>> side, for multi-queue and some other possible problems related to taking 
>> locks when the system is frozen.  If I get some time soon, I'm going to 
>> propose an overhaul to address some of these issues that show up in the 
>> kgdboe and netdump cases.
>>
>> Mark Huth
>>     
>
> Hey Mark,
>
> What are your thoughts on how to implement this?  
>
> Scrub every softnet_data queue->poll_list for every cpu?  Or perhaps its
> better to have a new function ptr off the netdev that sez "poll all rx
> queues"?
>
>   
The existing netpoll needs a complete redesign. Perhaps a separate hook into
a slow true polled mode in the hardware, as it is now it causes all sort 
of semantic
assumptions, that high speed network drivers need, to be violated.

Given that the only users of netpoll are kgdb and netdump (both not in 
mainline),
there is less effort to work on it.

