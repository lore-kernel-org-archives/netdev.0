From: Thomas Graf <tgraf@suug.ch>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 16:59:29 +0100
Message-ID: <20050131155929.GF31837@postel.suug.ch>
References: <1107123123.8021.80.camel@jzny.localdomain> <20050131135810.GC31837@postel.suug.ch> <1107181169.7840.184.camel@jzny.localdomain> <20050131151532.GE31837@postel.suug.ch> <1107186044.1076.11.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1107186044.1076.11.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> My experience is that you end up dropping no more than a packet in a
> burst with policing before TCP adjusts. Also depending on the gap
> between bursts, that may be the only packet you drop altogether.
> In long flows such as file transfers, avergae of one packet ever gets
> dropped.

I mostly agree but not completely. It's definitely true that most of
the problems I'm fighting today are causes by the attempt to be too
perfect in calculating. Going a step backwards solves most of the
problems and probably works just fine for most cases. One of the main
problem I'm facing here are big file transfers on low latency links with
modified ip stacks to allow for a "faster" slow start (those are the
reason why I'm trying to do this). An attempt to drop only a few
packets results in a stronger incremenal growth. I'm not quite sure
why that happens yet but a more aggresive policing stategy helped a
lot. I agree that if we plan to put something like this into mainline
those problem domains should be separated to not overcomlicate the
whole thing.

> checksum and other validity of ip header will have to be written as an
> action if needed. Infact csum is on my list of mini actions. I could
> decide to change something on egress of outgoing ip packet in pedit
> and would therefore require to recompute csum.

Sounds good. We'll need to address this anyway, the classifiers rely
on the ip header being valid which is no longer assured.

> Ok, I think both approaches are correct. ematch does the check/get
> essentially; and action will create the set/tracking if needed.
> For the example i gave, you are absolutely correct, ematch is
> sufficient.

Right, so we can do something like the meta ematch/action split. What
attributes to you intend to be modifieable? A neat thing would be
to overwrite the state and thus assign a packet to another connection
which could be used to reimplement fast nat together with pedit.
