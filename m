From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 21 Oct 2015 14:18:30 -0700
Message-ID: <1445462310.22974.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com>
	 <20151021.083008.1870598627666404990.davem@davemloft.net>
	  <201510211604.t9LG4r9A005345@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Alan.Burlison@oracle.com,
	viro@ZenIV.linux.org.uk, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34619 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822AbbJUVSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 17:18:32 -0400
Received: by padhk11 with SMTP id hk11so65296364pad.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 14:18:31 -0700 (PDT)
In-Reply-To: <201510211604.t9LG4r9A005345@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-10-21 at 18:04 +0200, Casper.Dik@oracle.com wrote:

> It is only expensive within the process itself. 

thread synchro would require additional barriers to maintain this state,
for a very unlikely case.

The atomic_{inc|dec}() on file refcount are already a problem.

We certainly do not use/take a lock to find a file pointer into file
descriptor table.

(This lock is only used at open() or close() time)
