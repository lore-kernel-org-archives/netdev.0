From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 0/2] netfilter: IPv4/v6 IPcomp match support
Date: Fri, 20 Dec 2013 10:04:19 +0100
Message-ID: <20131220090419.GA5661@localhost>
References: <1386937082-30412-1-git-send-email-fan.du@windriver.com>
 <20131217130555.GA8874@localhost>
 <52B26841.40800@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, steffen.klassert@secunet.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52B26841.40800@windriver.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 19, 2013 at 11:30:09AM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B412=E6=9C=8817=E6=97=A5 21:05, Pablo Neira Ayuso wrote=
:
> >On Fri, Dec 13, 2013 at 08:18:00PM +0800, Fan Du wrote:
> >>Hi,
> >>
> >>This patchset adds IPv4/v6 IPComp 'match' plugin to enables user se=
tting
> >>ACTONs for IPcomp flows sepecified with SPI value.
> >>
> >>Corresponding iptables patchset will be sent here after soon.
> >>
> >>Fan Du (2):
> >>   netfilter: add IPv4 IPComp extension match support
> >>   netfilter: add IPv6 IPComp extension match support
> >
> >This looks good, but I have to ask you to merge those two modules in=
to
> >one single xt_ipcomp, they are fairly small and we can save the
> >overhead of having two different modules. Moreover, at quick glance =
I
> >don't see any dependency with IPv4/IPv6 exported symbols that may
> >cause ifdef pollution.
> >
> >Please, see net/netfilter/xt_tcpudp.c as reference to rework this.
> >Thanks.
> >
>=20
> I noticed netfilter ipv4/v6 AH support also has split implementation,
> so far, by my understanding, it's fairly enough to consolidate those
> two implementations into one as well, as IPv4/6 AH head format are
> identical.
>
> If you don't mind or it won't break anything internal for netfilter,
> I plan to combine them into one piece.

We can merge those two, but you'll have to handle dependencies with
IPv6 core via ifdefs and Kconfig to avoid problems.

AH is not the last header, so we still have to use ipv6_find_hdr() to
find the good header instead of par->thoff. Note that the ip6_tables
sets par->thoff to the last IPv6 extension header.

This rises some concerns regarding your ipcomp, I think that if you
use this with ah and esp, the ordering of the headers is
ah+ipcomp+esp, right? In that case, you need to use ipv6_find_hdr()
since par->thoff would point to the esp header.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
