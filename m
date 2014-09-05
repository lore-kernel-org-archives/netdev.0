From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net] core: Don't attempt to load the "" driver.
Date: Fri, 05 Sep 2014 14:32:41 -0700 (PDT)
Message-ID: <20140905.143241.114624370748725493.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D174856B9@AcuExch.aculab.com>
	<063D6719AE5E284EB5DD2968C1650D6D174862E0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950AbaIEVcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 17:32:42 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174862E0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 3 Sep 2014 08:55:21 +0000

> Requests like 'ifconfig ""' cause dev_load(net, "") be called, since
> request_module("") return 0 (success) this generates the error message:
> "Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev- instead."
> 
> Since dev_load() doesn't have to work, just ignore such names.
> 
> Signed-off-by: David Laight <david.laight@aculab.com>
> ---
> 
> V2: Added sign off.
> 
> If you search for the above error message, you'll find a lot of complaints.
> While the applications shouldn't be calling an SIOCxxx ioctl with ifr_name[0] == 0
> the kernel shouldn't be tracing the error either.
> 
> Due to the complaints from users, this might be a backport candidate.

I have to say that I don't like this.

Why is request_module("") signalled with success unconditionally?
A module didn't get loaded, so semantically this behavior makes
no sense at all.

I would rather than simply request_module() signal an error in this
case, and then _NOBODY_ has to have all of this duplicated logic to
check for name[0]=='\0' throughout all of the call chains leading to
request_module().
