From: Thomas Graf <tgraf@suug.ch>
Subject: Re: memory leak in net/sched/ipt.c?
Date: Wed, 23 Mar 2005 14:23:32 +0100
Message-ID: <20050323132332.GQ3086@postel.suug.ch>
References: <E1DE44X-0001QM-00@gondolin.me.apana.org.au> <1111581618.1088.72.camel@jzny.localdomain> <20050323125516.GP3086@postel.suug.ch> <1111583497.1089.92.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Yichen Xie <yxie@cs.stanford.edu>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	"David S. Miller" <davem@davemloft.net>, kaber@trash.net
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111583497.1089.92.camel@jzny.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <1111583497.1089.92.camel@jzny.localdomain> 2005-03-23 08:11
> On Wed, 2005-03-23 at 07:55, Thomas Graf wrote:
> > * jamal <1111581618.1088.72.camel@jzny.localdomain> 2005-03-23 07:40
> 
> > > Just a small correction to patchlet:
> > > The second kfree should check for existence of t.
> > 
> > t is either valid or NULL so it's not a problem, unless you want
> > to create janitor work of course. ;->
> 
> if t is null you still goto rtattr_failure
> I have seen people put little comments of "kfree will work if you
> pass it NULL" - are you saying such assumptions exist all over
> net/sched?

kfree simply does nothing if it is given a null pointer so that
goto rtattr_failure for t == NULL  is handled just fine without
a check. I will never get used to this behaviour and policy as
well though, it somewhat makes code less readable.

> didnt understand the janitor part.

It will probably be removed again by one of the regular 'remove
unnecessary pre kfree checks' patchsets.
