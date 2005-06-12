From: Willy Tarreau <willy@w.ods.org>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 20:14:25 +0200
Message-ID: <20050612181425.GA11284@alpha.home.local>
References: <42A9C607.4030209@unixtrix.com> <200506122010.33075.vda@ilport.com.ua> <20050612173614.GA11157@alpha.home.local> <200506122047.07257.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, xschmi00@stud.feec.vutbr.cz,
        alastair@unixtrix.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@ilport.com.ua>
Content-Disposition: inline
In-Reply-To: <200506122047.07257.vda@ilport.com.ua>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 12, 2005 at 08:47:07PM +0300, Denis Vlasenko wrote:
> On Sunday 12 June 2005 20:36, Willy Tarreau wrote:
> > On Sun, Jun 12, 2005 at 08:10:33PM +0300, Denis Vlasenko wrote:
> > > > Does it seem appropriate for mainline ? In this case, I would also backport
> > > > it to 2.4 and send it to you for inclusion.
> > > 
> > > It does not contain a comment why it is configurable.
> > 
> > You're right. Better with this ?
> 
> Very nice. BTW, is there any real world applications which
> ever used this?

Not that I'm aware of, but that does not mean they don't exist. Until
yesterday, I even thought that it was never implemented. As most other
systems don't implement it, the applications, if they exist, are Linux
or BSD-dependant. It's even difficult to use because the two ends must
loop around the connect() call until it succeeds, because as long as
they're not both trying to connect, they get RSTs back.

> > +	If you want backwards compatibility with every possible application,
> > +	you should set it to 1. If you prefer to enhance security on your
> > +	systems at the risk of breaking very rare specific applications, you'd
> > +	better let it to 0.
> > +	Default: 0
> 
> This text leaves an impression that they exist.

In doubt, I consider that they might exist. It's just like martians :-)

Willy
