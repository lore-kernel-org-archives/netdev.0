From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH] vsnprintf: Remove use of %n and convert existing uses
Date: Thu, 12 Sep 2013 09:06:04 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B732A@saturn3.aculab.com>
References: <1378926562.4714.11.camel@joe-AO722> <CAGXu5jLO6109fkejXqX=WhkQnfAUeWtTcow0v1BNqyi=8=Qa3Q@mail.gmail.com> <1378928700.4714.17.camel@joe-AO722> <CAGXu5jLTjrPr=GwOmMcu55Qp9K-_XS75xq9NJ0vBUEwy-i_YMw@mail.gmail.com> <1378941761.4714.37.camel@joe-AO722> <201309120840.HHE37542.OJMFFHSOQOtVFL@I-love.SAKURA.ne.jp> <1378944257.4714.45.camel@joe-AO722> <20130912001911.GO13318@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Tetsuo Handa" <penguin-kernel@I-love.SAKURA.ne.jp>,
	<linux-kernel@vger.kernel.org>, <kosaki.motohiro@jp.fujitsu.com>,
	<keescook@chromium.org>, <fweisbec@gmail.com>,
	<dan.carpenter@oracle.com>, <devel@driverdev.osuosl.org>,
	<gregkh@linuxfoundation.org>, <tushar.behera@linaro.org>,
	<lidza.louina@gmail.com>, <davem@davemloft.net>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<courmisch@gmail.com>, <vyasevich@gmail.com>,
	<nhorman@tuxdriver.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: "Al Viro" <viro@ZenIV.linux.org.uk>,
	"Joe Perches" <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20130912001911.GO13318@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Wed, Sep 11, 2013 at 05:04:17PM -0700, Joe Perches wrote:
> > On Thu, 2013-09-12 at 08:40 +0900, Tetsuo Handa wrote:
> > > Joe Perches wrote:
> > > > -	seq_printf(m, "%s%d%n", con->name, con->index, &len);
> > > > +	len = seq_printf(m, "%s%d", con->name, con->index);
> > >
> > > Isn't len always 0 or -1 ?
> >
> > Right.  Well you're no fun...
> >
> > These uses would seem broken anyway because the
> > seq_printf isn't itself tested for correctness.
> >
> > Hmm.
> >
> > Also, there's a large amount of code that appears
> > to do calculations with pos or len like:
> >
> > 	pos += seq_printf(handle, fmt. ...)
> 
> ... and most of that code proceeds to ignore pos completely.
> Note that ->show() is *NOT* supposed to return the number of
> characters it has/would like to have produced.  Just return
> 0 and be done with that; overflows are dealt with just fine.
> The large amount, BTW, is below 100 lines, AFAICS, in rather
> few files.
> 
> > There are very few that seem to use it correctly
> > like netfilter.
> 
> > Suggestions?

Change the return type of seq_printf() to void and require that
code use access functions/macros to find the length and error
status. Possibly save the length of the last call separately.

	David
