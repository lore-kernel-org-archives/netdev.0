From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Tue, 2 Dec 2003 01:30:17 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312020120020.2728-100000@u.domain.uli>
References: <20031201204700.GA20349@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031201204700.GA20349@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 2 Dec 2003, Herbert Xu wrote:

> On Tue, Dec 02, 2003 at 07:16:51AM +1100, herbert wrote:
> >
> > I found out that PMTU only works on those routing cache entries where
> > rt_src != 0.  This patch should make it work for all matching entries.
>
> That patch removed one line too many.  This one should be better.

	IMO, the rt_src check in ip_rt_frag_needed is ok.

	I would suspect all rth->fl.fl4_tos checks too.
It seems we need toskeys[2] and a second for loop if tos!=0.
What about rewriting them to (rth->fl.fl4_tos == toskeys[j]).

Regards

--
Julian Anastasov <ja@ssi.bg>
