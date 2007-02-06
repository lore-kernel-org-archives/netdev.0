From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] apply cwnd rules to FIN packets with data
Date: Mon, 05 Feb 2007 16:20:14 -0800
Message-ID: <45C7C9BE.5050205@hp.com>
References: <45C7A87A.5050200@psc.edu>	<20070205.145615.92339659.davem@davemloft.net>	<45C7B77B.9060506@psc.edu>	<20070205.150815.112291591.davem@davemloft.net> <45C7C79D.1070707@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:49621 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965125AbXBFAUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:20:16 -0500
In-Reply-To: <45C7C79D.1070707@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner wrote:
> David Miller wrote:
> 
>>> However, I can't think of any reason why the cwnd test should not apply.
>>
>>
>> Care to elaborate here?  You can view the FIN special case as an off
>> by one error in the CWND test, it's not going to melt the internet.
>> :-)
> 
> 
> True, it's not going to melt the internet, but why stop at one when two 
> would finish the connection even faster?  Not sure I buy this argument. 
>  Was there some benchmarking data that was a justification for this in 
> the first place?

Is the cwnd in the stack byte based, or packet based?

While "all" the RFCs tend to discuss things in terms of byte-based cwnds 
and assumptions based on MSSes and such, the underlying principle was/is 
a conservation of packets.  As David said, a packet is a packet, and if 
one were going to be sending a FIN segment, it might as well carry data. 
  And if one isn't comfortable sending that one last data segment with 
the FIN because cwnd wasn't large enough at the time, should the FIN be 
sent at that point, even if it is waffer thin?

rick jones
2 cents tossed-in from the peanut gallery
