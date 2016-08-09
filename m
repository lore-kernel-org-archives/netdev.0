From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/3] net: Remove unnecessary memset in
 __snmp6_fill_stats64
Date: Tue, 09 Aug 2016 12:12:51 +0200
Message-ID: <1470737571.5324.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1470651742-15195-1-git-send-email-hejianet@gmail.com>
	 <1470651742-15195-2-git-send-email-hejianet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Jia He <hejianet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33299 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbcHIKMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 06:12:54 -0400
In-Reply-To: <1470651742-15195-2-git-send-email-hejianet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-08-08 at 18:22 +0800, Jia He wrote:
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

This is completely buggy, since we performs additions, not assignments :



buff[i] += snmp_get_cpu_field64(mib, c, i, syncpoff);


Please do not send untested patches.
