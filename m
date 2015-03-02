From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next v4 0/2] net: Introducing socket mark receive
 socket option
Date: Mon, 2 Mar 2015 19:55:17 +0100
Message-ID: <20150302185517.GA9762@breakpoint.cc>
References: <1425302043-669-1-git-send-email-eyal.birger@gmail.com>
 <20150302132925.GB7418@breakpoint.cc>
 <CAHsH6Gu+ZHSdnnritKk5cjTg4NuKppYjffXjNpou2i+uVeykYA@mail.gmail.com>
 <20150302143647.GC7418@breakpoint.cc>
 <CAHsH6GtDXWwLP4C2ZTfFpbWyLUKh8=nO02Xg_WmD4a+pN-Vf_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54391 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753730AbbCBSzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 13:55:20 -0500
Content-Disposition: inline
In-Reply-To: <CAHsH6GtDXWwLP4C2ZTfFpbWyLUKh8=nO02Xg_WmD4a+pN-Vf_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eyal Birger <eyal.birger@gmail.com> wrote:
> On Mon, Mar 2, 2015 at 4:36 PM, Florian Westphal <fw@strlen.de> > > wrote:
> The application does not need to know about the match criteria. Only about the
> eventual mark. This decouples the semantics of a flow and it's actual
> match criteria.
> 
> > I don't see how that is 'better' than e.g. looking at dst port number.
> 
> As mentioned, in cases where the match criteria is more complex than
> just the dst
> port number, the match logic has to be duplicated in the application.

Sure.  However, in that case, I fail to see why you'd need to
differentiate at all; normally this would only be needed to e.g. figure
out if your proxy deals with f.e. http or ssl, and dport would be enough
for this.

> > Right, but to me it seems very hacky to use SO_MARK as some kind of OOB signal.
> >
> > It won't work depending on loaded ruleset, it won't work with non-localhost
> > traffic and it won't work when other application runs in another network
> > namespace.
> >
> > Seems such facility would be limited to some pre-configured distribution where
> > users don't run own software and make no changes to the default system
> > setup.
> >
> 
> It does not necessarily imply a static configuration, only a carefully
> crafted one.
> There are more than a few systems with this premise.

> >> For example, a user space daemon can receive traffic from multiple
> >> applications using a single socket and distinguish between different traffic groups
> >> according to the packet mark.
> >
> > Right, but it might as well use SO_PEERCRED to identify the other pid, right?
> 
> I don't think so.
> 
> This would only work on connection/pair based sockets (and currently
> only supported
> in AF_UNIX) - the skb->mark can be different on a per packet basis -
> especially when
> several applications interact with a single daemon.

Fair enough, I still  cannot imagine any scenario where doing this
would be a clean design or where this cannot be covered by other means
(in payload, via peercred, using dbus, etc.)

I'd have no problem at all with this if we had some kind of staging
tree for uapi :-}

I'll assume that I'm just not imaginative enough when it comes to use
cases for this facility, it doesn't seem to be too problematic exposing
this, aside from userspace considerations (such as inability to guarantee
that skb->mark will be set up as expected), so i still fail to see how
its useful for isolated applications or even a collection of programs
that want to do ipc.
