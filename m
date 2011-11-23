From: Patrick McHardy <kaber@trash.net>
Subject: Re: RAW netfilter - "advanced netfilter setting" or not?
Date: Wed, 23 Nov 2011 20:58:33 +0100
Message-ID: <4ECD5069.4090106@trash.net>
References: <CA+55aFxtSgLppJQ8EbQEovdXsCNxQ1gT31FyP2cpyuvoBLajZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxtSgLppJQ8EbQEovdXsCNxQ1gT31FyP2cpyuvoBLajZw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.11.2011 20:45, Linus Torvalds wrote:
> So I'm the one who long ago asked for some of the more esoteric
> netfilter configuration questions to be hidden behind some "advanced"
> question, and thus the reason why a lot of them are behind that
> NETFILTER_ADVANCED Kconfig setting.
> 
> However, I'm now trying OpenSUSE on one of my laptops, and it looks
> like the RAW filter is used by the default OS iptables setup. The fact
> that it is hidden behind NETFILTER_ADVANCED now means that I either
> have to enable the advanced netfilter Kconfig questions, or we should
> just remove the "depends on NETFILTER_ADVANCED" for the RAW case (or,
> rather - caseS - since there's a separate raw filter for ipv4 and
> ipv6, which sounds odd in itself, but that's another issue entirely)
> 
> My gut feel is that if it's one of the filters that a major distro
> depends on by default, it should no longer be hidden.

Agreed, the main point was to enable everything used by major
distributions by default (default m if NETFILTER_ADVANCED=n)
and hide everything else.

> But honestly, I
> didn't look at *why* OpenSUSE uses that filter. Maybe it's just doing
> something really odd and crazy.

Most likely they're using NOTRACK to avoid connection tracking for
some traffic. Could you post the output of "iptables -t raw -vxnL"?
