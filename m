From: "David S. Miller" <davem@redhat.com>
Subject: Re: bk16 changes to cbq
Date: Tue, 6 Jul 2004 22:13:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706221317.2f0585d1.davem@redhat.com>
References: <1088861810.1039.298.camel@jzny.localdomain>
	<20040705202727.GA21226@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20040705202727.GA21226@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 00:27:27 +0400
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> > What i remember is this (4-5 years back) used to cure a bug - cant
> > remember the details unfortunately, but Alexey may remember.
> 
> Actually, I do not. It looks like an optimization: if the device is
> throttled we just do not need to add timer, qdisc will be woken up
> by unthrottle. I do not see any race condition here, but also I do not
> see why this check could be important.
> 
> > At the expense of repeating a discussion that may have already happened,
> 
> To be honest, I wish to be reminded. If this check cured something,
> it would be interesting to know what was this.

e1000 would hang the delay scheduler sometimes

Let me look for the exact email from Stephen.  Here it is:

http://mailman.ds9a.nl/pipermail/lartc/2004q2/012736.html

Jamal read this, and that is what prompted him to say that if
the delay scheduler was made classful instead of "pretending"
to be, the bug mentioned in Stephen's email would not occur.

I do not understand things fully.  I think it would help if, for example,
each of the qdisc and classification operations had some comments
describing the exact semantics of each ops->method.   For example,
what does requeue do and what is it indicating with each of the
possible return values.  What is expected of it?  What kind of state
is it allowed to leave the queue in?
