From: Jan Moskyto Matejka <mq@jmq.cz>
Subject: Re: [PATCH] net: ipv6: Truncate single route when it doesn't fit
 into dump buffer.
Date: Fri, 12 May 2017 23:34:04 +0200
Message-ID: <20170512213404.rndcujbptjhhusww@lopatka.joja.cz>
References: <20170512111510.2697-1-mq@ucw.cz>
 <20170512.112447.1421545301592945998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mq@ucw.cz, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        dsa@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-84-242-100-228.net.upcbroadband.cz ([84.242.100.228]:44326
        "EHLO prague.ecotrend.cz" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750796AbdELVju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 17:39:50 -0400
Content-Disposition: inline
In-Reply-To: <20170512.112447.1421545301592945998.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 12, 2017 at 11:24:47AM -0400, David Miller wrote:
> From: Jan Moskyto Matejka <mq@ucw.cz>
> Date: Fri, 12 May 2017 13:15:10 +0200
> 
> > -int rt6_dump_route(struct rt6_info *rt, void *p_arg);
> > +int rt6_dump_route(struct rt6_info *rt, void *p_arg, int truncate);
> 
> Please use "bool" and "true"/"false" for boolean values.

Missed that, sorry. Will remember next time.

> What does ipv4 do in this situation?
> 
> I'm hesitant to be OK with adding a new nlmsg flag just for this case
> if we solve this problem differently and using existing mechanisms
> elsewhere.

IPv4 is broken the same way as IPv6, with the difference that
'ip route append' does not append a new multipath nexthop but
creates a whole new route.

It is probably impossible to create such a big route via iproute2 tool;
it is needed to open netlink socket by hand and write there the
attached file. (It is one nlmsg adding one huge multipath route.)

It should be also noted that 'ip monitor' gets the huge routes
truncated.

MQ
