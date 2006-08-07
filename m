From: Xiaolan Zhang <cxzhang@us.ibm.com>
Subject: Re: [SELinux]: selinux_socket_getpeersec_dgram() compile fix
Date: Mon, 7 Aug 2006 00:07:10 -0400
Message-ID: <OFCA41DD70.986D1781-ON852571C3.00168B57-852571C3.0016A014@us.ibm.com>
References: <20060805115620.GO14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: cxzhang@watson.ibm.com, davem@davemloft.net, jmorris@namei.org,
	netdev@vger.kernel.org, paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:37318 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751010AbWHGEHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 00:07:14 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7747EMu028209
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 00:07:14 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k7747DDR222220
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 00:07:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7747Ccv023709
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 00:07:13 -0400
In-Reply-To: <20060805115620.GO14627@postel.suug.ch>
To: Thomas Graf <tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: Catherine Zhang <cxzhang@watson.ibm.com>

Thomas Graf <tgraf@suug.ch> wrote on 08/05/2006 07:56:20 AM:

> Collision between "[NetLabel]: SELinux support"  and
> "[AF_UNIX]: Kernel memory leak fix for af_unix datagram getpeersec"
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Index: net-2.6.19.git/security/selinux/hooks.c
> ===================================================================
> --- net-2.6.19.git.orig/security/selinux/hooks.c
> +++ net-2.6.19.git/security/selinux/hooks.c
> @@ -3556,9 +3556,9 @@ static int selinux_socket_getpeersec_dgr
>     if (sock && (sock->sk->sk_family == PF_UNIX))
>        selinux_get_inode_sid(SOCK_INODE(sock), &peer_secid);
>     else if (skb) {
> -      peer_sid = selinux_netlbl_socket_getpeersec_dgram(skb);
> -      if (peer_sid == SECSID_NULL)
> -         peer_sid = selinux_socket_getpeer_dgram(skb);
> +      peer_secid = selinux_netlbl_socket_getpeersec_dgram(skb);
> +      if (peer_secid == SECSID_NULL)
> +         peer_secid = selinux_socket_getpeer_dgram(skb);
>     }
> 
>     if (peer_secid == SECSID_NULL)

