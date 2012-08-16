From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2 0/7] TCP Fast Open client
Date: Thu, 16 Aug 2012 09:35:26 -0700
Message-ID: <502D214E.8070803@hp.com>
References: <1342645307-17772-1-git-send-email-ycheng@google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6FB6@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>, davem@davemloft.net,
	hkchu@google.com, edumazet@google.com, ncardwell@google.com,
	sivasankar@cs.ucsd.edu, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:10066 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932996Ab2HPQfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 12:35:30 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FB6@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2012 01:50 AM, David Laight wrote:
> It seems wrong to be using sendmsg() to perform a 'connect' action.
> Anything that tries to monitor the socket state from a trace, or
> validate the sequence of library calls will get it all wrong.
>
> IMHO this should be a new connect_xxx() function - and probably
> a new system call entry.
>
> This is similar to the complete fubar where sctp abuses setsockopt().
>
> For development hacking using sendmsg() probably avoided the need
> to hack at some code paths, but I'm sure it will cause grief in
> the long term.
>
> Other OS may have much more difficultly in abusing sendmsg().

I kind of like being able to use sendmsg()/sendto() as it provides a bit 
of symmetry with UDP.  Just so long as I can keep using 
sendmsg()/sendto() for subsequent sends on the same connection I think 
it would be fine.  In fact, being able to use sendto() made adding 
netperf support for the client side of TCP Fast Open rather trivial as 
it already knew about using sendto() for UDP :)

Someone tracing/monitoring will have to know "When tracing an 
application possibly using TCP Fast Open you have to include 
<new-to-the-procedure> in the tracing" - and including sendmsg/sendto 
there is no different than a new call.  At least from my perspective.

rick jones
