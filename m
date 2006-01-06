From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 06 Jan 2006 12:33:32 -0800 (PST)
Message-ID: <20060106.123332.109879608.davem@davemloft.net>
References: <20060106164702.GA5087@us.ibm.com>
	<43BEA693.5010509@cosmosbay.com>
	<20060106202626.GA5677@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, alan@lxorguk.ukuu.org.uk, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, dipankar@in.ibm.com,
	manfred@colorfullife.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752548AbWAFUeD@vger.kernel.org>
To: paulmck@us.ibm.com
In-Reply-To: <20060106202626.GA5677@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@us.ibm.com>
Date: Fri, 6 Jan 2006 12:26:26 -0800

> If not, it may be worthwhile to limit the number of times that
> rt_run_flush() runs per RCU grace period.

This is mixing two sets of requirements.

rt_run_flush() runs periodically in order to regenerate the hash
function secret key.  Now, for that specific case it might actually be
possible to rehash instead of flush, but the locking is a little bit
tricky :-)  And also, I think we're regenerating the secret key
just a little bit too often, I think we'd get enough security
with a less frequent regeneration.

I'll look into this and your other ideas later today hopefully.
