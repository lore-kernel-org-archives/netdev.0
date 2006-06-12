From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH RFC] netpoll: don't spin forever sending to stopped queues
Date: Mon, 12 Jun 2006 13:57:58 -0700
Message-ID: <448DD556.6030705@goop.org>
References: <44886381.9050506@goop.org> <20060608210702.GD24227@waste.org> <4488D9D6.6070205@goop.org> <20060611200407.GG24227@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:27831 "EHLO mail.goop.org")
	by vger.kernel.org with ESMTP id S1751415AbWFLU6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 16:58:05 -0400
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20060611200407.GG24227@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> On Thu, Jun 08, 2006 at 07:15:50PM -0700, Jeremy Fitzhardinge wrote:
>   
>> Here's a patch.  I haven't tested it beyond compiling it, and I don't 
>> know if it is actually correct.  In this case, it seems pointless to 
>> spin waiting for an even which will never happen.  Should 
>> netif_poll_disable() cause netpoll_send_skb() (or something) to not even 
>> bother trying to send?  netif_poll_disable seems mysteriously simple to me.
>>
>>    J
>>     
>
> Did this work for you at all?
>   

No, it didn't appear to help; I get the same symptom.  I think fix is 
correct (in that its better than what was there before), but there's 
probably more going on in my case.  I haven't looked into it more deeply 
yet.  I suspect there's another netpoll code path which is spinning 
forever on an XOFFed queue.

>> When transmitting a skb in netpoll_send_skb(), only retry a limited
>> number of times if the device queue is stopped.
>>     
>
> Where limited = once?
>   

No, it reuses the existing retry logic.  It retries 20000 times with a 
50us pause between attempts, so up to a second.  This seems excessive to 
me; I don't know where those original numbers came from.  I tried 5000 
retries, but it didn't make any difference to my case.

    J
