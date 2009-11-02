From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder Cookie
Date: Mon, 02 Nov 2009 07:36:10 -0500
Message-ID: <4AEED23A.7070009@gmail.com>
References: <4AEAC763.4070200@gmail.com> <4AED86AD.6010906@gmail.com> <4AEDCD7C.2010403@gmail.com> <4AEEB6D2.7090505@gmail.com> <4AEEBAC6.7020308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:64853 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994AbZKBMgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 07:36:08 -0500
In-Reply-To: <4AEEBAC6.7020308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> cookie_hash() runs in a non preemptable context. CPU cannot change under us.
> 
> (or else, we would not use __get_cpu_var(ipv4_cookie_scratch); )
> 
> And of course, each cpu gets its own scratch area, thanks to __get_cpu_var()
> 
Interesting.  I'm not sure that running CPU intensive functions like SHA1 in
a non-preemptable context is a good idea.  I'd assumed it wasn't!

Perhaps you could point at the documentation in the code that explains this?
Perhaps a function header comment that mentions it?

All I know is (from testing) that the tcp_minisockets.c caller is sometimes
called in a fashion that requires atomic allocation, and other times does not!

See my "Subject: query: tcpdump versus atomic?" thread from Oct 14th.
