From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [Patch net-next 4/5] ipv6: drop ipv6_sk_mc_lock in mcast
Date: Wed, 10 Sep 2014 19:16:23 +0200
Message-ID: <20140910171623.GA12299@kria>
References: <1410306738-18036-1-git-send-email-xiyou.wangcong@gmail.com>
 <1410306738-18036-5-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:17725 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751715AbaIJRQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 13:16:30 -0400
Content-Disposition: inline
In-Reply-To: <1410306738-18036-5-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

2014-09-09, 16:52:17 -0700, Cong Wang wrote:
> Similarly the code is already protected by rtnl lock.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv6/mcast.c | 18 ++----------------
>  1 file changed, 2 insertions(+), 16 deletions(-)
> 
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 6833dd0..d2b7dd8 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -82,9 +82,6 @@ static void *__mld2_query_bugs[] __attribute__((__unused__)) = {
>  
>  static struct in6_addr mld2_all_mcr = MLD2_ALL_MCR_INIT;
>  
> -/* Big mc list lock for all the sockets */
> -static DEFINE_SPINLOCK(ipv6_sk_mc_lock);
> -

Just a small thing: there are a few comments in the file that still
refer to this lock (as ipv6_sk_mc_lock or ip6_sk_mc_lock):

--
	/*
	 * changes to the ipv6_mc_list require the socket lock and
	 * a read lock on ip6_sk_mc_lock. We have the socket lock,
	 * so reading the list is safe.
	 */
--
	/* changes to psl require the socket lock, a read lock on
	 * on ipv6_sk_mc_lock and a write lock on pmc->sflock. We
	 * have the socket lock, so reading here is safe.
	 */
--
	/* callers have the socket lock and a write lock on ipv6_sk_mc_lock,
	 * so no other readers or writers of iml or its sflist
	 */
--

If you submit a v2 of this patchset, you could update them. Otherwise,
I'll do it later.


Thanks,

-- 
Sabrina
