From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 1 Jul 2008 17:08:36 +0400
Message-ID: <20080701130835.GA29223@2ka.mipt.ru>
References: <20080701113927.GA16343@2ka.mipt.ru> <486A1AC7.9020706@trash.net> <20080701120320.GA9412@2ka.mipt.ru> <486A2487.2010303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <486A2487.2010303@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 01, 2008 at 02:35:19PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> >>My two main objections are that this only works for TCP and
> >>can be trivially evaded. What use cases does it have?
> >
> >Yes, it is TCP specific module.
> 
> What about the use cases? I certainly like the idea you suggest in
> your blog ("Ever dreamt to block all Linux users in your network
> from accessing internet and allow full bandwidth to Windows worm?")
> :) But something this easy to evade doesn't seem to provide a real
> benefit for a firewall.

Actually worm detection is one of the use cases - I was told about
successful installations several years ago.

> I can see that something like "Block IE6 running on Windows version X"
> might be useful (NUFW can do this I think), but that needs support
> from the host.

It allows to determine that it is Windows version X, there is no way to
distinguish userspace application from each other if they use default
parameters.

OS version detection is somewhat subtle - in earlier days it was
simpler, since each major version broke/changed something especially
in XP stack, in Linux I do not know any similar changes in recent
2.6 kernels.

> >>I'm also wondering whether this couldn't be implemented
> >>using the u32 match.
> >
> >I'm not sure it is that simple. OSF uses common rules database
> >shared with OpenBSD (and other *BSDs as well), so converting it into u32
> >match would require noticeble efforts. But in theory it is probably
> >doable.
> 
> This would be preferrable in my opinion since they both allow
> programmable filters, but u32 appears to be more flexible. I'm
> very reluctant to add new iptables modules that don't increase
> expressiveness or provide other clear benefits since we already
> have an insane amount of modules.

OSF does increase expressiveness! :)
'--genre Linux' is much more clear than... Do you want me to at least
roughly draw mathing rules enciphered in u32 format?

I agree that matching can be done with u32 (even private OSF TTL games),
but it will much much much more ugly than simple module.

I am also not sure OSF should live in kernel, but what it does it does
good and there is no simple way to do the same with existing
functionality. It is possible, but not simple, and definitely not
trivial for administrator :)

> From the fingerprint file:
> 
> # Fingerprint entry format:
> #
> # wwww:ttt:D:ss:OOO...:OS:Version:Subtype:Details
> #
> # wwww     - window size (can be *, %nnn, Snn or Tnn).  The special values
> #            "S" and "T" which are a multiple of MSS or a multiple of MTU
> #            respectively.
> # ttt      - initial TTL
> # D        - don't fragment bit (0 - not set, 1 - set)
> # ss       - overall SYN packet size
> # OOO      - option value and order specification (see below)
> # OS       - OS genre (Linux, Solaris, Windows)
> # Version  - OS Version (2.0.27 on x86, etc)
> # Subtype  - OS subtype or patchlevel (SP3, lo0)
> # details  - Generic OS details
> 
> MSS can be matched using the tcpmss match, options (but not order)
> using the tcp match, TTL using the ttl match, DF using the IP flags
> match, packet size using the length match. That leaves WS for u32
> (or adding support to the tcp match).
> 
> The conversion looks pretty easy actually.

Hmm, I can assure you that simple rule for OSF matching module is much
more clear than zillions above rules, but it can be done indeed. I'm not
sure that 5 years ago all that matches existed, but right now it is
possible. Not trivial and not simple, but probably possible.

To use multple matches one has to chain them into single rule/table,
listing and understaning of which is not simple enough compared to OSF
rules. So it is helper module which allows really simple installation.

Various tricks with TTL used in OSF will complicate that chaining even
more.

> >Also I do not know why we want to remove connector in favour of
> >genetlink, since the former is much simpler to work with. Connector
> >logging is optional in OSF.
> 
> I'm not sure if we want to, but they appear to provide similar
> functionality and connector only has a single user in the tree
> so far. But thats a different discussion, for netfilter related
> things nfnetlink should be used.

IIRC there are at least threee: w1, various accountings and uvesafb.
And I authored only the first :)

There was no nfnetlink either 5 years ago, when OSF was created,
this release is just subsequent update to the project.
At some moment OSF shared netlink group with ulog, but it was
considered harmful, so I dropped support. Netlink usage is
rather trivial: it just sends information about matched packt to
userspace, so it can block it on its own, rise a message in the window
or perform some other steps. Nothing exceptionally complex :)

-- 
	Evgeniy Polyakov
