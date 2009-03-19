From: David Miller <davem@davemloft.net>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 18:03:55 -0700 (PDT)
Message-ID: <20090318.180355.228447835.davem@davemloft.net>
References: <49C16349.9030503@us.ibm.com>
	<20090318.143844.173112261.davem@davemloft.net>
	<49C16D7C.3080003@novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vernux@us.ibm.com, andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org,
	pmullaney@novell.com
To: ghaskins@novell.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757992AbZCSBEY@vger.kernel.org>
In-Reply-To: <49C16D7C.3080003@novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gregory Haskins <ghaskins@novell.com>
Date: Wed, 18 Mar 2009 17:54:04 -0400

> Note that -rt doesnt typically context-switch under contention anymore
> since we introduced adaptive-locks.  Also note that the contention
> against the lock is still contention, regardless of whether you have -rt
> or not.  Its just that the slow-path to handle the contended case for
> -rt is more expensive than mainline.  However, once you have the
> contention as stated, you have already lost.

First, contention is not implicitly a bad thing.

Second, if the -rt kernel is doing adaptive spinning I see no
reason why that adaptive spinning is not kicking in here to
make this problem just go away.

This lock is held for mere cycles, just to unlink an SKB from
the networking qdisc, and then it is immediately released.
