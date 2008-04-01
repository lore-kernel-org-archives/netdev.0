From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fix for the fundamental network/block layer race in sendfile().
Date: Tue, 1 Apr 2008 23:45:27 +0400
Message-ID: <20080401194527.GA26833@2ka.mipt.ru>
References: <20080328092036.GA11924@2ka.mipt.ru> <20080328.134053.122172549.davem@davemloft.net> <20080328205613.GA24812@2ka.mipt.ru> <20080328.140736.92315090.davem@davemloft.net> <20080328215131.GB24812@2ka.mipt.ru> <20080401164904.GA2382@2ka.mipt.ru> <47F26EAB.7040900@cosmosbay.com> <20080401174759.GB28217@2ka.mipt.ru> <20080401180751.GA3263@2ka.mipt.ru> <47F28B2F.2070609@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, axboe@kernel.dk,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45685 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756793AbYDATpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 15:45:43 -0400
Content-Disposition: inline
In-Reply-To: <47F28B2F.2070609@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 01, 2008 at 09:21:19PM +0200, Eric Dumazet (dada1@cosmosbay.com) wrote:
> I see no socket locking, so multiple threads could use sendfile() & 
> sendmsg() on same socket, and crash kernel...

How?
Those who use sendfile() automatically install page->lru.prev which is
checked in release path, only those with given value will be processed
as spliced (i.e. new callback).

It is safe to install new callback on skbs which were not spliced, since
for that skbs it will be pure sock_wfree().

-- 
	Evgeniy Polyakov
