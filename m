From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Tue, 22 Jul 2008 01:34:28 -0500
Message-ID: <48857F74.2040406@lwfinger.net>
References: <488504D9.5090100@lwfinger.net>	<488507FB.9050101@trash.net>	<4885104A.2070201@lwfinger.net> <20080721.161517.27161039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, mingo@elte.hu, ischram@telenet.be,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, j@w1.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:61072 "EHLO
	mtiwmhc11.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750718AbYGVGeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 02:34:31 -0400
In-Reply-To: <20080721.161517.27161039.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Larry Finger <Larry.Finger@lwfinger.net>
> Date: Mon, 21 Jul 2008 17:40:10 -0500
> 
>> Sorry :(
>>
>> I used the davem patch, the second version of your first one, and your second 
>> one. Both problems persist.
>>
>> Still plugging away on bisection.
> 
> GIT bisecting the lockdep problem is surely going the land you on:
> 
> commit e308a5d806c852f56590ffdd3834d0df0cbed8d7

No. It landed on this one.

37437bb2e1ae8af470dfcd5b4ff454110894ccaf is first bad commit
commit 37437bb2e1ae8af470dfcd5b4ff454110894ccaf
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Jul 16 02:15:04 2008 -0700

     pkt_sched: Schedule qdiscs instead of netdev_queue.

     When we have shared qdiscs, packets come out of the qdiscs
     for multiple transmit queues.

     Therefore it doesn't make any sense to schedule the transmit
     queue when logically we cannot know ahead of time the TX
     queue of the SKB that the qdisc->dequeue() will give us.

     Just for sanity I added a BUG check to make sure we never
     get into a state where the noop_qdisc is scheduled.

     Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 4d13d1fb1ae37d9720c3db6b1368866e78621f55 
f1a0f5e5a191e7904b528d9e10069a4324a5d328 M      include
:040000 040000 3515aad52a2cdaaba85feeffc0944d7f07a19c96 
4854d4f4df9726a2e8837037f82bde807bed2ede M      net

Larry
