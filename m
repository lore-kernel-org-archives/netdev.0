From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: Quick Blind TCP Connection Spoofing with SYN Cookies
Date: Fri, 16 Aug 2013 01:57:43 +0200
Message-ID: <20130815235743.GA25665@midget.suse.cz>
References: <520A3B4A.1050704@jakoblell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jakob Lell <jakob@jakoblell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46139 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540Ab3HOX5s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 19:57:48 -0400
Content-Disposition: inline
In-Reply-To: <520A3B4A.1050704@jakoblell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 03:57:30PM +0200, Jakob Lell wrote:
> VIII. Possible mitigation options
> 
> The simplification of TCP Connection Spoofing described here is an
> inherent problem of TCP SYN Cookies and so there won't be a simple
> patch which just solves the issue and makes the Spoofing Attack as
> hard as it is without SYN Cookies. It is only possible to gradually
> increase the required effort for successfully spoofing a connection
> e.g. by only accepting the last two instead of four counter values
> (which will lead to a 60-120s 

If the counter is slowed down 4 times, accepting only two
values should result in similar behaviour as we have today.

Can anyone think of a reason this should not be done?


Additionally, I believe we should reduce the number of possible MSS
values. I think 3 values should be enough - not supporting jumbo
frames and wasting a few bytes on sub-optimal MSS around 1400
bytes should be acceptable when a system is under a DoS attack.

I have 3 patches doing just that:

1 - slow down the timer and improve the situation by a factor of 2
2 - since not everyone will be happy with exactly 3 MSS values,
    let's make this configurable via sysctl
3 - decrease the default number of MSS values to 3 and improve
    the situation by a factor of 8/3

These patches combined make the attack 5.3 times harder. By
using the sysctl to only set two possible MSSs, one can make
the attack 8 times harder - and only 4 times easier than
previously believed.

The patches are compile-tested only.

Thoughts?


-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
