From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] tcp: randomize TCP source ports
Date: Thu, 07 Nov 2013 17:07:14 -0800
Message-ID: <527C3942.509@hp.com>
References: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:38070 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab3KHBHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 20:07:15 -0500
In-Reply-To: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2013 04:54 PM, Eric Dumazet wrote:
> TCP does proper randomization of ports on active connections only if
> bind() is used between socket() and connect()
>
> If bind() is not specifically used, kernel performs autobind, and TCP
> autobind typically uses a sequential allocation for a given (dst
> address, dst port, src address) tuple.
>
> UDP autobind does a randomization, as part of the effort to make DNS
> more secure.
>
> TCP autobind uses a global sequential number (called @hint in source
> code) with a perturbation done by secure_ipv4_port_ephemeral(),
>   so that the 'hint' of the next port is per (saddr, daddr, dport) tuple
>
> This was probably done to maximize port use and avoid hitting timewait
> sockets, but I think it should be OK to replace this stuff by a random
> selection to have more entropy in the various flow hashing functions,
> and in general higher security levels. TCP timestamps are now well
> deployed.

For perhaps most definitions of well deployed.  There is at least one 
load balancer which, while it offers TCP Window Scaling, does not also 
offer TCP Time Stamps...

By rights they should (must) be offering TCP Time Stamps, and they are, 
I am told, "working on it."

Is all going to be "well" when it is the (non-Linux) remote system which 
has the TIME_WAIT endpoint?

rick jones
