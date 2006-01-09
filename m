From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink oops fix due to incorrect error code
Date: Tue, 10 Jan 2006 00:50:52 +0100
Message-ID: <43C2F6DC.7040602@trash.net>
References: <43C27662.2030400@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org, Dmitry Mishin <dim@sw.ru>,
	Stanislav Protassov <st@sw.ru>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751648AbWAIXvl@vger.kernel.org>
To: Kirill Korotaev <dev@openvz.org>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <43C27662.2030400@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kirill Korotaev wrote:
> Fixed oops after failed netlink socket creation.
> Wrong parathenses in if() statement caused err to be 1,
> instead of negative value.
> Trivial fix, not trivial to find though.
> 
> Signed-Off-By: Dmitry Mishin <dim@sw.ru>
> Signed-Off-By: Kirill Korotaev <dev@openvz.org>

Good catch. Dave, please apply.

> 
> ------------------------------------------------------------------------
> 
> --- ./net/netlink/af_netlink.c.nlfix	2006-01-06 18:37:28.000000000 +0300
> +++ ./net/netlink/af_netlink.c	2006-01-09 16:40:49.000000000 +0300
> @@ -416,7 +416,7 @@ static int netlink_create(struct socket 
>  	groups = nl_table[protocol].groups;
>  	netlink_unlock_table();
>  
> -	if ((err = __netlink_create(sock, protocol) < 0))
> +	if ((err = __netlink_create(sock, protocol)) < 0)
>  		goto out_module;
>  
>  	nlk = nlk_sk(sock->sk);
> 
