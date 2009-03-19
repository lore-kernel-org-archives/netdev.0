From: Sven-Thorsten Dietrich <sven@thebigcorporation.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 18:13:11 -0700
Message-ID: <1237425191.8204.41.camel@quadrophenia.thebigcorporation.com>
References: <49C16349.9030503@us.ibm.com>
	 <20090318.143844.173112261.davem@davemloft.net>
	 <49C16D7C.3080003@novell.com>
	 <20090318.180355.228447835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ghaskins@novell.com, vernux@us.ibm.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, pmullaney@novell.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f118.google.com ([209.85.221.118]:38118 "EHLO
	mail-qy0-f118.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767AbZCSBUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 21:20:19 -0400
Received: by qyk16 with SMTP id 16so437532qyk.33
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 18:20:17 -0700 (PDT)
In-Reply-To: <20090318.180355.228447835.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-03-18 at 18:03 -0700, David Miller wrote:
> From: Gregory Haskins <ghaskins@novell.com>
> Date: Wed, 18 Mar 2009 17:54:04 -0400
> 
> > Note that -rt doesnt typically context-switch under contention anymore
> > since we introduced adaptive-locks.  Also note that the contention
> > against the lock is still contention, regardless of whether you have -rt
> > or not.  Its just that the slow-path to handle the contended case for
> > -rt is more expensive than mainline.  However, once you have the
> > contention as stated, you have already lost.
> 
> First, contention is not implicitly a bad thing.
> 

Its a bad thing when it does not scale.

> Second, if the -rt kernel is doing adaptive spinning I see no
> reason why that adaptive spinning is not kicking in here to
> make this problem just go away.
> 

If only the first of N contending threads gets to spin, 2..N would
context-switch.


> This lock is held for mere cycles, just to unlink an SKB from
> the networking qdisc, and then it is immediately released.

For very short hold times, and heavy contention, as well as for
scalability, the solution may lie in tunable spinner-count and adaptive
spinner time-out.

Sven

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rt-users" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

