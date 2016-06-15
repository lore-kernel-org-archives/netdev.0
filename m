From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: fix buffer null termination
Date: Wed, 15 Jun 2016 14:17:40 +0200
Message-ID: <20160615121740.GA3088@salvia>
References: <1465620484-5543-1-git-send-email-sandeepkishan108@gmail.com>
 <CAJ3s=NBCvYnRaWcFb==vZqP1_YE6w=uKqbtBvESkCo1sED2CHg@mail.gmail.com>
 <20160614150802.GA1029@salvia>
 <CAJ3s=ND18x4g4gwVOb0G4cqRbAiF-6F341gWJK7_vumc2BLB0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Kishan Sandeep <sandeepkishan108@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJ3s=ND18x4g4gwVOb0G4cqRbAiF-6F341gWJK7_vumc2BLB0w@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 14, 2016 at 09:52:49PM +0530, Kishan Sandeep wrote:
> Hi Pablo,
> 
> On Tue, Jun 14, 2016 at 8:38 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > Cc'ing netfilter-devel.
> >
> > On Tue, Jun 14, 2016 at 07:39:27PM +0530, Kishan Sandeep wrote:
> >> + netdev
> >>
> >> On Sat, Jun 11, 2016 at 10:18 AM, Kishan Sandeep
> >> <sandeepkishan108@gmail.com> wrote:
> >> > strncpy generally perferable fo non-terminated
> >> > fixed-width strings. For NULL termination strlcpy
> >> > is preferrable.
> >> >
> >> > Signed-off-by: Kishan Sandeep <sandeepkishan108@gmail.com>
> >> > ---
> >> >  net/netfilter/xt_repldata.h |    2 +-
> >> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >> >
> >> > diff --git a/net/netfilter/xt_repldata.h b/net/netfilter/xt_repldata.h
> >> > index 8fd3241..a460211 100644
> >> > --- a/net/netfilter/xt_repldata.h
> >> > +++ b/net/netfilter/xt_repldata.h
> >> > @@ -28,7 +28,7 @@
> >> >         if (tbl == NULL) \
> >> >                 return NULL; \
> >> >         term = (struct type##_error *)&(((char *)tbl)[term_offset]); \
> >> > -       strncpy(tbl->repl.name, info->name, sizeof(tbl->repl.name)); \
> >> > +       strlcpy(tbl->repl.name, info->name, sizeof(tbl->repl.name)); \
> >
> > I don't think this is actually fixing anything. Tables in x_tables
> > have a known and fixed name that is defined from the kernel side, that
> > is always smaller that the buffer we have there. So are you observing
> > any real problem from there?
> >
> > Thanks.
> 
> Not observed any real problem. Here the string is not NULL terminated with
> the use of strncpy - that is the problem. With the use of strlcpy we can make
> the string to terminated properly.

1) Table names set from the kernel codebase, so they are always
   way smaller than that.

2) We're not expecting the addition of new tables in the future that
   we result in the hypothetical problem that you indicate.

Thanks.
