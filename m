From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH v2] sctp: fix incorrect overflow check on autoclose
Date: Thu, 15 Dec 2011 17:13:28 -0500
Message-ID: <0BF79838-C86F-4C3F-8D51-4223D579764C@gmail.com>
References: <1323393883-3759-1-git-send-email-xi.wang@gmail.com> <4EE919B5.3090901@gmail.com> <4EEA6176.9020704@hp.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrei Pelinescu-Onciul <andrei@iptel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:48120 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756377Ab1LOWNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 17:13:33 -0500
In-Reply-To: <4EEA6176.9020704@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 15, 2011, at 4:07 PM, Vlad Yasevich wrote:
> I think it would be better to keep this value in seconds and get rid
> of division in the setsockopt code.  We could then have a min and max
> values where max value could be something like 2 days.  I really don't
> see an autoclose value that is bigger then that being very useful.  In
> fact, most of the time these values are very small as one wants to close
> out idle associations.

Now I start to think exposing a new sysctl option might be a little
overkill since autoclose is often small.

How about this?

1) Simply store autoclose in seconds in setsockopt.

2) Avoid overflow in associola.c.

	asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE] =
		(sp->autoclose > MAX_SCHEDULE_TIMEOUT / HZ)
		? MAX_SCHEDULE_TIMEOUT
		: (unsigned long)sp->autoclose * HZ;

Or we could use INT_MAX instead of MAX_SCHEDULE_TIMEOUT if you want to
keep that value consistent across 32/64 bits.

- xi
