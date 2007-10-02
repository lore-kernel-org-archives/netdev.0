From: Ben Greear <greearb@candelatech.com>
Subject: Re: How do queue-less virtual devices wake higher level senders?
Date: Mon, 01 Oct 2007 17:24:26 -0700
Message-ID: <47018FBA.4030700@candelatech.com>
References: <47018772.4060803@candelatech.com> <20071001.170410.40806513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:45048 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752149AbXJBAY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 20:24:28 -0400
In-Reply-To: <20071001.170410.40806513.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Mon, 01 Oct 2007 16:49:06 -0700
> 
>> For 'real' hardware, it seems that the netif_stop_queue and
>> netif_wake_queue methods handle stopping and waking the
>> higher level senders, but for virtual devices with no
>> queues, how does this work?
> 
> They don't queue, there is nothing to stop or wakeup.

Ok, so if I have a UDP socket bound to an interface that has
no queue, and yet I see the send portion of the queue being
full in netstat, what does this mean?

Maybe the device I think has no queue somehow does?

I added some debugging to print out dev->state in sysfs, and
the state of the virtual is always 0x6, which appears right
to me.  It's underlying device goes back and forth between 0x7 and 0x6,
which also seems right to me.

When the thing is in the hung state, phys and virtual interface have 0x6
state, and yet the udp tx queue remains full.  The physical NIC also
prints out some errors about being low on buffers right before the
hang, but it seems to recover since just doing a ping or starting
a second udp connection brings everything back to life.

Other than IFF_UP and dev->state, are there other things that
can make the tx logic stop sending to a device?

Thanks,
Ben


> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

