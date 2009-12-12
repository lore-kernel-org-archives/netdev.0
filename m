From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: Custom hardware Qdisc...
Date: Fri, 11 Dec 2009 16:58:50 -0800
Message-ID: <4B22EACA.2060407@caviumnetworks.com>
References: <4B228EC0.80105@caviumnetworks.com> <20091211.144021.192655356.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.caviumnetworks.com ([209.113.159.134]:18233 "EHLO
	smtp2.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758394AbZLLBNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 20:13:45 -0500
In-Reply-To: <20091211.144021.192655356.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: David Daney <ddaney@caviumnetworks.com>
> Date: Fri, 11 Dec 2009 10:26:08 -0800
> 
>> Our hardware (Octeon SOC) has fairly flexible packet output queuing
>> that can be done completely in hardware.
> 
> You haven't described sufficiently what your hardware is
> capable of.
> 

Up to 16 output queues per port. With (almost) any combination of 
absolute and weighted priorities between the various queues.


> Generally, implementing qdiscs specifically to support
> hardware features is not how things are handled.
> 

I think I could emulate the default pfifo Qdisk fairly well in hardware. 
  By making it a Qdisc, the user would still be able to switch to one of 
the software implementations if desired at runtime.


> But really we need to know a lot more about the details of your
> hardware to make any kind of real suggestions.
> 

Well see above for the overview.  I just wanted to get an idea if such 
an approach would be highly frowned upon before coding anything up.

We see significant cacheline bouncing in the Qdisc code and can increase 
  packet forwarding rates by 10%-15% by setting the txqueuelen to zero 
to disable the queuing.  I would like to see if the same thing can be 
achieved without throwing away the features of the Qdisc.

David Daney

