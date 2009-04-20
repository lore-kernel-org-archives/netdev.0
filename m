From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Mon, 20 Apr 2009 11:46:29 -0700
Message-ID: <OF579850AE.5836C3EC-ON8825759E.0064AEE9-8825759E.006720F6@us.ibm.com>
References: <alpine.DEB.1.10.0904201242270.1585@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, nhorman@tuxdriver.com,
	vladislav.yasevich@hp.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:51808 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbZDTSqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 14:46:32 -0400
In-Reply-To: <alpine.DEB.1.10.0904201242270.1585@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter <cl@linux.com> wrote on 04/20/2009 09:43:45 AM:

> On Fri, 17 Apr 2009, David Stevens wrote:
> 
> >         Linux is not Solaris. I think Solaris is wrong to change the
> > behavior from the original BSD behavior, but it should be no surprise
> > that there are other differences in the API's, too. It's not difficult
> > to write code that works as intended on both, and the case Solaris is
> > trying to avoid is not really avoided since you can still receive
> > unicast traffic, or totally unrelated multicast traffic on the shared
> > port and multicast address space. If the app doesn't use the port to
> 
> By that you mean unrelated multicast traffic destined to the same
> multicast address and port?

        Yes. If neither the port nor the multicast address are
registered than anyone on your network can use them for anything. 
Even if they are registered, someone may still use it; sending
requires no special privilege, and neither does joing groups or
binding to ports above 1024. Anyone on your network, or within
your multicast routing domain, may reuse both (even if they
intend it for a different machine) and your app will receive
them.

        I think generally the best approach is to bind to the
particular multicast address and use SO_BINDTODEVICE if it
matters to the app. But the app still has to handle receiving
data from a different source or totally unrelated data;
it certainly can receive those, because anyone can send those.

        I can see the value of a per-socket, default-off option
in the case where you want multiple groups on a single socket,
and I encourage you to submit that as a patch. It reduces the
work the receiver has to do, but doesn't eliminate it. The
way I'd do that is to use multiple sockets, one bound to each
group, but ok. As long as it doesn't change the existing
behavior out from under existing, unknown apps.

                                                                +-DLS

