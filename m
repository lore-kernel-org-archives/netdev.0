From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH nf-next] netfilter: nf_conntrack: make nf_ct_zone_dflt
 built-in
Date: Wed, 02 Sep 2015 16:33:28 -0700 (PDT)
Message-ID: <20150902.163328.2105819031511147300.davem@davemloft.net>
References: <e3e68a263cbf95761bd3f759f458f43973741584.1441235714.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, fengguang.wu@intel.com, fw@strlen.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <e3e68a263cbf95761bd3f759f458f43973741584.1441235714.git.daniel@iogearbox.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu,  3 Sep 2015 01:26:07 +0200

> Fengguang reported, that some randconfig generated the following linker
> issue with nf_ct_zone_dflt object involved:
> 
>   [...]
>   CC      init/version.o
>   LD      init/built-in.o
>   net/built-in.o: In function `ipv4_conntrack_defrag':
>   nf_defrag_ipv4.c:(.text+0x93e95): undefined reference to `nf_ct_zone_dflt'
>   net/built-in.o: In function `ipv6_defrag':
>   nf_defrag_ipv6_hooks.c:(.text+0xe3ffe): undefined reference to `nf_ct_zone_dflt'
>   make: *** [vmlinux] Error 1
> 
> Given that configurations exist where we have a built-in part, which is
> accessing nf_ct_zone_dflt such as the two handlers nf_ct_defrag_user()
> and nf_ct6_defrag_user(), and a part that configures nf_conntrack as a
> module, we must move nf_ct_zone_dflt into a fixed, guaranteed built-in
> area when netfilter is configured in general.
> 
> Therefore, split the more generic parts into a common header under
> include/linux/netfilter/ and move nf_ct_zone_dflt into the built-in
> section that already holds parts related to CONFIG_NF_CONNTRACK in the
> netfilter core. This fixes the issue on my side.
> 
> Fixes: 308ac9143ee2 ("netfilter: nf_conntrack: push zone object into functions")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  [ Here's the 2nd one for either nf-next or net-next. I've tried various
>    Kconfig combinations including the one Fengguang reported, seems to be
>    okay from my side. ]

Ok I'll apply this directly too, thanks Daniel.

If Pablo and others want to fix this another way, they can send me
a relative patch.

Thanks.
