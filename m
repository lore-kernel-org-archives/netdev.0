From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Sat, 07 Feb 2004 13:22:33 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040207.132233.21960944.yoshfuji@linux-ipv6.org>
References: <20040206195325.207aa1c7.davem@redhat.com>
	<OF293C5854.C480643B-ON88256E33.0016BE45-88256E33.0016EBE0@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OF293C5854.C480643B-ON88256E33.0016BE45-88256E33.0016EBE0@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF293C5854.C480643B-ON88256E33.0016BE45-88256E33.0016EBE0@us.ibm.com> (at Fri, 6 Feb 2004 21:12:59 -0700), David Stevens <dlstevens@us.ibm.com> says:

> > David, please don't pollute global name space so badly :-)
> > ipv6_is_mld() would be fine.
> 
> Of course, sorry about that. :-)

Why not in icmpv6_rcv()?
we need to do pskb_pull() before touching type/code.

>  int ip6_mc_input(struct sk_buff *skb)
>  {
> -     struct ipv6hdr *hdr;
> -     int deliver = 0;
> +     int deliver = 1;
>       int discard = 1;
> 
>       IP6_INC_STATS_BH(Ip6InMcastPkts);
> 
> -     hdr = skb->nh.ipv6h;
> -     if (ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, &hdr->saddr))
> -           deliver = 1;
> -

Please do not remove this.
We need to check destination (but not source)
because the driver may be in "promisc." mode.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
