From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netfilter: turn NF_HOOK into an inline function
Date: Fri, 09 Oct 2015 13:21:54 -0500
Message-ID: <877fmvzyv1.fsf@x220.int.ebiederm.org>
References: <201510092113.o4u2vjMD%fengguang.wu@intel.com>
	<37905061.HAWoCKur8L@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <37905061.HAWoCKur8L@wuerfel> (Arnd Bergmann's message of "Fri,
	09 Oct 2015 15:15:59 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> On Friday 09 October 2015 21:03:57 kbuild test robot wrote:
>> ^1da177e Linus Torvalds    2005-04-16  818      cb->rt_flags &= ~DN_RT_F_IE;
>> ^1da177e Linus Torvalds    2005-04-16  819      if (rt->rt_flags & RTCF_DOREDIRECT)
>> ^1da177e Linus Torvalds    2005-04-16  820              cb->rt_flags |= DN_RT_F_IE;
>> ^1da177e Linus Torvalds    2005-04-16  821  
>> 29a26a56 Eric W. Biederman 2015-09-15  822      return NF_HOOK(NFPROTO_DECNET, NF_DN_FORWARD,
>> 29a26a56 Eric W. Biederman 2015-09-15 @823                     &init_net, NULL, skb, dev, skb->dev,
>> 8f40b161 David S. Miller   2011-07-17  824                     dn_to_neigh_output);
>> ^1da177e Linus Torvalds    2005-04-16  825  
>> ^1da177e Linus Torvalds    2005-04-16  826  drop:
>> 
>
> Ah, right. The 'dev' variable here is declared as
>
> #ifdef CONFIG_NETFILTER
>         struct net_device *dev = skb->dev;
> #endif
>
> Apparently because the code produced the same warning as the ipv6 code.
>
> Removing the #ifdef here would make that code nicer and let us use
> my patch. Alternatively we could put the same #ifdef into IPV6 and
> not use the inline function.

Compilers are good at removing unused variabes (SSA should guarantee
this will always happen), and #ifdefs sucks.  I vote for your inline.
Especially as the case that is actively used and tested
(CONFIG_NETFILTER) has these two functions as inline functions.

Eric
