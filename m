From: Corey Minyard <minyard@acm.org>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 11:43:04 -0500
Message-ID: <48EB9198.1090605@acm.org>
References: <20081006185026.GA10383@minyard.local>
 <48EA8197.6080502@cosmosbay.com>
 <20081006.144002.56418911.davem@davemloft.net>
 <48EAF29D.8050203@cosmosbay.com> <m37i8k3hv1.fsf@ursa.amorsen.dk>
 <48EB5D28.7000503@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benny Amorsen <benny+usenet@amorsen.dk>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, paulmck@linux.vnet.ibm.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:61946 "EHLO
	vms046pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985AbYJGQnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 12:43:17 -0400
In-reply-to: <48EB5D28.7000503@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
>
> (2 weeks ago, Corey mentioned a 10x increase on UDP throughput on a 
> 16-way machine,
> that sounds promising)
Just to be clear, that was 10x with preempt RT, which converts rwlocks 
into PI mutexes.  So 16 processors going for the same lock is pretty ugly.

Under heavy loads there is also a writer starvation problem, I believe 
in non-RT.  You can't actually create or destroy a UDP socket when the 
load is high because there's always a reader holding the lock.  RCU also 
solves that problem.

-corey

