From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v6] netlink: have netlink per-protocol bind function
 return an error code.
Date: Wed, 26 Mar 2014 16:46:00 -0400 (EDT)
Message-ID: <20140326.164600.1051337978560114220.davem@davemloft.net>
References: <20140324183406.GE28666@madcap2.tricolour.ca>
	<32971f5def3bebff26650bc088c6f3f21f3c727b.1395751443.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	eparis@redhat.com, sgrubb@redhat.com, hadi@mojatatu.com
To: rgb@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <32971f5def3bebff26650bc088c6f3f21f3c727b.1395751443.git.rgb@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Guy Briggs <rgb@redhat.com>
Date: Tue, 25 Mar 2014 08:50:56 -0400

> @@ -1441,6 +1445,24 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
>  	if (!nladdr->nl_groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
>  		return 0;
>  
> +	if (nlk->netlink_bind && nladdr->nl_groups) {
> +		int i;
> +
> +		for (i = 0; i < nlk->ngroups; i++)
 ...
> +				if (err) {
> +					int undo;
> +					if (!nlk->portid)
> +						netlink_remove(sk);

Please put an empty line between local variable declarations and code, just as it
is a few lines up.
