From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: PATCH: netdev: add a cast NLMSG_OK to avoid a GCC warning in
 users' code
Date: Fri, 11 Sep 2015 08:42:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB922FF@AcuExch.aculab.com>
References: <alpine.LRH.2.02.1509080933340.4754@redclaw.mimosa.com>
 <20150909.123717.2263645868892698375.davem@davemloft.net>
 <alpine.LRH.2.02.1509091555230.4754@redclaw.mimosa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'D. Hugh Redelmeier'" <hugh@mimosa.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.193]:60826 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbbIKIno convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 04:43:44 -0400
In-Reply-To: <alpine.LRH.2.02.1509091555230.4754@redclaw.mimosa.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: D. Hugh Redelmeier
> Sent: 09 September 2015 21:24
...
> 2) if you use the type "unsigned int" on a 32-bit machine, you get the
>    warning for an earlier conjunct:
> 
> #define NLMSG_OK(nlh,len) ((len) >= (int)sizeof(struct nlmsghdr) && \
> 			   (nlh)->nlmsg_len >= sizeof(struct nlmsghdr) && \
> 			   (nlh)->nlmsg_len <= (len))
> 
>    (len) >= (int)sizeof(struct nlmsghdr)  <=== unsigned >= int
> 
> 3) on a 32-bit machine, size_t is likely "unsigned int" so the
>    same problem as (2) should arise.
> 
> 4) on a 64-bit machine with 64-bit ints, the same problems are likely.
>    I don't have one to test on.
> 
> Casting to "short" or "unsigned short" works, but I don't know that
> the value is guaranteed to fit in either of them.

Why not cast (nlh)->nl_msg_len instead?
Or subtract the two values and compare against zero?
Perhaps:
	(typeof (len))(nlh)->nlmsg_len <= (len)
which is almost certainly safe unless 'len' is 'signed char'.

	David
