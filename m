From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v3 2/7] xfrm_state: Make sure alg_name is
 NULL-terminated
Date: Tue, 22 Aug 2017 13:05:25 +0200
Message-ID: <20170822110525.GD27194@orbyte.nwl.cc>
References: <20170821132341.23118-1-phil@nwl.cc>
 <20170821132341.23118-3-phil@nwl.cc>
 <20170821172541.6eb3e60c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43265 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932427AbdHVLF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 07:05:26 -0400
Content-Disposition: inline
In-Reply-To: <20170821172541.6eb3e60c@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 05:28:20PM -0700, Stephen Hemminger wrote:
> On Mon, 21 Aug 2017 15:23:36 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  ip/xfrm_state.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
> > index e11c93bf1c3b5..7c0389038986e 100644
> > --- a/ip/xfrm_state.c
> > +++ b/ip/xfrm_state.c
> > @@ -125,7 +125,8 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
> >  	fprintf(stderr, "warning: ALGO-NAME/ALGO-KEYMAT values will be sent to the kernel promiscuously! (verifying them isn't implemented yet)\n");
> >  #endif
> >  
> > -	strncpy(alg->alg_name, name, sizeof(alg->alg_name));
> > +	strncpy(alg->alg_name, name, sizeof(alg->alg_name) - 1);
> > +	alg->alg_name[sizeof(alg->alg_name) - 1] = '\0';
> >  
> >  	if (slen > 2 && strncmp(key, "0x", 2) == 0) {
> >  		/* split two chars "0x" from the top */
> 
> You are fixing enough of these null terminated string issues, that maybe
> introducing strlcpy() would make sense. Either in utils (or -lbsd).

I thought about that already, but decided against it since we don't want
to truncate user chosen interface names so instead implemented
assert_valid_dev_name() and went on with manually sanitizing the other
cases.

Is adding libbsd as additional dependency acceptable? If not, I could
provide a simple strlcpy() implementation in utils.

Are you fine with a follow-up patch addressing this?

Thanks, Phil
