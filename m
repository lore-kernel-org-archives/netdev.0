From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [RFC] ethtool semantics
Date: Wed, 9 Jun 2004 23:38:50 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040609213850.GA17243@k3.hellgate.ch>
References: <20040607212804.GA17012@k3.hellgate.ch> <20040607145723.41da5783.davem@redhat.com> <20040608210809.GA10542@k3.hellgate.ch> <40C77C70.5070409@tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, jgarzik@pobox.com,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265974AbUFIWPj@vger.kernel.org>
To: Bill Davidsen <davidsen@tmr.com>
Content-Disposition: inline
In-Reply-To: <40C77C70.5070409@tmr.com>
List-Id: netdev.vger.kernel.org

On Wed, 09 Jun 2004 17:09:04 -0400, Bill Davidsen wrote:
> cases forcing on both ends or just the NIC end results in a fully 
> functional connection.
> 
> We usually do this with module parameters, but do use ethtool (or 
> mii-tool) on occasion.

<sigh> I just killed the module parameters in my via-rhine development
tree. I suppose you don't use via-rhine!? :-) Nobody complained when
the code was broken for the longest time, and the current design has
all kinds of issues, not the least of which is a distinct lack of sane
semantics for stuff like hotplug, interface renaming, etc.

I'd prefer not to spend my time writing a clean implementation (or fixing
up the current one) of a mechanism that is conceptually obsolete.

> >However, "silently ignoring" strikes me as a very poor choice, in
> >stark contrast to Unix/Linux tradition. A user issues a command which
> >cannot be executed and gets the same response that is used to indicate
> >success!? What school of user interface design is that? How is that
> >not confusing users? </rant>
> 
> Yah.
> 
> Seeing this happen while autonegotiation is in progress is a small and 
> unlikely window of course!

Hmm? It's not about autoneg being in progress, and it's not a race
of any kind. If your NIC comes up with nway autoneg enabled, you must
use ethtool to explicitly turn autoneg off before you can use ethtool
duplex/speed options to force a media mode. However, if you try to force
media with autoneg still enabled, your command will be silently ignored.
It's up to the user to find out that the command failed and why.

Roger
