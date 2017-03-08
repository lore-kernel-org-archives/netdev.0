From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 2/2] iproute2: add support for invisible qdisc dumping
Date: Wed, 8 Mar 2017 11:40:19 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1703081138180.31814@cbobk.fhfr.pm>
References: <alpine.LSU.2.20.1702252228010.24579@cbobk.fhfr.pm> <20170227115218.GO6099@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170227115218.GO6099@orbyte.nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 27 Feb 2017, Phil Sutter wrote:

> > Support the new TCA_DUMP_INVISIBLE netlink attribute that allows asking 
> > kernel to perform 'full qdisc dump', as for historical reasons some of the 
> > default qdiscs are being hidden by the kernel.
> > 
> > The command syntax is being extended by voluntary 'invisible' argument to
> > 'tc qdisc show'.
> > 
> > Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> > ---
> >  tc/tc_qdisc.c | 25 +++++++++++++++++++++++--
> >  1 file changed, 23 insertions(+), 2 deletions(-)
> 
> Would you mind adding a description of the new keyword to tc man page as
> well?

Seems like tc manpage would need more updates, as it doesn't seem to 
reflect the '[ ingress | clsact ]' possibility either. So I'll send this 
as a followup patch, fixing all these at once.

> > diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
> > index 3a3701c2..29da9269 100644
> > --- a/tc/tc_qdisc.c
> > +++ b/tc/tc_qdisc.c
> > @@ -34,7 +34,7 @@ static int usage(void)
> >  	fprintf(stderr, "       [ stab [ help | STAB_OPTIONS] ]\n");
> >  	fprintf(stderr, "       [ [ QDISC_KIND ] [ help | OPTIONS ] ]\n");
> >  	fprintf(stderr, "\n");
> > -	fprintf(stderr, "       tc qdisc show [ dev STRING ] [ ingress | clsact ]\n");
> > +	fprintf(stderr, "       tc qdisc show [ dev STRING ] [ ingress | clsact | invisible ]\n");
> 
> Doesn't look like these are mutually exclusive. Therefore I would
> suggest fixing the syntax to:
> 
> | +	fprintf(stderr, "       tc qdisc show [ dev STRING ] [ ingress | clsact ] [ invisible ]\n");

Makes sense, will include this in v2.

Thanks,

-- 
Jiri Kosina
SUSE Labs
