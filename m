From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 16:11:27 -0400
Message-ID: <1178827887.4062.90.camel@localhost>
References: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>
	 <46435412.50800@hp.com>
	 <1178820423.17393.3.camel@w-sridhar2.beaverton.ibm.com>
	 <464375F9.1050600@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Rick Jones <rick.jones2@hp.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: Gagan Arneja <gaagaan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:19485 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754996AbXEJULa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:11:30 -0400
Received: by wx-out-0506.google.com with SMTP id h31so660614wxd
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 13:11:30 -0700 (PDT)
In-Reply-To: <464375F9.1050600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The discussion seems to have steered into protocol coalescing.
My tests for example were related to forwarding and not specific
to any protocol.

On Thu, 2007-10-05 at 12:43 -0700, Gagan Arneja wrote:

> It's not just small packets. The cost of calling hard_start_xmit/byte 
> was rather high on your particular device. I've seen  PCI read 
> transaction in hard_start_xmit taking ~10,000 cycles on one particular 
> device. Count the cycles your brand of NIC is taking in it's 
> xmit_routine. The worse it is, the stronger your case for cluster 
> transmits.

You would need to almost re-write the driver to make sure it does IO
which is taking advantage of the batching. 

> Also, I think, you don't have to chain skbs, they're already chained in 
>   Qdisc->q. 
> All you have to do is take the whole q and try to shove it 
> at the device hoping for better results. 

You are onto something with desire to use the qdisc; however, note you
need to leave the qdisc above so other CPUs can continue enqueueing.
In my approach i used the qdisc to populate a list that is attached to
the dev.

> But then, if you have rather 
> big backlog, you run the risk of reordering packets if you have to requeue.

You could avoid totaly requeueing by asking the driver how much space it
has. Once you shove down to it a number of packets, you are then
guaranteed they will never be requeued (refer to the slides i pointed to
earlier).

cheers,
jamal


