From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] apply cwnd rules to FIN packets with data
Date: Mon, 05 Feb 2007 19:25:54 -0500
Message-ID: <45C7CB12.2040109@psc.edu>
References: <45C7A87A.5050200@psc.edu>	<20070205.145615.92339659.davem@davemloft.net>	<45C7B77B.9060506@psc.edu>	<20070205.150815.112291591.davem@davemloft.net> <45C7C79D.1070707@psc.edu> <45C7C9BE.5050205@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:58071 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965284AbXBFA0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:26:04 -0500
In-Reply-To: <45C7C9BE.5050205@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> John Heffner wrote:
>> David Miller wrote:
>>
>>>> However, I can't think of any reason why the cwnd test should not 
>>>> apply.
>>>
>>>
>>> Care to elaborate here?  You can view the FIN special case as an off
>>> by one error in the CWND test, it's not going to melt the internet.
>>> :-)
>>
>>
>> True, it's not going to melt the internet, but why stop at one when 
>> two would finish the connection even faster?  Not sure I buy this 
>> argument.  Was there some benchmarking data that was a justification 
>> for this in the first place?
> 
> Is the cwnd in the stack byte based, or packet based?
> 
> While "all" the RFCs tend to discuss things in terms of byte-based cwnds 
> and assumptions based on MSSes and such, the underlying principle was/is 
> a conservation of packets.  As David said, a packet is a packet, and if 
> one were going to be sending a FIN segment, it might as well carry data. 
>  And if one isn't comfortable sending that one last data segment with 
> the FIN because cwnd wasn't large enough at the time, should the FIN be 
> sent at that point, even if it is waffer thin?

The most conservative thing is to apply congestion control exactly as 
you would to any other segment, that is, just take the special case out 
entirely.  An empty FIN is not too likely to cause problems, a full-MSS 
FIN somewhat more so, 2-MSS, yet more, a 64k TSO segment even more. :) 
I don't have hard data to argue for or against any particular 
optimization, but it seems there should be some if we're ignoring the 
standard cwnd rules.

   -John
