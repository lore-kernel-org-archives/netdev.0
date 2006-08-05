From: James Morris <jmorris@namei.org>
Subject: Re: [SELinux]: selinux_socket_getpeersec_dgram() compile fix
Date: Sat, 5 Aug 2006 09:02:47 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608050902330.18307@d.namei>
References: <20060805115620.GO14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, paul.moore@hp.com, cxzhang@watson.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:52649 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161433AbWHENCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 09:02:50 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060805115620.GO14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 5 Aug 2006, Thomas Graf wrote:

> Collision between "[NetLabel]: SELinux support"  and
> "[AF_UNIX]: Kernel memory leak fix for af_unix datagram getpeersec"
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: James Morris <jmorris@namei.org>


> 
> Index: net-2.6.19.git/security/selinux/hooks.c
> ===================================================================
> --- net-2.6.19.git.orig/security/selinux/hooks.c
> +++ net-2.6.19.git/security/selinux/hooks.c
> @@ -3556,9 +3556,9 @@ static int selinux_socket_getpeersec_dgr
>  	if (sock && (sock->sk->sk_family == PF_UNIX))
>  		selinux_get_inode_sid(SOCK_INODE(sock), &peer_secid);
>  	else if (skb) {
> -		peer_sid = selinux_netlbl_socket_getpeersec_dgram(skb);
> -		if (peer_sid == SECSID_NULL)
> -			peer_sid = selinux_socket_getpeer_dgram(skb);
> +		peer_secid = selinux_netlbl_socket_getpeersec_dgram(skb);
> +		if (peer_secid == SECSID_NULL)
> +			peer_secid = selinux_socket_getpeer_dgram(skb);
>  	}
>  
>  	if (peer_secid == SECSID_NULL)
> 

-- 
James Morris
<jmorris@namei.org>
