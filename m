From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: why are there messages like assertion ((int)tcp_packets_in_flight(tp)...
Date: Wed, 26 Mar 2008 14:57:03 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803261353100.24534@kivilampi-30.cs.helsinki.fi>
References: <18406.49168.311576.570515@fisica.ufpr.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Carlos Carvalho <carlos@fisica.ufpr.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54600 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755567AbYCZM5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 08:57:07 -0400
In-Reply-To: <18406.49168.311576.570515@fisica.ufpr.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Mar 2008, Carlos Carvalho wrote:

> We get these messages in the log from time to time:
> 
> assertion ((int)tcp_packets_in_flight(tp) >= 0) failed at net/ipv4/tcp_input.c (1274)
> 
> What do they mean? Is there a way to get rid of them?

> They usually appear at high net traffic periods.

Your mail is lacking key bit of information:
- What kernel version you're using?
- Is this only message? Especially I'm interested in if Leak printouts 
show up, but more complete snippet of the log wouldn't hurt (I don't need 
all those boot up details though :-)).

It may mean a number of things. Basically packet counting is not that 
accurate as it should, whether that's causing bad things or not, it 
depends...

...In case it's something before 2.6.24, there's one potential patch 
available in archives adding one clearly missing left_out adjustment. 
Nobody has confirmed that it actually silences the message nor I've a 
clear theory how it could cause this. In the case that was debugged 
(either 2.6.22 or 2.6.23, I don't remember anymore in which), this message 
was found to occur in a rather harmless situation, ie., when no packets 
are outstanding. Unless they occur in sheer number spamming your logs, 
it's not that big problem.

2.6.24 and later does not have left_out but sacked_out + lost_out is used 
when needed making inconsistent left_out a non-issue. There might still be 
some miscount for either of the source counters and this message could 
signal that.

> This is with a forcedeth chip, in case it's relevant.

Very likely a pure tcp issue.


-- 
 i.
