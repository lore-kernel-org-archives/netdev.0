From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Thu, 12 Feb 2004 11:03:28 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040212.110328.103131455.yoshfuji@linux-ipv6.org>
References: <20040211.160152.48476158.yoshfuji@linux-ipv6.org>
	<OFA4C00EE0.FAE8C2B9-ON88256E37.0072FEDF-88256E37.00732B00@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OFA4C00EE0.FAE8C2B9-ON88256E37.0072FEDF-88256E37.00732B00@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OFA4C00EE0.FAE8C2B9-ON88256E37.0072FEDF-88256E37.00732B00@us.ibm.com> (at Wed, 11 Feb 2004 14:00:39 -0700), David Stevens <dlstevens@us.ibm.com> says:

> Ok, here's what I hope is the final version of the patch, so we can
> finally put this to bed. :-)

Well...

> +                 hdr = skb->nh.ipv6h;
> +                 if (ipv6_addr_is_multicast(&hdr->daddr) &&
> +                     !ipv6_chk_mcast_addr(skb->dev, &hdr->daddr,
> +                     &hdr->saddr) &&
> +                     !ipv6_is_mld(skb))
> +                       goto discard;
:

You forgot to check if proto is IPPROTO_ICMPV6.
(This is one reason why I want to check the icmpv6 code 
 in icmpv6_rcv().)

  if (ipv6_addr_is_multicast(&hdr->daddr) &&
      !ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, &hdr->saddr) &&
      (proto != IPPROTO_ICMPV6 || !ipv6_is_mld(skb)))
          goto discard;

And, the name ipv6_is_mld should be icmpv6_is_mld or 
something like this now.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
