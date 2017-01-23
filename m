From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Make xfrm usable by 32-bit programs
Date: Mon, 23 Jan 2017 11:57:22 -0500 (EST)
Message-ID: <20170123.115722.2044116177906799668.davem@davemloft.net>
References: <20170121000507.34381-1-cernekee@chromium.org>
        <063D6719AE5E284EB5DD2968C1650D6DB026BC58@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cernekee@chromium.org, steffen.klassert@secunet.com,
        herbert@gondor.apana.org.au, paul@paul-moore.com,
        sds@tycho.nsa.gov, eparis@parisplace.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        selinux@tycho.nsa.gov, fw@strlen.de, fan.du@windriver.com,
        dianders@chromium.org, dtor@chromium.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44992 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbdAWQ5Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 11:57:25 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB026BC58@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 23 Jan 2017 16:45:39 +0000

> Provided you've got the length of the user's buffer the compat code
> ought to be trivial (if tedious).

Wireless guys had to deal with a similar problem with nl80211.

You don't know who is going to get the message when you build it,
because you can't possibly know what applications are listening
on the netlink sockets for notifications and even if you did
that set changes dynamically and could be different by the time
the notification is delivered.

The long and short of it is that you must always generate both the
native 64-bit as well as the 32-bit compat version of every message,
then at delivery time you enqueue the appropriate one to each
receiving socket.

This is how nl80211 solved the problem, and it's what XFRM should do
as well.
