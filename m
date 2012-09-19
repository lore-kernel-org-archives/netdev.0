From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: only run neigh_forced_gc() from one cpu
Date: Wed, 19 Sep 2012 13:07:05 +0200
Message-ID: <1348052825.26523.676.camel@edumazet-glaptop>
References: <1348046827.26523.571.camel@edumazet-glaptop>
	 <20120919105038.GA12352@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Tom Herbert <therbert@google.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45657 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330Ab2ISLHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 07:07:12 -0400
Received: by bkwj10 with SMTP id j10so435770bkw.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 04:07:11 -0700 (PDT)
In-Reply-To: <20120919105038.GA12352@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 06:50 -0400, Neil Horman wrote:

> This is going to cause callers in neigh_alloc to immediately fail their
> allocation attempts.  Would it be a good idea to modify that call site so that
> instead of returning NULL, instead reread tbl->entries before comparing to
> gc_thresh3, on the hope that the cpu in the garbage collecting routine has freed
> some entries?

neigh_alloc() fails only if gc_thresh3 is hit, and if it is hit, we are
under attack by definition.

(the gc is run every 5 seconds is above gc_thresh2, and below
gc_thresh3)

No matter what you try, the attacker is going to be the winner.

The best thing here is to drop packets, not spending several milli
seconds to serve one packet, as queues are going to tail drop anyway.
