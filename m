From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] iphase fix.
Date: Thu, 15 May 2003 02:43:10 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3EC336FE.1030805@pobox.com>
References: <200305150417.h4F4HTRA025809@hera.kernel.org> <3EC3359D.5050207@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: davej@codemonkey.org.uk
In-Reply-To: <3EC3359D.5050207@pobox.com>
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
>>          dev_kfree_skb(skb);
>> -    else
>> -        netif_wake_queue(dev);
>> +    netif_wake_queue(dev);
>>      LEAVE("iph5526_send_packet");
> 
> 
> 
> This appears to revert a fix.
> 
> You only want to wake the queue if you have room to queue another skb.


Actually, I'm wrong.

But it could still use some looking-at.  You don't want to stop_queue at 
the beginning of send_packet and wake_queue at the end.  Instead, the 
queue should be awakened in the Tx completion routine, and the 
stop_queue should be moved from the beginning to the end of the function.

	Jeff
