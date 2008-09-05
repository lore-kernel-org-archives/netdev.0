From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 1/2] ipvs: load balance IPv4 connections from a local process
Date: Fri, 5 Sep 2008 13:02:44 +0200
Message-ID: <f4845fc0809050402x5552f526pc8511026d7faa359@mail.gmail.com>
References: <20080905013609.GD14128@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	"Malcolm Turnbull" <malcolm@loadbalancer.org>,
	"=?ISO-8859-1?Q?Siim_P=F5der?=" <siim@p6drad-teel.net>,
	"Vince Busam" <vbusam@google.com>
To: "Simon Horman" <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080905013609.GD14128@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 5, 2008 at 3:36 AM, Simon Horman <horms@verge.net.au> wrote:
> @@ -1244,11 +1278,12 @@ ip_vs_in(unsigned int hooknum, struct sk
>        ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
>
>        /*
> -        *      Big tappo: only PACKET_HOST (neither loopback nor mcasts)
> -        *      ... don't know why 1st test DOES NOT include 2nd (?)
> +        *      Big tappo: only PACKET_HOST, including loopback for local client
> +        *      Don't handle local packets on IPv6 for now
>         */
> -       if (unlikely(skb->pkt_type != PACKET_HOST
> -                    || skb->dev->flags & IFF_LOOPBACK || skb->sk)) {
> +       if (unlikely(skb->pkt_type != PACKET_HOST ||
> +                    (af == AF_INET6 || (skb->dev->flags & IFF_LOOPBACK ||
> +                                        skb->sk)))) {

Hm, shouldn't this be (af == AF_INET6 && ...) instead of "||"? The
current expression just NF_ACCEPTs _any_ incoming IPv6 packets, even
non-local ones.

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
