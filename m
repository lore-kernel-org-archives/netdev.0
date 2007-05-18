From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [patch 2/7] CAN: Add PF_CAN core module
Date: Fri, 18 May 2007 11:19:01 +0200
Message-ID: <464D6F85.9090202@hartkopp.net>
References: <20070516145100.29877.0@janus.isnogud.escape.de> <20070516145121.29877.2@janus.isnogud.escape.de> <20070518005948.GA11737@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: paulmck@linux.vnet.ibm.com, Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:54668 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518AbXERJTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 05:19:52 -0400
In-Reply-To: <20070518005948.GA11737@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Urs, Hello Paul,

i assume Paul refers to the can_rx_delete_all() function that adds each 
receive list entry for rcu removal using the can_rx_delete RCU callback, 
right?

So the idea would be to create a second RCU callback - e.g. 
can_rx_delete_list() - that removes the complete list inside the RCU 
callback?!?
The list removal would therefore be processed inside this new 
can_rx_delete_list() in RCU context and not inside can_rx_delete_all().

@Paul: Was this your intention?

Best regards,
Oliver

Paul E. McKenney wrote:
> On Wed, May 16, 2007 at 04:51:02PM +0200, Urs Thuermann wrote:
>   
>> This patch adds the CAN core functionality but no protocols or drivers.
>> No protocol implementations are included here.  They come as separate
>> patches.  Protocol numbers are already in include/linux/can.h.
>>     
>
> Interesting!  One question called out below -- why do call_rcu() on each
> piece of the struct dev_rcv_lists, instead of doing call_rcu() on the
> whole thing and having the RCU callback free up the pieces?  Given that
> all the pieces are call_rcu()ed separately, there had better not be
> persistent pointers to the pieces, right?
>
> Doing it in one chunk would make the code a bit simpler and also reduce
> the RCU overhead a bit.
>
> Or am I missing something subtle here?
>
> 						Thanx, Paul
>
>   
>

