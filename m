From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net-next] ieee802154: fix variable
 declaration and initializer
Date: Tue, 18 Mar 2014 22:11:28 -0700
Message-ID: <1395205888.8649.36.camel@joe-AO722>
References: <1395199198-14310-1-git-send-email-sakiwit@gmail.com>
	<1395199941.9114.47.camel@edumazet-glaptop2.roam.corp.google.com>
	<1395200557.8649.20.camel@joe-AO722>
	<1395203754.9114.54.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140319045634.GB1448@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Jean Sacren <sakiwit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20140319045634.GB1448-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-03-18 at 22:56 -0600, Jean Sacren wrote:
> Stating it is a "fix" is not a false statement at all. !! falsely
> changes the value to be int TWICE for nothing! Are you still not
> convinced?

Not so fast Jean.  There's no logic change.

Changing the type to bool does exactly the same thing
and doesn't change the generated object code at all.

$ diff net/ieee802154/nl-phy.lst.new net/ieee802154/nl-phy.lst.old
2289d2288
< static int phy_set_lbt(struct wpan_phy *phy, struct genl_info *info)
2291c2290
< 	u8 on = !!nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
---
> 	bool on;
2293a2293
> 	on = nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
2296,2298d2295
< 	return 0;
< }
< 
2301,2303c2298
< 	u8 on = !!nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
<     1096:	80 78 04 00          	cmpb   $0x0,0x4(%rax)
<     109a:	41 0f 95 c5          	setne  %r13b
---
> 	bool on;
2305a2301,2303
> 	on = nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
>     1096:	80 78 04 00          	cmpb   $0x0,0x4(%rax)
>     109a:	41 0f 95 c5          	setne  %r13b
2322c2320
< 
---



------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
