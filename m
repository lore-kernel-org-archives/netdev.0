From: David Miller <davem@davemloft.net>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 18:54:41 -0700 (PDT)
Message-ID: <20090318.185441.138157931.davem@davemloft.net>
References: <1237425191.8204.41.camel@quadrophenia.thebigcorporation.com>
	<20090318.181713.62394874.davem@davemloft.net>
	<1237427007.8204.55.camel@quadrophenia.thebigcorporation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ghaskins@novell.com, vernux@us.ibm.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, pmullaney@novell.com
To: sven@thebigcorporation.com
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <1237427007.8204.55.camel@quadrophenia.thebigcorporation.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sven-Thorsten Dietrich <sven@thebigcorporation.com>
Date: Wed, 18 Mar 2009 18:43:27 -0700

> Do we have to rule-out per-CPU queues, that aggregate into a master
> queue in a batch-wise manner? 

That would violate the properties and characteristics expected by
the packet scheduler, wrt. to fair based fairness, rate limiting,
etc.

The only legal situation where we can parallelize to single device
is where only the most trivial packet scheduler is attached to
the device and the device is multiqueue, and that is exactly what
we do right now.
