From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ipv6: invert join/leave anycast  rtnl/socket
 locking order
Date: Fri, 20 Mar 2015 17:24:32 +0300
Message-ID: <550C2DA0.6050809@cogentembedded.com>
References: <1426857632-17879-1-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:33090 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbbCTOYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 10:24:36 -0400
Received: by lbbrr9 with SMTP id rr9so11991402lbb.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 07:24:35 -0700 (PDT)
In-Reply-To: <1426857632-17879-1-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/20/2015 4:20 PM, Marcelo Ricardo Leitner wrote:

> Commit baf606d9c9b1 ("ipv4,ipv6: grab rtnl before locking the socket")
> missed to update two setsockopt options, IPV6_JOIN_ANYCAST and
> IPV6_LEAVE_ANYCAST, causing a lock inverstion regarding the updated ones.

> As ipv6_sock_ac_join and ipv6_sock_ac_leave are only called from
> do_ipv6_setsockopt, we are good to just move the rtnl lock upper.

> Fixes: baf606d9c9b1 ("ipv4,ipv6: grab rtnl before locking the socket")
> Reported-by: Ying Huang <ying.huang@intel.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>   net/ipv6/anycast.c       | 9 ++++-----
>   net/ipv6/ipv6_sockglue.c | 2 ++
>   2 files changed, 6 insertions(+), 5 deletions(-)

> diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
> index baf2742d1ec47ee1b9cf62d087afb8b7d7195921..a1db95e863ffdd1aa1cb5112da11ccdef9e945fd 100644
> --- a/net/ipv6/anycast.c
> +++ b/net/ipv6/anycast.c
[...]
> @@ -155,7 +156,6 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
>   		prev_pac = pac;
>   	}
>   	if (!pac) {
> -		rtnl_unlock();
>   		return -ENOENT;
>   	}

    Get rid of {} please, as they're not needed anymore.

[...]

WBR, Sergei
