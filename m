From: maximilian attems <janitor@sternwelten.at>
Subject: Re: [KJ] Re: [patch 2.4] back port msleep(), msleep_interruptible()
Date: Sun, 31 Oct 2004 01:19:12 +0200
Message-ID: <20041030231912.GC1456__38137.0373921984$1099178449$gmane$org@stro.at>
References: <20040923221303.GB13244@us.ibm.com> <5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de> <415CD9D9.2000607@pobox.com> <20041030222228.GB1456@stro.at> <41841886.2080609@pobox.com> <29495f1d041030155953a9a776@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Margit Schubert-While <margitsw@t-online.de>,
        kernel-janitors@lists.osdl.org, mcgrof@studorgs.rutgers.edu,
        prism54-devel@prism54.org, Domen Puncer <domen@coderock.org>,
        linux-kernel@vger.kernel.org, hvr@gnu.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Content-Disposition: inline
In-Reply-To: <29495f1d041030155953a9a776@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Oct 2004, Nish Aravamudan wrote:

> On Sat, 30 Oct 2004 18:41:10 -0400, Jeff Garzik <jgarzik@pobox.com> wrote:
> > maximilian attems wrote:
> > > diff -puN include/linux/delay.h~add-msleep-2.4 include/linux/delay.h
> > > --- a/include/linux/delay.h~add-msleep-2.4    2004-10-30 22:48:46.000000000 +0200
> > > +++ b/include/linux/delay.h   2004-10-30 22:48:46.000000000 +0200
> > > @@ -34,4 +34,12 @@ extern unsigned long loops_per_jiffy;
> > >       ({unsigned long msec=(n); while (msec--) udelay(1000);}))
> > >  #endif
> > >
> > > +void msleep(unsigned int msecs);
> > > +unsigned long msleep_interruptible(unsigned int msecs);
> > > +
> > > +static inline void ssleep(unsigned int seconds)
> > [...]
> > > +static inline unsigned int jiffies_to_msecs(const unsigned long j)
> > 
> > > +static inline unsigned int jiffies_to_usecs(const unsigned long j)
> > 
> > > +static inline unsigned long msecs_to_jiffies(const unsigned int m)
> > 
> > 
> > I'm pretty sure more than one of these symbols clashes with a symbol
> > defined locally in a driver.  I like the patch but we can't apply it
> > until the impact on existing code is evaluated.
> 
> More than likely much of the code cleanup that was done before I began
> my patches, like removing custom msleep()s from drivers will need to
> be done again, as Jeff points out.
> 
> -Nish

thanks Jeff for your quick response,
ooh i seee libata is defining an msleep().
so there seems to be need for it.

ok we'll come up with tougher patchset.

--
maks
kernel janitor  	http://janitor.kernelnewbies.org/
