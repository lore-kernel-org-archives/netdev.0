From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH 1/3] net: Remove unnecessary memset in
 __snmp6_fill_stats64
Date: Mon, 8 Aug 2016 13:12:31 +0200
Message-ID: <20160808111231.GA20192@breakpoint.cc>
References: <1470651742-15195-1-git-send-email-hejianet@gmail.com>
 <1470651742-15195-2-git-send-email-hejianet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Jia He <hejianet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1470651742-15195-2-git-send-email-hejianet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jia He <hejianet@gmail.com> wrote:
> buff[] will be assigned later, so memset is not necessary.
> 
> Signed-off-by: Jia He <hejianet@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> ---
>  net/ipv6/addrconf.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index ab3e796..43fa8d0 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -4967,7 +4967,6 @@ static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
>  
>  	BUG_ON(pad < 0);
>  
> -	memset(buff, 0, sizeof(buff));
>  	buff[0] = IPSTATS_MIB_MAX;
>  
>  	for_each_possible_cpu(c) {
                for (i = 1; i < IPSTATS_MIB_MAX; i++)
                        buff[i] += snmp_get_cpu_field64(mib, c, i, syncpoff);

Without memset result of buff[i] += ... is undefined.
