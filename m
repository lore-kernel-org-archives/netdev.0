From: =?iso-8859-2?B?TWljaGFsIFL5vmnoa2E=?= <michal.ruzicka@comstar.cz>
Subject: Re: multicast group memberships purge on interface delete
Date: Wed, 23 Aug 2006 15:29:45 +0200
Message-ID: <039601c6c6b8$47b0f7a0$2303a8c0@mruzicka>
References: <20060809.195627.59155708.yoshfuji@linux-ipv6.org> <44D9D431.10101@tcs.hut.fi>	<44DA558A.1080706@tcs.hut.fi> <20060810.174635.42119608.yoshfuji@linux-ipv6.org> <44DB0870.6000902@tcs.hut.fi> <019901c6bc75$872ee1f0$2303a8c0@mruzicka> <021e01c6c6a4$6e7845f0$2303a8c0@mruzicka> <1156336331.5035.79.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-2";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateplz-adsl.comstar.cz ([193.179.24.196]:62393 "EHLO
	gateplz.comstar.cz") by vger.kernel.org with ESMTP id S932150AbWHWNbE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 09:31:04 -0400
To: <hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>
> You should be able to "fix it" in the kernel by listening to events of
> the interface/device disappearing.

Interesting, I've thought that it would have to be done explicitly by the 
interface
cleanup code, this approach looks promising to me.

> By "disappearing" i think you meant
> the netdevice was totally rmmod-ed?

No need to rmmod anything, just think of ppp or gre interfaces which come 
and go
without any modules loading/unloading. But yes, the rmmod would probably be
needed in case of, for example, an ethernet device.

> The challenge is to make the app
> also aware of you taking away the group from underneath them (thats why
> i said "fix it")
>

I dont's see this as any challange as the applications could just assume 
that any
memberships on deleted interfaces have been just droped implicitly by the 
kernel.
(This should be no problem for them provided that they keep track of
the interfaces present on the system, which they should anyway or otherwise
they could end up listening to just a part of the multicast traffic they are
interested in.)

>
> These events are also available in user space via netlink. so an alter
> your app could listen to them and make the group leaves instead of the
> kernel.
>

In fact I've had proposed that on the application mailing list (the 
appliaction is
quagga formerly zebra routing suite to be specific) but the people there 
disliked
it because of the fact that for example the NetBSD (as I noted in my 
previous
post) does the group leaves implicitly on the interface delete and the 
explicit
group leaves fail there (and reportedly on other OSes too).
Sure this can solved by some conditional compilation.
This is why my post was more a theoretical design question/suggestion than
a feature request (or a bug report).

In this sense what do you think about the possible benefit of the proposed
approach for maintaning the per-interface multicast reception state?

> cheers,
> jamal
>

Thanks
Michal 

