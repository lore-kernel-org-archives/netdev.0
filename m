From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Subject: Re: [PATCH] isdn: Return -EINTR in gigaset_start() if locking
 attempts fails.
Date: Sat, 17 Mar 2012 21:26:14 +0530
Message-ID: <CAOD=uF6JJiiGjQwybzwdU3Zw9pC8YbDPxm_Pg9E9WNAXbfTiUQ@mail.gmail.com>
References: <1331903413-11426-1-git-send-email-santoshprasadnayak@gmail.com>
	<20120316.231856.1071253468993560433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hjlipp@web.de, tilman@imap.cc, isdn@linux-pingi.de,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-media@vger.kernel.org, kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:47233 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756479Ab2CQP4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 11:56:14 -0400
In-Reply-To: <20120316.231856.1071253468993560433.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes. You are right.

Caller is interpreting 0 in opposite way of normal sequence.
Thats why I misunderstood it.

In general, 0 means success and on error we return -ve.
Here its opposite.




regards
Santosh



On Sat, Mar 17, 2012 at 11:48 AM, David Miller <davem@davemloft.net> wrote:
> From: santosh nayak <santoshprasadnayak@gmail.com>
> Date: Fri, 16 Mar 2012 18:40:13 +0530
>
>> We have 3 callers: gigaset_probe(), gigaset_tty_open() and
>> gigaset_probe(). Each caller tries to free allocated memory
>> if lock fails. This is possible if we returns -EINTR.
>
> Look again at the callers.
>
> They interpret "0" as an error, so your patch would break the driver.
