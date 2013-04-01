From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next v1 3/4] vxlan: add ipv6 support
Date: Mon, 1 Apr 2013 13:14:50 -0700
Message-ID: <20130401131450.5d6bbc1e@nehalam.linuxnetplumber.net>
References: <1364708625-29063-1-git-send-email-amwang@redhat.com>
	<1364708625-29063-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:44553 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969Ab3DAUPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 16:15:08 -0400
Received: by mail-da0-f54.google.com with SMTP id p1so1193736dad.27
        for <netdev@vger.kernel.org>; Mon, 01 Apr 2013 13:15:07 -0700 (PDT)
In-Reply-To: <1364708625-29063-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 31 Mar 2013 13:43:44 +0800
Cong Wang <amwang@redhat.com> wrote:

>  	/* Need to drop RTNL to call multicast leave */
>  	rtnl_unlock();
> -	lock_sock(sk);
> -	err = ip_mc_leave_group(sk, &mreq);
> +	if (vxlan->gaddr.proto == htons(ETH_P_IP)) {
> +		lock_sock(sk);
> +		err = ip_mc_leave_group(sk, &mreq);
> +	} else {
> +#if IS_ENABLED(CONFIG_IPV6)
> +		lock_sock(sk);
> +		err = ipv6_sock_mc_drop(sk, vxlan->link, &vxlan->gaddr.ip6);
> +#endif
> +	}
>  	release_sock(sk);

Since both v4 and v6 need socket locked why not?

	rtnl_unlock();
	lock_sock(sk);
	if (vxlan->gaddr.proto == htons(ETH_P_IP)) 
		err = ip_mc_leave_group(sk, &mreq);
if IS_ENABLED(CONFIG_IPV6)
	else
		err = ipv6_sock_mc_drop(sk, vxlan->link, &vxlan->gaddr.ip6);
#endif

  	release_sock(sk);
