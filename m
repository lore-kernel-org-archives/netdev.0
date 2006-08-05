From: Paul Moore <paul.moore@hp.com>
Subject: Re: [SELinux]: selinux_socket_getpeersec_dgram() compile fix
Date: Sat, 5 Aug 2006 16:12:51 -0400
Message-ID: <200608051612.52528.paul.moore@hp.com>
References: <20060805115620.GO14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, cxzhang@watson.ibm.com, jmorris@namei.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:24006 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S932311AbWHEUNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2006 16:13:00 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060805115620.GO14627@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 05 August 2006 7:56 am, Thomas Graf wrote:
> Collision between "[NetLabel]: SELinux support"  and
> "[AF_UNIX]: Kernel memory leak fix for af_unix datagram getpeersec"
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I have no idea what the correct protocol is here, i.e. do I need to Ack this?  
However, I've never "Ack'd" anything before and I figure an extra Ack won't 
hurt anything :)

Acked-by: Paul Moore <paul.moore@hp.com>

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
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
paul moore
linux security @ hp
