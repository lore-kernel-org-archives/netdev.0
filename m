From: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: potential bug in bnep_net_set_mc_list()
Date: Sat, 19 Jun 2010 01:09:17 +0200
Message-ID: <20100618230916.GA5467@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is from ff6e2163f28a: "net: convert multiple drivers to use
netdev_for_each_mc_addr, part7"

net/bluetooth/bnep/netdev.c
   101                  i = 0;
   102                  netdev_for_each_mc_addr(ha, dev) {
   103                          if (i == BNEP_MAX_MULTICAST_FILTERS)
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   104                                  break;
   105                          memcpy(__skb_put(skb, ETH_ALEN), ha->addr, ETH_ALEN);
   106                          memcpy(__skb_put(skb, ETH_ALEN), ha->addr, ETH_ALEN);
   107                  }

"i" is never incremented here so the check is always false.

regards,
dan carpenter
