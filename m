From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/6] bond: Implement a basic set of rtnl link ops
Date: Fri, 30 Oct 2009 09:06:00 +0100
Message-ID: <4AEA9E68.5070204@trash.net>
References: <m1tyxhwxah.fsf@fess.ebiederm.org> <1256861906-5059-5-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37179 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895AbZJ3IGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 04:06:05 -0400
In-Reply-To: <1256861906-5059-5-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> @@ -5115,6 +5118,10 @@ static int __init bonding_init(void)
>  
>  	bond_create_proc_dir();
>  
> +	res = rtnl_link_register(&bond_link_ops);
> +	if (res)
> +		goto err;

The error handling looks wrong, at err: you call rtnl_link_unregister()
after rtnl_link_register() failed.

> +
>  	for (i = 0; i < max_bonds; i++) {
>  		res = bond_create(NULL);
>  		if (res)
> @@ -5128,14 +5135,12 @@ static int __init bonding_init(void)
>  	register_netdevice_notifier(&bond_netdev_notifier);
>  	register_inetaddr_notifier(&bond_inetaddr_notifier);
>  	bond_register_ipv6_notifier();
> -
> -	goto out;
> -err:
> -	rtnl_lock();
> -	bond_free_all();
> -	rtnl_unlock();
>  out:
>  	return res;
> +err:
> +	rtnl_link_unregister(&bond_link_ops);
> +	bond_destroy_proc_dir();
> +	goto out;
>  
>  }
