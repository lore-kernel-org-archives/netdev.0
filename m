From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: add IPComp extension match support
Date: Sun, 8 Dec 2013 00:55:39 +0100
Message-ID: <20131207235539.GA6693@localhost>
References: <1385607204-27650-1-git-send-email-fan.du@windriver.com>
 <20131205183402.GA8949@localhost>
 <52A19F39.3030702@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52A19F39.3030702@windriver.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 06, 2013 at 05:56:09PM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B412=E6=9C=8806=E6=97=A5 02:34, Pablo Neira Ayuso wrote=
:
> >Hi,
> >
> >On Thu, Nov 28, 2013 at 10:53:24AM +0800, Fan Du wrote:
> >>With this plugin, user could specify IPComp tagged with certain
> >>CPI that host not interested will be DROPped or any other action.
> >>
> >>For example:
> >>iptables -A INPUT -p 108 -m ipcomp --ipcompspi 0x87 -j DROP
> >>
> >>Then input IPComp packet with CPI equates 0x87 will not reach
> >>upper layer anymore.
> >
> >I think that, with a little bit more work, you can add support for
> >IPv6 as well. From RFC 3173:
> >
> >"In the IPv6 context, IPComp is viewed as an end-to-end payload, and
> >MUST NOT apply to hop-by-hop, routing, and fragmentation extension
> >headers.
> >
> >You can perform that IPv6-specific handling to skip these extension
> >headers and reach the IPComp header by means of the ipv6_find_hdr()
> >helper function.

I just noted that you always have to use -p 108 to get this match
working, in that case the ip6_tables already sets par->thoff that you
can use to reach the transport header, so you can skip calling
ipv6_find_hdr(). So adding IPv6 support is even easier to make.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
