From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Piggyback the final ACK of the three way TCP connection establishment
 with the data
Date: Wed, 21 Mar 2012 16:52:24 -0700
Message-ID: <4F6A69B8.3060500@hp.com>
References: <CAK3+h2zYLsWw44cAqJN_7vE1bqbEEsDK5oqKLpej0RLuKhk3qQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:36351 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465Ab2CUXw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 19:52:26 -0400
In-Reply-To: <CAK3+h2zYLsWw44cAqJN_7vE1bqbEEsDK5oqKLpej0RLuKhk3qQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2012 04:38 PM, Vincent Li wrote:
> Hi,
>
> I happen to see this link
> http://h20000.www2.hp.com/bc/docs/support/SupportManual/c02020743/c02020743.pdf
> and

That dates to March of 2008.

> tcp_delay_final_twh_ack:
>              Piggyback the final ACK of the three way TCP connection
>              establishment with the data by delaying the final ack by
>             10ms.
>
>             0: Send the final ACK as soon as the SYN+ACK packet
>                 arrives from the remote host.
>
>             1: Delay the sending of the final ACK by 10ms. If
>                 there is data available to be sent with in the
>                 next 10ms, piggyback the ACK for the SYN.
> [0-1] Default: 1

I guess that was to allow the client's ACK of the server's SYN|ACK of 
the client's SYN to be piggybacked with the client's initial request. 
Probably did nice things on either netperf TCP_CRR, or some 
connect()-heavy workload.    Probably not a good thing for those 
applications where the accept()ing side sends first...

> It appears this feature is not available in kernel tcp implementation,
> is it trivial to make a custom patch to make this feature available?
> can someone give a hint on how to make a patch for this?
>
> We had a situation that we want to make linux kernel tcp stack behave
> this way so we can reproduce another issue at hand.

Unless some other stack has that feature, why not simply use an HP-UX 
system directly?

rick jones
