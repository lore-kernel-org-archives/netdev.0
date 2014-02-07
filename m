From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Fix runtime WARNING in rtmsg_ifa()
Date: Thu, 06 Feb 2014 20:03:00 -0800 (PST)
Message-ID: <20140206.200300.862172310084916848.davem@davemloft.net>
References: <1391585905-24851-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, cwang@twopensource.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391585905-24851-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed,  5 Feb 2014 08:38:25 +0100

> On m68k/ARAnyM:
 ...
> Adding some debugging code reveals that net_fill_ifaddr() fails in
> 
>     put_cacheinfo(skb, ifa->ifa_cstamp, ifa->ifa_tstamp,
>                               preferred, valid))
> 
> nla_put complains:
> 
>     lib/nlattr.c:454: skb_tailroom(skb) = 12, nla_total_size(attrlen) = 20
> 
> Apparently commit 5c766d642bcaffd0c2a5b354db2068515b3846cf ("ipv4:
> introduce address lifetime") forgot to take into account the addition of
> struct ifa_cacheinfo in inet_nlmsg_size(). Hence add it, like is already
> done for ipv6.
> 
> Suggested-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied and queued up for -stable, thanks!
