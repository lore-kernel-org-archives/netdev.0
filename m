From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: Controlling TCP window size
Date: Tue, 16 May 2006 19:36:56 +0100
Message-ID: <446A1BC8.5060609@andyfurniss.entadsl.com>
References: <4469B251.3050901@andyfurniss.entadsl.com> <446A19C7.1000302@psc.edu>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from entadsl.viper.enta.net ([81.31.115.186]:3848 "EHLO
	entadsl.viper.enta.net") by vger.kernel.org with ESMTP
	id S932505AbWEPSed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 14:34:33 -0400
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <446A19C7.1000302@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner wrote:
> Andy Furniss wrote:
> 
>>
>> I've been doing some testing of my new wan connection and noticed that 
>> when I specify a window with ip route it still changes after a while.
> 
> 
> Looks like this is occurring in 
> net/ipv4/tcp_input.c:tcp_rcv_space_adjust().
> 
> The problem really is that the window_clamp variable is overloaded. It's 
> used as a kind of cache for rcvbuf -> window conversion, but also as a 
> user-settable bound in window size.  On examination, it looks like this 
> is also broken (in that window size won't increase) if a user does a 
> setsockopt(SO_RCVBUF).  Can we make window_clamp a true clamp?  Then we 
> can get rid of the hack of raising it in tcp_rcv_space_adjust().  I can 
> cook up a patch if interested.
> 
>   -John
> 

Thanks - I did get an answer off list (probably accidently?) to the 
effect that I shouldn't rely on ip route to limit window as it's only a 
hint and would make more sense if I wanted it to start really big.

Playing with r_mem etc is the way to go to hard limit.

Andy.

