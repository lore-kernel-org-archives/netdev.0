From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 20:07:01 +0100
Message-ID: <20151022190701.GV22011@ZenIV.linux.org.uk>
References: <20151021034950.GL22011@ZenIV.linux.org.uk>
 <5627A37B.4090208@oracle.com>
 <20151021185104.GM22011@ZenIV.linux.org.uk>
 <20151021.182955.1434243485706993231.davem@davemloft.net>
 <5628636E.1020107@oracle.com>
 <20151022044458.GP22011@ZenIV.linux.org.uk>
 <20151022060304.GQ22011@ZenIV.linux.org.uk>
 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
 <20151022172146.GS22011@ZenIV.linux.org.uk>
 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38135 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbbJVTHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 15:07:07 -0400
Content-Disposition: inline
In-Reply-To: <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 08:24:51PM +0200, Casper.Dik@oracle.com wrote:

> The external behaviour atomic; you cannot distinguish the order
> between the closing of the original file (and waking up other threads
> waiting for a record lock) or changing the file referenced by that newfd.
> 
> But this not include a global or process specific lock.

Interesting...  Do you mean that decriptor-to-file lookup blocks until that
rundown finishes?
