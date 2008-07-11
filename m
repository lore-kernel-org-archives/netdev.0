From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Autotuning and send buffer size
Date: Fri, 11 Jul 2008 09:48:06 -0700
Message-ID: <48778EC6.8070507@hp.com>
References: <20080711150208.GA15305@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:9773 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898AbYGKQsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 12:48:11 -0400
In-Reply-To: <20080711150208.GA15305@citi.umich.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't undestand how a "too big" sender buffer can hurt performance.  I
> have not measured what size the sender's buffer is in the autotuning case.

In broad handwaving terms, TCP will have no more data outstanding at one 
time than the lesser of:

*) what the application has sent
*) the current value of the computed congestion window
*) the receiver's advertised window
*) the quantity of data TCP can hold in its retransmission queue

That last one is, IIRC directly related to "SO_SNDBUF"

That leads to an hypothesis of all of those being/growing large enough 
to overflow a queue somewhere - for example an interface's transmit 
queue and causing retransmissions.  Ostensibly, one could check that in 
ifconfig and/or netstat statistics.

rick jones
