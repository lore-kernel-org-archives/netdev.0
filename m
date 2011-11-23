From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: RAW netfilter - "advanced netfilter setting" or not?
Date: Wed, 23 Nov 2011 22:27:46 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1111232217220.27025@frira.zrqbmnf.qr>
References: <CA+55aFxtSgLppJQ8EbQEovdXsCNxQ1gT31FyP2cpyuvoBLajZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxtSgLppJQ8EbQEovdXsCNxQ1gT31FyP2cpyuvoBLajZw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 2011-11-23 20:45, Linus Torvalds wrote:

>So I'm the one who long ago asked for some of the more esoteric
>netfilter configuration questions to be hidden behind some "advanced"
>question, and thus the reason why a lot of them are behind that
>NETFILTER_ADVANCED Kconfig setting.
>
>However, I'm now trying OpenSUSE on one of my laptops, and it looks
>like the RAW filter is used by the default OS iptables setup. The fact
>that it is hidden behind NETFILTER_ADVANCED now means that I either
>have to enable the advanced netfilter Kconfig questions, or we should
>just remove the "depends on NETFILTER_ADVANCED" for the RAW case (or,
>rather - caseS - since there's a separate raw filter for ipv4 and
>ipv6, which sounds odd in itself, but that's another issue entirely)

Welcome to the green. You will find the most complete Netfilter stack
here :)

>My gut feel is that if it's one of the filters that a major distro
>depends on by default, it should no longer be hidden. But honestly, I
>didn't look at *why* OpenSUSE uses that filter. Maybe it's just doing
>something really odd and crazy.

The "raw" table is populated by SUSE SFW2 with rules to exempt all
loopback packets from connection tracking since SFW2 at the same time
unconditionally allows all lo transfers in the "filter" table.

>Comments?

In my opinion, NETFILTER_ADVANCED should be changed to only control
the visibility of all suboptions, i.e. I suggest that "default m if
NETFILTER_ADVANCED=n" be done for all non-deprecated modules.
(Similar to how CONFIG_EXPERT works.)

Unless one wants to argue that "that's a detail left to the distro
makers" and "people not compiling kernels would never run into this
issue".
