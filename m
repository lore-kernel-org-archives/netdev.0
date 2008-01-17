From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] ICMP: ICMP_MIB_OUTMSGS increment duplicated
Date: Wed, 16 Jan 2008 16:10:45 -0800
Message-ID: <OFDCFFA090.803D8BBA-ON882573D2.00825C17-882573D3.0000FA84@us.ibm.com>
References: <E1JFHVh-00012A-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	wangchen@cn.fujitsu.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:35629 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbYAQAKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 19:10:46 -0500
In-Reply-To: <E1JFHVh-00012A-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 01/16/2008 03:17:29 PM:

> Fair enough.  How about moving this code back into icmp.c and just
> add a new count call in raw.c? The push pending function is used on
> the UDP fast path so the leaner it is the better.

        I started out with it there, but it certainly wasn't
cleaner. You have to peek on the queue, which I didn't
want to do for all the SMP issues that brings in, and
then replicate all the code push_pending_frames does to
get you a protocol header pointer in one buffer, and there
are multiple ways in the raw path to get you there (so the
counter code itself would appear in multiple places).
        I don't think the 2 instructions measurably impact
anything in the fast path and that is the earliest common
point for the multiple paths to generate ICMP output where
the header and type are available without replicating code.
So, simplicity is exactly why I put it there, rather than
the "obvious" places at the higher layer. :-) It's probably
the better, single place to put the other protocol "out messages"
counters, too, since those probably also have multiple paths
that end up here, but ICMPMsgStats was all that patch was
after.


                                                +-DLS

