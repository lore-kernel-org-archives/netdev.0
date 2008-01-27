From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Sun, 27 Jan 2008 02:11:26 +0100
Message-ID: <20080127011126.GA3408@ami.dom.local>
References: <bug-9816-10286@http.bugzilla.kernel.org/> <20080125142603.a73fd7a2.akpm@linux-foundation.org> <479A6CBD.4010908@gmail.com> <20080125192026.e667f396.akpm@linux-foundation.org> <b25c3fa70801252116h2b9f12c9j65a8a75dbd0d5662@mail.gmail.com> <20080126114036.GA2624@ami.dom.local> <20080126141010.GC2624@ami.dom.local> <jeve5gd5mz.fsf@sykes.suse.de> <20080126151934.GA2969@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joonwoo Park <joonwpark81@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Andreas Schwab <schwab@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.233]:22978 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbYA0BI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 20:08:57 -0500
Received: by hu-out-0506.google.com with SMTP id 19so709011hue.21
        for <netdev@vger.kernel.org>; Sat, 26 Jan 2008 17:08:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080126151934.GA2969@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 26, 2008 at 04:19:34PM +0100, Jarek Poplawski wrote:
> On Sat, Jan 26, 2008 at 03:27:00PM +0100, Andreas Schwab wrote:
> > Jarek Poplawski <jarkao2@gmail.com> writes:
> > 
> > > And, after re-reading this bugzilla report, I'm pretty sure the thing
> > > should be done with 'ip route change' (but I didn't check if 2.6.24
> > > knows about this...).
> > 
> > $ man ip
> > [...]
> >    ip route add - add new route
> >    ip route change - change route
> >    ip route replace - change or add new one
> > [...]
> > 
> > According to this "replace" should be a superset of "change".
> 
> According to this "replace" should be ...ambiguous. I could read this
> "my/proper(?) way":
> 
>     ip route replace - change with new one or add new one
> 
> And ...man could be wrong too after all! (...but not me!)

After some checks it seems man is right - ie. WRT iproute.c! (...hmm?)
And you read this right: '"replace" should be a superset of "change"'.

> > Also, please check out comment#3, it also fails for replacing a route
> > with something different (it's a route to an ipsec tunnel).

But comment#3 is "ambiguous"... It looks like you don't want to show
us too much... So, apparently you change the route, but it seems this
route exists; you have this:
  10.0.0.0/8 dev eth0  scope link 
but probably also something like this:
  default via 192.168.1.1 dev eth0 src 10.204.0.116

So, I doubt there is any "real" change attempted here. It looks more
like a question if program should allow for changing the form of route
entries even if they mean the same, and if this should be reported as
error at all? But maybe I miss something...

Jarek P.
