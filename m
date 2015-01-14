From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Filter inet dgram sockets with established
 state by default
Date: Wed, 14 Jan 2015 14:41:20 -0800
Message-ID: <20150114144120.0e15ac1f@urahara>
References: <1420738342-3750-1-git-send-email-vadim4j@gmail.com>
	<20150113173150.0a50f74e@urahara>
	<20150114064944.GA28611@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32781 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753742AbbANWla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 17:41:30 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so13375882pad.1
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 14:41:29 -0800 (PST)
In-Reply-To: <20150114064944.GA28611@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jan 2015 08:49:44 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> On Tue, Jan 13, 2015 at 05:31:50PM -0800, Stephen Hemminger wrote:
> > On Thu,  8 Jan 2015 19:32:22 +0200
> > Vadim Kochan <vadim4j@gmail.com> wrote:
> > 
> > > From: Vadim Kochan <vadim4j@gmail.com>
> > > 
> > > As inet dgram sockets (udp, raw) can call connect(...)  - they
> > > might be set in ESTABLISHED state. So keep the original behaviour of
> > > 'ss' which filtered them by ESTABLISHED state by default. So:
> > > 
> > >     $ ss -u
> > > 
> > >     or
> > > 
> > >     $ ss -w
> > > 
> > > Will show only ESTABLISHED UDP sockets by default.
> > > 
> > > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> > > ---
> > >  misc/ss.c | 4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/misc/ss.c b/misc/ss.c
> > > index 08d210a..015d829 100644
> > > --- a/misc/ss.c
> > > +++ b/misc/ss.c
> > > @@ -170,11 +170,11 @@ static const struct filter default_dbs[MAX_DB] = {
> > >  		.families = (1 << AF_INET) | (1 << AF_INET6),
> > >  	},
> > >  	[UDP_DB] = {
> > > -		.states   = (1 << SS_CLOSE),
> > > +		.states   = (1 << SS_ESTABLISHED),
> > >  		.families = (1 << AF_INET) | (1 << AF_INET6),
> > >  	},
> > >  	[RAW_DB] = {
> > > -		.states   = (1 << SS_CLOSE),
> > > +		.states   = (1 << SS_ESTABLISHED),
> > >  		.families = (1 << AF_INET) | (1 << AF_INET6),
> > >  	},
> > >  	[UNIX_DG_DB] = {
> > 
> > This is a change likely to break somebody using 'ss -u' now and the bound
> > sockets will disappear from the output.
> > 
> 
> But thats was as original behaviour before I added table-driven code
> (about few commits ago), so thats a rather fix (sorry I did not noticed
> about it) to keep the previous behaviour for dgram sockets - show
> established states by default.
> 
> Regards,

Ok, I will merge it and update the comments.
