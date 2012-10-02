From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] vxlan: put UDP socket in correct namespace
Date: Mon, 01 Oct 2012 17:58:13 -0700
Message-ID: <87626tbsgq.fsf@xmission.com>
References: <20121001141609.14639bc0@nehalam.linuxnetplumber.net>
	<20121001145838.5eafef4c@nehalam.linuxnetplumber.net>
	<87fw5xeryf.fsf@xmission.com>
	<20121001155702.5b5e2188@nehalam.linuxnetplumber.net>
	<87y5jpdbzo.fsf@xmission.com>
	<20121001163226.3873ca58@nehalam.linuxnetplumber.net>
	<871uhhd82p.fsf@xmission.com>
	<20121001175107.0ec2931c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:60950 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300Ab2JBA6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 20:58:19 -0400
In-Reply-To: <20121001175107.0ec2931c@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Mon, 1 Oct 2012 17:51:07 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> Move vxlan UDP socket to correct network namespace

You also need to replease sock_release with
sk_release_kernel.

Otherwise you will decrement the network namespace count
below zero, when sock_release is called.

Eric

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> --- a/drivers/net/vxlan.c	2012-10-01 17:18:30.776513263 -0700
> +++ b/drivers/net/vxlan.c	2012-10-01 17:42:28.340411631 -0700
> @@ -1136,6 +1136,9 @@ static __net_init int vxlan_init_net(str
>  		pr_debug("UDP socket create failed\n");
>  		return rc;
>  	}
> +	/* Put in proper namespace */
> +	sk = vn->sock->sk;
> +	sk_change_net(sk, net);
>  
>  	vxlan_addr.sin_port = htons(vxlan_port);
>  
> @@ -1150,7 +1153,6 @@ static __net_init int vxlan_init_net(str
>  	}
>  
>  	/* Disable multicast loopback */
> -	sk = vn->sock->sk;
>  	inet_sk(sk)->mc_loop = 0;
>  
>  	/* Mark socket as an encapsulation socket. */
