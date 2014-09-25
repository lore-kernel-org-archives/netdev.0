From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next 2/3] ipv6: mld: do not overwrite uri when receiving
 an mldv2 query
Date: Thu, 25 Sep 2014 12:02:17 -0400
Message-ID: <54243C89.6060405@oracle.com>
References: <1411455828-5196-1-git-send-email-dborkman@redhat.com> <1411455828-5196-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21675 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476AbaIYQCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 12:02:41 -0400
In-Reply-To: <1411455828-5196-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While I can see the case you're making, I think the intent of MRC is
violated by arbitrary URI.

> 5.1.3.  Maximum Response Code
> 
>    The Maximum Response Code field specifies the maximum time allowed
>    before sending a responding Report. 
>...
>    Small values of Maximum Response Delay allow MLDv2 routers to tune
>    the "leave latency" (the time between the moment the last node on a
>    link ceases to listen to a specific multicast address and the moment
>    the routing protocol is notified that there are no more listeners for
>    that address).  Larger values, especially in the exponential range,
>    allow the tuning of the burstiness of MLD traffic on a link.

If URI is larger than MRD, then a lost unsolicited report, or series,
specifically will *not* propagate changes throughout the network in less
than MRD*QRV, as intended.

It was an intentional design choice, not required or prohibited by RFC.

I'm not sure what problem you think it's causing, but if they are not
equal, I think at least the URI should be enforced to <= MRD. The querier,
IMO, should set these network-wide relevant parameters, not the individual
hosts.

Is there actually some bad effect from this?

						+-DLS
