From: Rick Jones <rick.jones2@hp.com>
Subject: Re: UDP path MTU discovery
Date: Fri, 26 Mar 2010 10:48:08 -0700
Message-ID: <4BACF358.7040001@hp.com>
References: <1269561751.2891.8.camel@ilion>	<4BAC0577.7070803@hp.com> <20100325.202636.149498207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gdt@gdt.id.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:47521 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab0CZRsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 13:48:11 -0400
In-Reply-To: <20100325.202636.149498207.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Thu, 25 Mar 2010 17:53:11 -0700
> 
> 
>>So, presuming it is indeed a bug what form might a fix take? Are you
>>suggesting there should be a way for an application to say "Please let
>>me see/know about the ICMP messages?"  Is that option available on
>>other platforms as a platform-specific extension?
> 
> 
> We already provide this information.
> 
> The socket ends up with EMSGSIZE in it's error queue, so the next time
> the application does I/O it sees that error immediately from the
> read/write call and thus knows that path MTU arrived.

A possibly pedantic question, but only when it does I/O, or also when/if it is 
in poll/select?

What distinguishes this EMSGSIZE from a run-of-the-mill EMSGSIZE error such as 
one gets from trying to send a datagram larger than SO_SNDBUF?

That is something that happens all the time in netperf when people forget a -m 
option on UDP_STREAM tests :)  Netperf gets the error and exits.  But supposing 
I wanted to make netperf more sophisticated in that regard - what sort of things 
must it do?  Call getsockopt(SO_SNDBUF) to check the size of the failed send 
against SO_SNDBUF and only then decide if it is an error on this send or an ICMP 
Datagram Too Big arrived indication from a previous send?  I know that netperf 
already has this information, so using it as the example is a bit stretched, but 
lets presume for the moment that netperf just has a socket handed to it from 
"somewhere."

rick jones
