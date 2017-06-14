From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 00/11] skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:11:54 +0200
Message-ID: <1497471114.9377.9.camel@sipsolutions.net>
References: <1497452424.3765.3.camel@163.com>
         <1497457773.9377.2.camel@sipsolutions.net>
         <1497457908.9377.4.camel@sipsolutions.net>
         <20170614.153850.858684905893972084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: cugyly@163.com, netdev@vger.kernel.org,
        Linyu.Yuan@alcatel-sbell.com.cn
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:41344 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751960AbdFNUMC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 16:12:02 -0400
In-Reply-To: <20170614.153850.858684905893972084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-14 at 15:38 -0400, David Miller wrote:

> What do you think about Stephen Hemminger's feedback to make
> skb_put_zero() return "void *".  It will avoid a lot of casts and
> make the conversions look nicer.

I think it's a good idea. I can send a patch, and remove some casts
where they exist - I guess we could also do it even for skb_put()
eventually.

> I'll also defer on this patch series until we have the spatch thing
> which can catch all of them.

I think I have something that covers most cases, will send out an RFC
in a minute (since I'm not sure I was able to build it all yet).

Note that some of the cases like in ipv6/ndisc.c certainly can't be
done automatically, they look correct but are more complicated because
there's not just a single big memset(), but they're doing it piece by
piece (fill some bytes, clear some others, etc.) Might be worth
checking which aren't covered by the spatch.

johannes
