From: Thomas Graf <tgraf@suug.ch>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: Wed, 29 Sep 2004 14:48:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929124832.GA9634@postel.suug.ch>
References: <1093904088.1043.12.camel@jzny.localdomain> <20040830154430.769d1d59.davem@redhat.com> <1093906592.1037.32.camel@jzny.localdomain> <20040830160052.548c4846.davem@redhat.com> <1093916592.1037.51.camel@jzny.localdomain> <20040830191716.0d002f91.davem@redhat.com> <1093919823.1043.80.camel@jzny.localdomain> <20040830212910.78047bcd.davem@davemloft.net> <20040929003656.GX31616@rei.reeler.org> <1096426464.1045.133.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1096426464.1045.133.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1096426464.1045.133.camel@jzny.localdomain> 2004-09-28 22:54
> Lets do it on gnet stats though so we can make it more accessible.
> I think your granularity maybe too thin: bytes,packets, drops
> may need to be in the same TLV.

I partially agree as long as no structs visible to userspace will
ever change after introduction.

I'd really like to avoid maintaining different structs for collection
and transfer which must be kept in sync.

Having the application do its own struct and fill it based on
if (tb[TCA_STATS_*]) conditions avoids all possible compatibility 
issues. It would be possible for the application to choose between
the original and a _64 variant if we ever introduce them.

So this would be my approach:

Leave gnet_stats as-is and extend it as needed but hide it from
userspace.

Extend gen_copy_stats to add a nested TLV for every stat in
the structure. We could even introduce a bitmap to allow the
struct gnet_stats user to define which statistics are defined
and which aren't. This way we could avoid the mess with pfifo
and bfifo both using backlog but with a different unit in mind
(packets/bytes).

> do you have cycles to run with that patch?

Yes, it is related to my work so it's not a problem.
