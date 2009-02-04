From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 04 Feb 2009 11:19:06 -0800
Message-ID: <ada63jqm2mt.fsf@cisco.com>
References: <20090204081201.GB10445@ioremap.net>
	<20090204085432.GA21638@1wt.eu>
	<20090204085907.GA19388@gondor.apana.org.au>
	<20090204.010146.18100191.davem@davemloft.net>
	<20090204091217.GA21385@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	zbr@ioremap.net, jarkao2@gmail.com, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:36193 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755620AbZBDTTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 14:19:10 -0500
In-Reply-To: <20090204091217.GA21385@1wt.eu> (Willy Tarreau's message of "Wed,
	4 Feb 2009 10:12:17 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > And the arbitrary choice of 9k for jumbo frames was total crap too.
 > It's clear that no hardware designer was involved in the process.
 > They have to stuff 16kB of RAM on a NIC to use only 9. And we need
 > to allocate 3 pages for slightly more than 2. 7.5 kB would have been
 > better in this regard.

9K was not totally arbitrary.  The CRC used for checksumming ethernet
packets has a probability of undetected errors that goes up about
11-thousand something bytes.  So the real limit is ~11000 bytes, and I
believe ~9000 was chosen to be able to carry 8K NFS payloads + all XDR
and transport headers without fragmentation.

 - R.
