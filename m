From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Sun, 20 Feb 2005 08:13:28 +0100
Message-ID: <42183898.7020607@trash.net>
References: <4217266F.6090700@trash.net>	<20050219184351.GB10773@gondor.apana.org.au>	<42182082.9060301@trash.net> <20050220.155527.54695259.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net, netdev@oss.sgi.com
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050220.155527.54695259.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / $B5HF#1QL@ wrote:

> I didn't this because there are several places which depend on u8.
> If we go this way, we need to fix other places as well. e.g.
> 
>   net/ipv4/raw.c:raw_probe_proto_opt()

                                 get_user(fl->fl_icmp_type, type);
                                 __get_user(fl->fl_icmp_code, code);

On x86_64 both care only about the pointer type, not the target type.

>   net/ipv4/xfrm4_policy.c:_decode_session4()

                                 u8 *icmp = xprth;

                                 fl->fl_icmp_type = icmp[0];
                                 fl->fl_icmp_code = icmp[1];

No problem here.

>   net/ipv6/raw.c:rawv6_probe_proto_opt()

Same as IPv4.

>   net/ipv6/netfilter/ip6t_REJECT.c:send_unreach()

Not in mainline :)

>   net/ipv6/xfrm6_policy.c:_decode_session6()

Same as IPv4.

>   net/ipv6/ndisc.c:ndisc_flow_init()

         fl->fl_icmp_type        = type;
         fl->fl_icmp_code        = 0;

No problem.

>   net/ipv6/icmp.c:icmpv6_send()

         fl.fl_icmp_type = type;
         fl.fl_icmp_code = code;

Also ok.

>   net/ipv6/icmp.c:icmpv6_echo_reply()

         fl.fl_icmp_type = ICMPV6_ECHO_REPLY;

Same here.

> 
> (Note that type and code are stored in network-byte order.)

Both are u8 so there is no byte order.

Regards
Patrick
