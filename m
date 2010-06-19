From: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Subject: Re: potential bug in bnep_net_set_mc_list()
Date: Fri, 18 Jun 2010 21:22:13 -0300
Message-ID: <20100619002213.GC14514@vigoh>
References: <20100618230916.GA5467@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100618230916.GA5467@bicker>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dan,

* Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> [2010-06-19 01:09:17 +0200]:

> This is from ff6e2163f28a: "net: convert multiple drivers to use
> netdev_for_each_mc_addr, part7"
> 
> net/bluetooth/bnep/netdev.c
>    101                  i = 0;
>    102                  netdev_for_each_mc_addr(ha, dev) {
>    103                          if (i == BNEP_MAX_MULTICAST_FILTERS)
>                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
>    104                                  break;
>    105                          memcpy(__skb_put(skb, ETH_ALEN), ha->addr, ETH_ALEN);
>    106                          memcpy(__skb_put(skb, ETH_ALEN), ha->addr, ETH_ALEN);
>    107                  }
> 
> "i" is never incremented here so the check is always false.

Bring back the increment should fix this. I'll send a fix for this.

-- 
Gustavo F. Padovan
http://padovan.org
