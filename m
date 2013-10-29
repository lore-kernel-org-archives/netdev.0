From: Florian Weimer <fweimer@redhat.com>
Subject: Re: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE
Date: Tue, 29 Oct 2013 08:36:35 +0100
Message-ID: <526F6583.4000506@redhat.com>
References: <20131026201158.GI15744@order.stressinduktion.org> <20131029.000844.1092862708536984032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35478 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151Ab3J2Hgl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 03:36:41 -0400
In-Reply-To: <20131029.000844.1092862708536984032.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2013 05:08 AM, David Miller wrote:

> I do not like this reasoning.  You have several more acceptable paths to take
> to resolve this problem:
>
> 1) "I don't trust path MTU information at all"
>
>     Just turn it off globally, end of story.  It has the same effect as your
>     new per-application mode.

We can't push this as a security update.  We could tell everyone running 
DNS servers to reconfigure their systems in this way, but I always 
consider this a bit of a cop-out.

A new knob to turn IP_PMTUDISC_DONT into something that behaves like 
IP_PMTUDISC_INTERFACE would be more conservative and easier to deploy, I 
think.

> 2) "I don't trust path MTU information unless the full socket ID is available
>      in the ICMP packets quoted headers"
>
>     Then simply implement a policy as such and submit it to me.

There are IP protocols where these bits aren't readily available and 
where we don't want the kernel (outside the Netfilter code) to be aware 
of the payload structure.  Netfilter isn't a solution because it 
requires state and doesn't work well with request-response UDP protocols 
like DNS (even before source port randomization).

You could make the path MTU dependent on the protocol (which would even 
be the correct solution from a technical point of view) and use 
validation for TCP and UDP, but that's a fairly invasive change for such 
relatively minor functionality.

-- 
Florian Weimer / Red Hat Product Security Team
