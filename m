From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 2/3] iproute_lwtunnel: Argument to strerror
 must be positive
Date: Fri, 18 Aug 2017 13:21:27 +0200
Message-ID: <20170818112127.GI10864@orbyte.nwl.cc>
References: <20170817170932.24812-1-phil@nwl.cc>
 <20170817170932.24812-3-phil@nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6DD005A7C8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42055 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750877AbdHRLV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 07:21:29 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD005A7C8@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 09:21:34AM +0000, David Laight wrote:
> From: Phil Sutter
> > Sent: 17 August 2017 18:10
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  ip/iproute_lwtunnel.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
> > index 398ab5e077ed8..1a3dc4d4c0ed9 100644
> > --- a/ip/iproute_lwtunnel.c
> > +++ b/ip/iproute_lwtunnel.c
> > @@ -643,7 +643,7 @@ static int lwt_parse_bpf(struct rtattr *rta, size_t len,
> >  	err = bpf_parse_common(bpf_type, &cfg, &bpf_cb_ops, &x);
> >  	if (err < 0) {
> >  		fprintf(stderr, "Failed to parse eBPF program: %s\n",
> > -			strerror(err));
> > +			strerror(-err));
> 
> If we are in userspace I'd expect errno values to be +ve.
> Returning a -ve errno is very non-standard.

This is because bpf_parse() returns the number of instructions parsed or
a negative return code. We could change it to return instructions * -1
or a positive return code, but that's even more insane than calling
strerror(-err), isn't it?

Cheers, Phil
