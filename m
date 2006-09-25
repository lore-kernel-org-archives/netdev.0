From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Advertise PPPoE MTU / avoid memory leak.
Date: Sun, 24 Sep 2006 18:41:18 -0700 (PDT)
Message-ID: <20060924.184118.104036249.davem@davemloft.net>
References: <115903262344-git-send-email-mostrows@earthlink.net>
	<20060923.145600.51855973.davem@davemloft.net>
	<1159100966.23197.293.camel@brick.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ppp-bugs@dp.samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13515
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932216AbWIYBlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 21:41:16 -0400
To: mostrows@earthlink.net
In-Reply-To: <1159100966.23197.293.camel@brick.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Ostrowski <mostrows@earthlink.net>
Date: Sun, 24 Sep 2006 07:29:25 -0500

> I think the call path via dev->hard_start_xmit, if it fails, may result
> in an skb not being freed.  This appears to be the case with the e100.c
> driver.  The qdisc_restart path to dev->hard_start_xmit also appears
> susceptible to this.  It appears that not all devices agree as to who
> should clean-up an skb on error.

There is a well defined policy about who frees the SKB or has
ownership of it based upon dev->hard_start_xmit() return values.

Any driver deviating from this set of rules should simply be
audited and fixed, as needed.

But, no matter, your change is buggy and we can't apply your
patch (even if it does fix a leak in some legitimate case)
because it introduces an obvious double-free bug.
