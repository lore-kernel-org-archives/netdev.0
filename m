From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Thu, 05 Jun 2003 19:12:24 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030605.191224.68706097.yoshfuji@linux-ipv6.org>
References: <20030424132559.GA15894@morphine.tml.hut.fi>
	<Pine.LNX.4.44.0305301712300.3584-200000@rhea.tcs.hut.fi>
	<20030531.000319.114704530.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   ajtuomin@morphine.tml.hut.fi, lpetande@morphine.tml.hut.fi,
   jagana@us.ibm.com, kumarkr@us.ibm.com, yoshfuji@linux-ipv6.org,
   nakam@linux-ipv6.org, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <20030531.000319.114704530.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030531.000319.114704530.yoshfuji@linux-ipv6.org> (at Sat, 31 May 2003 00:03:19 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <Pine.LNX.4.44.0305301712300.3584-200000@rhea.tcs.hut.fi> (at Fri, 30 May 2003 17:34:40 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
> 
> > here is a patch that fixes CONFIG_IPV6_SUBTREES and allows overriding
> > normal routes with source address specific ones. This is for example
> > needed in MIPv6 for handling the traffic to and from a mobile node's home
> > address correctly.
> 
> Let us test the patch.  It seemed buggy when USAGI tested before.

I've re-tested your latest CONFIG_IPV6_SUBTREE patch.
The results of the restesting seems fine.
However, I won't accept your patch as-is for now.

The patch consists of several parts:

 1. fixing bugs in IPv6 code
 2. fixing bugs in CONFIG_IPV6_SUBTREE code
 3. changing majority of keys of routing table.

There's no problems with 1 and 2.  
However, We need to discuss on 3.


As I said in other thread, the policy routing should be done in the 
other way.  And, it is not good to change the semantics of 
CONFIG_IPV6_SUBTREE.

In original, routing is looked up by destination address, and then,
looked up by the source address; destination takes precedence over source.
Your patch changes this. Source address takes precedence over destination 
address.

>From the point of the policy routing, both (and other attributes) should be 
considered equally, and this is what IPv4 routing table does.

Well, I won't hurry intorducing IPv6 policy routing just because of MIP6.
The reason why I won't hurry is because I still believe it is not
required for MIP6.  Nakamura, one of our member, will describe the details.
It takes precedence over "limited" policy(?) routing to introcuce generic 
policy routing.


Anyway, will you split up your patch (into 1-3 above) first, please?

Thanks.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
