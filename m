From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/7] [IP] RULE: Add ifdef to FIB_RULE_INVERT since it is
 missing.
Date: Tue, 5 Dec 2006 10:02:11 -0800
Message-ID: <20061205100211.0a766673@freekitty>
References: <11653137331688-git-send-email-nakam@linux-ipv6.org>
	<20061205104231.GX8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:58991 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968550AbWLESCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 13:02:23 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061205104231.GX8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Dec 2006 11:42:31 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> * Masahide NAKAMURA <nakam@linux-ipv6.org> 2006-12-05 19:15
> > Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> > ---
> >  ip/iprule.c |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/ip/iprule.c b/ip/iprule.c
> > index c584b18..1da64b8 100644
> > --- a/ip/iprule.c
> > +++ b/ip/iprule.c
> > @@ -83,8 +83,10 @@ int print_rule(const struct sockaddr_nl 
> >  	else
> >  		fprintf(fp, "0:\t");
> >  
> > +#ifdef FIB_RULE_INVERT
> >  	if (r->rtm_flags & FIB_RULE_INVERT)
> >  		fprintf(fp, "not ");
> > +#endif
> >  
> >  	if (tb[RTA_SRC]) {
> >  		if (r->rtm_src_len != host_len) {
> > @@ -224,7 +226,9 @@ static int iprule_modify(int cmd, int ar
> >  
> >  	while (argc > 0) {
> >  		if (strcmp(*argv, "not") == 0) {
> > +#ifdef FIB_RULE_INVERT
> >  			req.r.rtm_flags |= FIB_RULE_INVERT;
> > +#endif
> >  		} else if (strcmp(*argv, "from") == 0) {
> >  			inet_prefix dst;
> >  			NEXT_ARG();
> 
> It's missing because you removed it.

Not applied, FIB_RULE_INVERT stays

-- 
Stephen Hemminger <shemminger@osdl.org>
