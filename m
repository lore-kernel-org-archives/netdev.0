From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] generic network statistics (was Re: [6/6]: jenkins
	hash for neigh / Statistics)
Date: 28 Sep 2004 22:22:07 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096424527.1044.94.camel@jzny.localdomain>
References: <20040925005623.2faf8faf.davem@davemloft.net>
	 <E1CBu70-00010X-00@gondolin.me.apana.org.au>
	 <20040927121403.767e2308.davem@davemloft.net>
	 <20040927222613.GE3236@sunbeam.de.gnumonks.org>
	 <20040927160636.7741d973.davem@davemloft.net>
	 <1096327658.1729.19.camel@localhost.localdomain>
	 <16729.9326.93269.422940@robur.slu.se>
	 <20040928111906.GB29961@sunbeam.de.gnumonks.org>
	 <1096375700.8659.235.camel@jzny.localdomain>
	 <20040928133334.GW31616@rei.reeler.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040928133334.GW31616@rei.reeler.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-28 at 09:33, Thomas Graf wrote:
> > Speaking of generic stats; i have a patch netlink ready which may need
> > some extensions. I did post it  a while back on netdev but didnt get
> > feedback.
> 
> The code looks good and I couldn't spot any errors but I'm not
> sure if the locking in gen_copy_[x]stats is a good thing.
> Shouldn't that be done earlier by the caller? 

In the netsched code that became a portability issue; Dave fixed it
there, so i just replicated here. If you feel like doing something
clever you are welcome to submit a patch.

> This prevents
> corruption but it allows duplicated TLVs in an skb. I suggest
> to make the caller have a lock on his data and only allow one
> dumper at the same time until the dump is complete, or at least
> provide a lockless variant for callers doing the locking on
> their own.
> 

Reminds me:
gnet_stats needs to have TLVs embedded in it.
bytes,drops, packets are generic enough; others are not.
So if we add a length field then we can add TLVs for things like
QSTATS = { qlen, backlog}  etc.
This means we could then allow for adding a lot of different
stats. A big lesson from current tc_stats.

cheers,
jamal
