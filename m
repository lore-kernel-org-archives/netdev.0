From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RFR: new SiS gige driver
Date: Wed, 13 Aug 2003 14:52:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F3A88DF.80205@pobox.com>
References: <20030808173932.GA4077@gtf.org> <20030809141533.GB4539@wotan.suse.de> <3F350CC8.3090605@pobox.com> <3F353925.3030106@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F353925.3030106@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Jeff Garzik wrote:
> 
>> Andi Kleen wrote:
>>
>>> * netif_stop_queue in hard_start_xmit is not protected against the 
>>> interrupt by the spinlock. That's racy, isn't it?
>>
>>
>>
>> Shouldn't be, if done right.  If the interrupt runs a TX completion 
>> cycle, it will run the code
>>     if (work_done && netif_queue_stopped(dev))
>>         netif_wake_queue(dev)
>>
> 
>> Since ->hard_start_xmit is guaranteed never to be called if the queue 
>> is stopped, you also guaranteed that netif_wake_queue and 
>> ->hard_start_xmit are mutually exclusive.
> 
> 
> Is this really guaranteed?  What if the queue is stopped between the check
> to see if it's stopped and the call to hard_start_xmit?


Actually, a slight correction (something I forgot):  the atomicity is 
provided by the bitops already so the netif_queue_stopped check isn't 
needed.

	Jeff
