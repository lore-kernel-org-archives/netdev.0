From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] [IPv4] Reply net unreachable ICMP message
Date: Thu, 6 Dec 2007 09:47:33 +0100
Message-ID: <20071206084733.GB2164@ff.dom.local>
References: <20071206171421.1495c019.mitch@linux.vnet.ibm.com>
Reply-To: Jarek Poplawski <jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Rami Rosen <roszenrami@gmail.com>
To: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:42606 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751891AbXLFIml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 03:42:41 -0500
Content-Disposition: inline
In-Reply-To: <20071206171421.1495c019.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06-12-2007 09:14, Mitsuru Chinen wrote:
> On Thu, 6 Dec 2007 08:49:47 +0100
> Jarek Poplawski <jarkao2@o2.pl> wrote:
> 
>> On 06-12-2007 07:31, Mitsuru Chinen wrote:
>>> IPv4 stack doesn't reply any ICMP destination unreachable message
>>> with net unreachable code when IP detagrams are being discarded
>>> because of no route could be found in the forwarding path.
>>> Incidentally, IPv6 stack replies such ICMPv6 message in the similar
>>> situation.
...
>> This patch seems to be wrong. It overrides err codes from
>> fib_lookup, where such decisions should be made.
> 
> fib_lookup() replies -ESRCH in this situation.
> It is necessary to override the variable by the suitable error
> number like the code under e_hostunreach label.

Probably I miss something, but I can't see how can you be sure it's
only -ESRCH possible here? Isn't opt->action() in fib_rules_lookup()
supposed to return this -ENETUNREACH when needed?

Jarek P.
