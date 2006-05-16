From: John Heffner <jheffner@psc.edu>
Subject: Re: Controlling TCP window size
Date: Tue, 16 May 2006 14:48:04 -0400
Message-ID: <446A1E64.7040006@psc.edu>
References: <4469B251.3050901@andyfurniss.entadsl.com> <446A19C7.1000302@psc.edu> <446A1BC8.5060609@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:8898 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S1751602AbWEPSsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 14:48:11 -0400
To: lists@andyfurniss.entadsl.com
In-Reply-To: <446A1BC8.5060609@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Furniss wrote:
> John Heffner wrote:
>> Andy Furniss wrote:
>>
>>>
>>> I've been doing some testing of my new wan connection and noticed 
>>> that when I specify a window with ip route it still changes after a 
>>> while.
>>
>>
>> Looks like this is occurring in 
>> net/ipv4/tcp_input.c:tcp_rcv_space_adjust().
>>
>> The problem really is that the window_clamp variable is overloaded. 
>> It's used as a kind of cache for rcvbuf -> window conversion, but also 
>> as a user-settable bound in window size.  On examination, it looks 
>> like this is also broken (in that window size won't increase) if a 
>> user does a setsockopt(SO_RCVBUF).  Can we make window_clamp a true 
>> clamp?  Then we can get rid of the hack of raising it in 
>> tcp_rcv_space_adjust().  I can cook up a patch if interested.
>>
>>   -John
>>
> 
> Thanks - I did get an answer off list (probably accidently?) to the 
> effect that I shouldn't rely on ip route to limit window as it's only a 
> hint and would make more sense if I wanted it to start really big.

I guess the other problem is that it's not well defined. :)  As it 
stands now though it's nearly useless if you have tcp_moderate_rcvbuf 
turned on.


> Playing with r_mem etc is the way to go to hard limit.

This will work, but is not available per-route or per-socket.  The 
purpose is really different.

   -John

