From: Joe Perches <joe@perches.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN
 exchange with SYNACK data
Date: Mon, 02 Nov 2009 09:00:19 -0800
Message-ID: <1257181219.28925.13.camel@Joe-Laptop.home>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com>
	 <4AEDDF33.9030205@gmail.com>  <4AEECFA8.1080306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1167 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756404AbZKBRAP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 12:00:15 -0500
In-Reply-To: <4AEECFA8.1080306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-02 at 07:25 -0500, William Allen Simpson wrote:
> For complex tests, this makes the code much more readable and easier to
> visually verify on code walk-through:
> 
> +	if (0 < tmp_opt.cookie_plus
> +	 && tmp_opt.saw_tstamp
> +	 && !tp->cookie_out_never
> +	 && (0 < sysctl_tcp_cookie_size
> +	  || (NULL != tp->cookie_values
> +	   && 0 < tp->cookie_values->cookie_desired))) {
> 
> Consistent use of security style would have obviated a lot of foolish >= 0
> tests that seem to be constantly in need of fixing.  It's a bad idea to
> depend on the compiler to catch non-executable code.

Linus wrote a long time back (5+ years):

The reason for "if (x == 8)" comes from the way we're taught to think. 
Arguing against that _fact_ is just totally non-productive, and you have 
to _force_ yourself to write it the other way around.

And that just means that you will do other mistakes. You'll spend your 
time thinking about trying to express your conditionals in strange ways, 
and then not think about the _real_ issue.

So let's make a few rules:

 - write your logical expressions the way people EXPECT them to be 
   written. No silly rules that make no sense.

   Ergo:

        if (x == 8)

   is the ONE AND ONLY SANE WAY.

 - avoid using assignment inside logical expressions unless you have a 
   damn good reason to.

   Ergo: write

        error = myfunction(xxxx)
        if (error) {
                ...

   instead of writing

        if (error = myfunction(xxxx))
                ....

   which is just unreadable and stupid.

 - Don't get hung about stupid rules. 

   Ergo: sometimes assignments in conditionals make sense, especially in
   loops. Don't avoid them just because of some silly rule. But strive to
   use an explicit equality test when you do so:

        while ((a = function(b)) != 0) 
                ...

   is fine.

 - The compiler warns about the mistakes that remain, if you follow these 
   rules.

 - mistakes happen. Deal with it. Having tons of rules just makes them 
   more likely. Expect mistakes, and make sure they are fixed quickly

