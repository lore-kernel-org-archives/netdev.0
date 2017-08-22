From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 1/7] nstat: Avoid passing negative fd to
 fdopen()
Date: Tue, 22 Aug 2017 12:48:08 +0200
Message-ID: <20170822104808.GC27194@orbyte.nwl.cc>
References: <20170821170813.29697-1-phil@nwl.cc>
 <20170821170813.29697-2-phil@nwl.cc>
 <20170821172323.47c335f3@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52325 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932350AbdHVKsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 06:48:09 -0400
Content-Disposition: inline
In-Reply-To: <20170821172323.47c335f3@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 05:23:23PM -0700, Stephen Hemminger wrote:
> On Mon, 21 Aug 2017 19:08:07 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > Introduce a wrapper which does the sanity checking and returns NULL
> > in case fd is invalid.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  misc/nstat.c | 15 +++++++++++----
> >  1 file changed, 11 insertions(+), 4 deletions(-)
> > 
> > diff --git a/misc/nstat.c b/misc/nstat.c
> > index 1212b1f2c8128..7cdde75a56e4e 100644
> > --- a/misc/nstat.c
> > +++ b/misc/nstat.c
> > @@ -252,9 +252,16 @@ static void load_ugly_table(FILE *fp)
> >  	}
> >  }
> >  
> > +static FILE *fdopen_null(int fd, const char *mode)
> > +{
> > +	if (fd < 0)
> > +		return NULL;
> > +	return fdopen(fd, mode);
> > +}
> > +
> >  static void load_sctp_snmp(void)
> >  {
> > -	FILE *fp = fdopen(net_sctp_snmp_open(), "r");
> > +	FILE *fp = fdopen_null(net_sctp_snmp_open(), "r");
> >  
> >  	if (fp) {
> >  		load_good_table(fp);
[...]
> 
> Why not just fix it at the source of the open.
> I.e 
> static FILE *generic_proc_open(condt char * env, const char *name)
> {
> ...
> 	return fopen(p, "r");
> }

What should it do? All the load_*() functions are supposed to be
fault-tolerant, so calling abort() or something is not an option.

Thanks, Phil
