From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Sun, 20 Feb 2005 15:55:27 +0900 (JST)
Message-ID: <20050220.155527.54695259.yoshfuji@linux-ipv6.org>
References: <4217266F.6090700@trash.net>
	<20050219184351.GB10773@gondor.apana.org.au>
	<42182082.9060301@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
To: kaber@trash.net
In-Reply-To: <42182082.9060301@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <42182082.9060301@trash.net> (at Sun, 20 Feb 2005 06:30:42 +0100), Patrick McHardy <kaber@trash.net> says:

> Herbert Xu wrote:
> 
> > I know this comment is probably a bit late but why didn't we simply put
> > type/code into sport/dport in struct flowi instead of introducing the
> > monstrosities of xfrm_flowi_sport/xfrm_flowi_dport?
> > 
> > Something like
> > 
> > struct {
> > 	__u16	type;
> > 	__u16	code;
> > } icmpt;
> > 
> > would've done (and still would do) the trick, no?
> 
> Here is an updated patch that kills xfrm_flowi_{sport,dport}.
> I've checked around, there seems to be nothing that relies
> on type and code beeing u8.

I didn't this because there are several places which depend on u8.
If we go this way, we need to fix other places as well. e.g.

  net/ipv4/raw.c:raw_probe_proto_opt()
  net/ipv4/xfrm4_policy.c:_decode_session4()
  net/ipv6/raw.c:rawv6_probe_proto_opt()
  net/ipv6/netfilter/ip6t_REJECT.c:send_unreach()
  net/ipv6/xfrm6_policy.c:_decode_session6()
  net/ipv6/ndisc.c:ndisc_flow_init()
  net/ipv6/icmp.c:icmpv6_send()
  net/ipv6/icmp.c:icmpv6_echo_reply()

(Note that type and code are stored in network-byte order.)

--yoshfuji
