From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: ipv6: Truncate single route when it doesn't fit
 into dump buffer.
Date: Sun, 14 May 2017 23:00:37 +0200
Message-ID: <1494795637.2803.2.camel@sipsolutions.net>
References: <20170512111510.2697-1-mq@ucw.cz>
         <20170512.112447.1421545301592945998.davem@davemloft.net>
         <3828cf04-1bf8-92d2-dfc4-184bd615fe10@gmail.com>
         <20170512214107.w3q7ycl6wm7phwox@lopatka.joja.cz>
         <6670aa0f-2f07-5afd-7c47-35b006c9b2e7@gmail.com>
         <20170513105401.iaialveoomahrmyq@lopatka.joja.cz>
         <f72f0622-f5d3-6a85-e8e8-15980c9f1f2d@gmail.com>
         <20170513172915.5ram3mlsy4ihzwmw@lopatka.joja.cz>
         (sfid-20170513_192929_901880_287B83AA)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mq@ucw.cz,
        netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>
To: Jan Moskyto Matejka <mq@jmq.cz>, David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:38042 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759171AbdENVAq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 14 May 2017 17:00:46 -0400
In-Reply-To: <20170513172915.5ram3mlsy4ihzwmw@lopatka.joja.cz> (sfid-20170513_192929_901880_287B83AA)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-05-13 at 19:29 +0200, Jan Moskyto Matejka wrote:
> 
> > When adding a route to the skb, track whether it contains at least
> > 1
> > route. If not, it means the next route in the dump is larger than
> > the
> > given buffer. Detect this condition and error out of the dump -
> > returning an error to the user (-ENOSPC? or EMSGSIZE?)
> 
> EMSGSIZE seems OK for me.

If we return an error here, and consequently allow for userspace
changes to pick this up, perhaps we could also consider allowing to
split the dump between nexthops, so that arbitrary such things can be
returned.

We did a similar thing in nl80211 at some point - originally, a dump of
wireless devices present was doing a whole device per message, we later
allowed splitting a single device across multiple messages because
capability information was reaching a reasonable message size limit.

johannes
