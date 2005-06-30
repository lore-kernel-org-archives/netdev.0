From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] updates for [nf|ct]netlink and event API
Date: Thu, 30 Jun 2005 23:34:59 +0200
Message-ID: <20050630213459.GO16076@postel.suug.ch>
References: <42C2F2DF.7070301@eurodev.net> <42C2FC14.80609@trash.net>
	<42C33E33.7090908@eurodev.net> <42C34445.9020709@trash.net>
	<20050630014901.GH16076@postel.suug.ch>
	<42C350A1.1030602@trash.net>
	<20050630120302.GI16076@postel.suug.ch> <42C3F35B.50805@trash.net>
	<20050630180238.GM16076@postel.suug.ch>
	<42C46374.5000407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@netfilter.org>, netdev@vger.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Pablo Neira <pablo@eurodev.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42C46374.5000407@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <42C46374.5000407@trash.net> 2005-06-30 23:26
> Thomas Graf wrote:
> > * Patrick McHardy <42C3F35B.50805@trash.net> 2005-06-30 15:27
> >
> >>I think for nested attributes error handling should happen on the
> >>outer level. Just trimming on the inner level would leave a
> >>half-finished nested attribute.
> > 
> > I can agree with this, the question that remains is: do we want
> > to trim in functions where no nesting is done at all? i.e. things
> > like the generic network statistics dumping interface.
> 
> Trimming isn't required in this case since the length is know and
> checked in advance. An error should still be propagated back of
> course so potential outer levels can do trimming.

This is only true if one attribute is added. What I really meant
is something like em_text_dump() in em_text.c. Assuming we rework
areas like this one in order to avoid structs on the stack, we'll
have a lot of such cases where we might hit the limit while not
really knowing about the start of the nested tlv.

Anyways, I think this is a minor issue and we can safely ignore it
and delegate the trimming responsibility to the underlying layer
which "started" the nested tlv.

The gnet_stats interface was a bad example since it doesn't have
such a case.
