From: Jan Moskyto Matejka <mq@jmq.cz>
Subject: Re: [PATCH] net: ipv6: Truncate single route when it doesn't fit
 into dump buffer.
Date: Sat, 13 May 2017 19:29:15 +0200
Message-ID: <20170513172915.5ram3mlsy4ihzwmw@lopatka.joja.cz>
References: <20170512111510.2697-1-mq@ucw.cz>
 <20170512.112447.1421545301592945998.davem@davemloft.net>
 <3828cf04-1bf8-92d2-dfc4-184bd615fe10@gmail.com>
 <20170512214107.w3q7ycl6wm7phwox@lopatka.joja.cz>
 <6670aa0f-2f07-5afd-7c47-35b006c9b2e7@gmail.com>
 <20170513105401.iaialveoomahrmyq@lopatka.joja.cz>
 <f72f0622-f5d3-6a85-e8e8-15980c9f1f2d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mq@ucw.cz,
        netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-84-242-100-228.net.upcbroadband.cz ([84.242.100.228]:44474
        "EHLO prague.ecotrend.cz" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752422AbdEMR3W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 13 May 2017 13:29:22 -0400
Content-Disposition: inline
In-Reply-To: <f72f0622-f5d3-6a85-e8e8-15980c9f1f2d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 13, 2017 at 11:13:38AM -0600, David Ahern wrote:
> On 5/13/17 4:54 AM, Jan Moskyto Matejka wrote:
> >> I see 2 problems:
> >> 1. the kernel is not telling the user the supplied buffer is too small
> >> (ie., if a single route does not fit in the skb then it should fail and
> >> return an error code to the user),
> > 
> > Definitely. I want just to note that this condition usually occurs
> > somewhere during route dump. To know it before starting output, we would 
> > have to walk the FIB once before dump to calculate max route len.
> 
> When adding a route to the skb, track whether it contains at least 1
> route. If not, it means the next route in the dump is larger than the
> given buffer. Detect this condition and error out of the dump -
> returning an error to the user (-ENOSPC? or EMSGSIZE?)

EMSGSIZE seems OK for me.
