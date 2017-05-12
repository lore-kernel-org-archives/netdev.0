From: Jan Moskyto Matejka <mq@jmq.cz>
Subject: Re: [PATCH] net: ipv6: Truncate single route when it doesn't fit
 into dump buffer.
Date: Fri, 12 May 2017 23:41:08 +0200
Message-ID: <20170512214107.w3q7ycl6wm7phwox@lopatka.joja.cz>
References: <20170512111510.2697-1-mq@ucw.cz>
 <20170512.112447.1421545301592945998.davem@davemloft.net>
 <3828cf04-1bf8-92d2-dfc4-184bd615fe10@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mq@ucw.cz,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        dsa@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Ahern <dsahern@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3828cf04-1bf8-92d2-dfc4-184bd615fe10@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 12, 2017 at 10:26:08AM -0700, David Ahern wrote:
> On 5/12/17 8:24 AM, David Miller wrote:
> > From: Jan Moskyto Matejka <mq@ucw.cz>
> > Date: Fri, 12 May 2017 13:15:10 +0200
> > 
> >> -int rt6_dump_route(struct rt6_info *rt, void *p_arg);
> >> +int rt6_dump_route(struct rt6_info *rt, void *p_arg, int truncate);
> > 
> > Please use "bool" and "true"/"false" for boolean values.
> > 
> > What does ipv4 do in this situation?
> > 
> > I'm hesitant to be OK with adding a new nlmsg flag just for this case
> > if we solve this problem differently and using existing mechanisms
> > elsewhere.
> > 
> 
> I'll take a look at this later today or this weekend; we can't just
> truncate the route returned to userspace.

Agreed. My favourite would be skb realloc somewhere inside the dump loop
... but I don't know whether it's feasible.

MQ
