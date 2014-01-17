From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/3] net: add trim helper and convert users
Date: Fri, 17 Jan 2014 11:08:44 -0800
Message-ID: <1389985724.31367.497.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389918519-23779-1-git-send-email-hannes@stressinduktion.org>
	 <1389918519-23779-3-git-send-email-hannes@stressinduktion.org>
	 <1389982549.27141.15.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389982549.27141.15.camel@bwh-desktop.uk.level5networks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-01-17 at 18:15 +0000, Ben Hutchings wrote:
> On Fri, 2014-01-17 at 01:28 +0100, Hannes Frederic Sowa wrote:
> [...]
> > --- a/include/linux/kernel.h
> > +++ b/include/linux/kernel.h
> > @@ -193,6 +193,25 @@ extern int _cond_resched(void);
> >  		(__x < 0) ? -__x : __x;		\
> >  	})
> >  
> > +/**
> > + * trim - perform a reciprocal multiplication in order to "clamp" a
> > + *        value into range [0, ep_ro), where the upper interval
> > + *        endpoint is right-open. This is useful, e.g. for accessing
> > + *        a index of an array containing ep_ro elements, for example.
> > + *        Think of it as sort of modulus, only that the result isn't
> > + *        that of modulo. ;)
> > + *        More: http://homepage.cs.uiowa.edu/~jones/bcd/divide.html
> [...]
> 
> And you think trim() is an obvious name for that?!
> How about: scale_u32_to_range().
> 
> Also the first physical line of a kernel-doc comment (after the name) is
> a summary which is used, for example, in the summary line on a manual
> page.  It seems like you have the summary and full description the wrong
> way round here.

BTW the 'scaling' depends on u32 value being pretty much random.

If initial input is a small value like 0 .. 1000, then trim(x, 1000)
will return 0

I liked the reciprocal name because it was really expressing the
reciprocal idea.
