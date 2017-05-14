From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: ipv6: Truncate single route when it doesn't fit into
 dump buffer.
Date: Sun, 14 May 2017 16:14:16 -0600
Message-ID: <fefe8b7a-3264-333a-bab3-7e0dd82efed1@gmail.com>
References: <20170512111510.2697-1-mq@ucw.cz>
 <20170512.112447.1421545301592945998.davem@davemloft.net>
 <3828cf04-1bf8-92d2-dfc4-184bd615fe10@gmail.com>
 <20170512214107.w3q7ycl6wm7phwox@lopatka.joja.cz>
 <6670aa0f-2f07-5afd-7c47-35b006c9b2e7@gmail.com>
 <20170513105401.iaialveoomahrmyq@lopatka.joja.cz>
 <f72f0622-f5d3-6a85-e8e8-15980c9f1f2d@gmail.com>
 <20170513172915.5ram3mlsy4ihzwmw@lopatka.joja.cz>
 <1494795637.2803.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mq@ucw.cz,
        netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>
To: Johannes Berg <johannes@sipsolutions.net>,
        Jan Moskyto Matejka <mq@jmq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33689 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752007AbdENWOY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 18:14:24 -0400
Received: by mail-io0-f194.google.com with SMTP id m4so10181516ioe.0
        for <netdev@vger.kernel.org>; Sun, 14 May 2017 15:14:24 -0700 (PDT)
In-Reply-To: <1494795637.2803.2.camel@sipsolutions.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/14/17 3:00 PM, Johannes Berg wrote:
> On Sat, 2017-05-13 at 19:29 +0200, Jan Moskyto Matejka wrote:
>>
>>> When adding a route to the skb, track whether it contains at least
>>> 1
>>> route. If not, it means the next route in the dump is larger than
>>> the
>>> given buffer. Detect this condition and error out of the dump -
>>> returning an error to the user (-ENOSPC? or EMSGSIZE?)
>>
>> EMSGSIZE seems OK for me.
> 
> If we return an error here, and consequently allow for userspace
> changes to pick this up, perhaps we could also consider allowing to
> split the dump between nexthops, so that arbitrary such things can be
> returned.

Returning an error should not impact existing userspace; it should
already be checking for an error response in the message.

Splitting the dump between nexthops across multiple messages will have
repercussions on userspace. I think (at least for rtnetlink and links,
addresses, routes) userspace needs to provide a buffer large enough for
a complete object. If we limit the number of nexthops to something
reasonable (e.g., 256), then ipv4 for example will be ~ 3kB + lwt encap
size we are talking on the order of an 8kb maybe 16kB buffer. That is a
reasonable request for the API.
