From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: Mon, 26 Jan 2004 16:24:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040126152409.GA10053@louise.pinerecords.com>
References: <20040125152419.GA3208@penguin.localdomain> <20040125164431.GA31548@louise.pinerecords.com> <1075058539.1747.92.camel@jzny.localdomain> <20040125202148.GA10599@usr.lcm.msu.ru> <1075074316.1747.115.camel@jzny.localdomain> <20040126001102.GA12303@usr.lcm.msu.ru> <1075086588.1732.221.camel@jzny.localdomain> <20040126093230.GA17811@usr.lcm.msu.ru> <1075124312.1732.292.camel@jzny.localdomain> <20040126135545.GA19497@usr.lcm.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Content-Disposition: inline
In-Reply-To: <20040126135545.GA19497@usr.lcm.msu.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Jan-26 2004, Mon, 16:55 +0300
Vladimir B. Savkin <master@sectorb.msk.ru> wrote:

>                     +---------+       +-ppp0- ... - client0
>                     |         +-eth1-<+-ppp1- ... - client1
> Internet ----- eth0-+ router  |     . . . . . . . .
>                     |         +-eth2-<  . . . . . .
>                     +---------+       +-pppN- ... - clientN

Actually, this is very much like what we're using IMQ for:

                  +-----------+ eth1 --- \
                  | shaper    + eth2 ---
Internet --- eth0 + in bridge + .    ---    ... WAN (10 C's of customer IPs)
                  | setup     + .    ---
                  +-----------+ ethN --- /

We're shaping single IPs and groups of IPs, applying tariff rates
on the sum of inbound and outbound flow (this last point, I'm told,
is the primary reason for our use of IMQ).  The machine also does
IP accounting (through custom userland software based on libpcap)
and has to be an ethernet bridge so that it can be replaced by
a piece of wire should it fail and there was no backup hardware left.

At this moment we're on sfq/u32/htb/IMQ/mangle.  We've figured out
that unless we mess with iptable_nat, IMQ-enabled kernels will work
perfectly reliably (SNAT in particular seems deadly).  We don't
insist on IMQ.  In fact, we would be very grateful if somebody
could point us to an alternative mechanism to IMQ that would allow
us to effectively shape by the sum of both traffic directions of
a given IP, as we'd like to deploy "shaping firewalls" that would
also do SNAT.

-- 
Tomas Szepe <szepe@pinerecords.com>
