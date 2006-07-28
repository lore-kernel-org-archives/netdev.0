From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Fri, 28 Jul 2006 00:55:42 -0700 (PDT)
Message-ID: <20060728.005542.21593420.davem@davemloft.net>
References: <20060717155224.060020000@hp.com>
	<20060717155822.315389000@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@epoch.ncsc.mil,
	jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14218
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030229AbWG1H4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 03:56:08 -0400
To: paul.moore@hp.com
In-Reply-To: <20060717155822.315389000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: paul.moore@hp.com
Date: Mon, 17 Jul 2006 11:52:26 -0400

> @@ -617,6 +618,8 @@ int inet_accept(struct socket *sock, str
>  
>  	sock_graft(sk2, newsock);
>  
> +	netlbl_socket_inet_accept(sock, newsock);
> +
>  	newsock->state = SS_CONNECTED;
>  	err = 0;
>  	release_sock(sk2);

This is only true wart I see in the patch set from my
perspective.

You have security_post_accept_hook(), which gets the parent and
the child socket which is all the information you need, and it
seems to be invoked at the correct location.

So can you please hook into this location using the security
level hook we already have?  Just check sock->sk->sk_family is
PF_INET at the top of that hook if you only want to handle
ipv4 sockets, or something like that.

Could this work?

When preparing and argument stating why this won't work, please
suggest a nicer name for this af_inet.c hook or some way to make
it more generic and palatable to us.

Thanks.

> -		case 0x86:	/* Another "Commercial Security" crap. */
> +		case IPOPT_CIPSO:

I am sad to see this comment disappear :-)
