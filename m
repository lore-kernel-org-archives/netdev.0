From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6] generic network statistics (was Re: [6/6]: jenkins hash for neigh / Statistics)
Date: Tue, 28 Sep 2004 15:33:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928133334.GW31616@rei.reeler.org>
References: <20040925005623.2faf8faf.davem@davemloft.net> <E1CBu70-00010X-00@gondolin.me.apana.org.au> <20040927121403.767e2308.davem@davemloft.net> <20040927222613.GE3236@sunbeam.de.gnumonks.org> <20040927160636.7741d973.davem@davemloft.net> <1096327658.1729.19.camel@localhost.localdomain> <16729.9326.93269.422940@robur.slu.se> <20040928111906.GB29961@sunbeam.de.gnumonks.org> <1096375700.8659.235.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@gnumonks.org>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1096375700.8659.235.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Speaking of generic stats; i have a patch netlink ready which may need
> some extensions. I did post it  a while back on netdev but didnt get
> feedback.

The code looks good and I couldn't spot any errors but I'm not
sure if the locking in gen_copy_[x]stats is a good thing.
Shouldn't that be done earlier by the caller? This prevents
corruption but it allows duplicated TLVs in an skb. I suggest
to make the caller have a lock on his data and only allow one
dumper at the same time until the dump is complete, or at least
provide a lockless variant for callers doing the locking on
their own.
