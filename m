From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Sun, 10 Oct 2004 20:59:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041010205928.6e54df7e.davem@davemloft.net>
References: <20041006232544.53615761@jack.colino.net>
	<20041006214322.GG31237@waste.org>
	<20041007075319.6b31430d@jack.colino.net>
	<20041006234912.66bfbdcc.davem@davemloft.net>
	<20041007160532.60c3f26b@pirandello>
	<20041007112846.5c85b2d9.davem@davemloft.net>
	<20041007224422.1c1bea95@jack.colino.net>
	<20041007214505.GB31558@wotan.suse.de>
	<20041008090610.70d7e183@pirandello>
	<20041008220001.GE31237@waste.org>
	<20041008151839.01823e0c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, colin@colino.net, ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041008151839.01823e0c.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Wait, I think I see the problem.

Sungem processes link status in it's ->poll() NAPI handler.
This occurs via calls to gem_pcs_interrupt(), for example.
Non-pcs sungem variants use a timer to poll link status.

When the link changes state, this link state processing
does printk()'s.

So perhaps that is why it deadlocks.
