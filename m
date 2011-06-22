From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Wed, 22 Jun 2011 12:54:34 +0200
Message-ID: <20110622105434.GE16021@Chamillionaire.breakpoint.cc>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
 <4E0115B3.2030802@redhat.com>
 <20110621225645.GD16021@Chamillionaire.breakpoint.cc>
 <20110621.155816.1840729860084652508.davem@davemloft.net>
 <4E01C34F.6050009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, fbl@redhat.com,
	netdev@vger.kernel.org, agospoda@redhat.com, nhorman@redhat.com,
	lwoodman@redhat.com, john.haxby@oracle.com
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:35242 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753138Ab1FVKyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 06:54:37 -0400
Content-Disposition: inline
In-Reply-To: <4E01C34F.6050009@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prarit Bhargava <prarit@redhat.com> wrote:

[ cc'd John Haxby, who worked on xt_SYSREQ ]

> On 06/21/2011 06:58 PM, David Miller wrote:
> > From: Florian Westphal <fw@strlen.de>
> > Date: Wed, 22 Jun 2011 00:56:45 +0200
> >> This is one of the reasons why I still think that
> >> xt_SYSREQ would be the better solution, you get all
> >> kinds of filtering features for free.
> >>
> >> You could even use crazy things like '-m time' to restrict
> >> sysreq availability to working hours and whatnot.
> >>
> > Agreed.
> Using the netfilter xt-SYSRQ code seems to store the entered code and
> execute it later after the system has returned to a normal state....
> which is much too late to be useful.

The target handler of the kernel part invokes handle_sysrq(),
I don't see any delaying/queueing?

FWIW, the old discussion is in the archives:
search for subject "nf-next: sysrq and condition 20100421" from Jan
Engelhardt, or try
http://thread.gmane.org/gmane.comp.security.firewalls.netfilter.devel/33615/focus=34808

As far as i understand the use case described by John Haxby matches yours.

Patrick McHardy suggested an alternative standalone method involving
encapsulation sockets; perhaps the reasons why this path was not chosen
have changed.

I think that a standalone module (i.e. not requiring netfilter) that
runs the sysreq handling after all netfilter hooks would be optimal,
but I don't see a simple method to implement that.
