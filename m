From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: NAPI packet weighting patch
Date: 21 Jun 2005 23:47:07 +0200
Message-ID: <p73oe9zbcx0.fsf@verdi.suse.de>
References: <468F3FDA28AA87429AD807992E22D07E0450C00B@orsmsx408>
	<Pine.CYG.4.58.0506061647340.128@mawilli1-desk2.amr.corp.intel.com>
	<42A5284C.3060808@osdl.org>
	<20050621.132044.115910664.davem@davemloft.net>
	<42B87ACF.3080800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <42B87ACF.3080800@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> writes:

> > Actually, it has a _HUGE_ _HUGE_ impact.  If you pass the big buffer
> > up, the receiving socket gets charged for the size of the huge buffer,
> > not for just the size of the packet contained within.  This makes
> > sockets get overcharged for data reception, and it can cause all kinds
> > of performance problems.
> 
> Then copy when the socket is about to fill with overhead bytes?

The stack has supported that since 2.4.

Mostly because it is the only sane way to handle devices with very big
MTU. But it turns off all kinds of fast paths before it happens, I
guess that is what David was refering too.

However I suspect the cut-off points with rx-copybreak in common driver 
have been  often tuned before that code was introduced and it might
be worth to do some retesting.

-Andi
