From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 22 Sep 2008 17:33:50 -0700
Message-ID: <48D8396E.20008@hp.com>
References: <48D82378.4000306@redhat.com>	<20080922.161323.108280715.davem@davemloft.net>	<20080922232428.GA25711@one.firstfloor.org>	<20080922.162158.223213897.davem@davemloft.net> <20080923001409.GB25711@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, csnook@redhat.com,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:25134 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751AbYIWAdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 20:33:53 -0400
In-Reply-To: <20080923001409.GB25711@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
>>It is not an invalid estimate even in the NAT case, 
> 
> 
> Typical case: you got a large company network behind a NAT.
> First user has a very crappy wireless connection behind a slow
> intercontinental link talking to the outgoing NAT router. He connectes to 
> your internet server first and the window, slow start etc. parameters 
> for him are saved in the dst_entry.  
> 
> The next guy behind the same NAT is in the same building
> as the router who connects the company to the internet. He
> has a much faster line. He connects to the same server. 
> They will share the same dst and inetpeer entries.
> 
> The parameters saved earlier for the same IP are clearly invalid
> for the second case. The link characteristics are completely 
> different.
> 
> Also did you know there are there are whole countries behind
> NAT. e.g. I was told that all of Saudi Arabia only comes from
> a small handfull of IP addresses. It would surprise me if 
> all of KSA has the same link characteristics? @)

That seems as much of a case against NAT as per-destintation attribute 
caching.

If my experience at "a large company" is any indication, for 99 
connections out of 10 I'm going through a proxy rather than NAT so all 
the remote server sees are the characteristics of the connection between 
it and the proxy.

And even if I were not, how is per-destination caching the possibly 
non-optimal characteristics based on one user behind a NAT really 
functionally different than having to tune the system-wide defaults to 
cover that corner-case user?  Seems that caching per-destination 
characteristics is actually limiting the alleged brokenness to that 
destination rather than all destinations?

rick jones
