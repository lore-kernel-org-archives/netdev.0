From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 28 Apr 2014 14:19:38 -0400
Message-ID: <20140428181938.GA24111@madcap2.tricolour.ca>
References: <20140428125759.47924ab500af7624f401d424@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Paris <eparis@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140428125759.47924ab500af7624f401d424@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/04/28, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in
> net/netlink/af_netlink.c between commit 5187cd055b6e ("netlink: Rename
> netlink_capable netlink_allowed") from the net tree and commit
> 4f520900522f ("netlink: have netlink per-protocol bind function return an
> error code") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Works for me.  Thanks Stephen.

> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> 
> diff --cc net/netlink/af_netlink.c
> index 81dca96d2be6,92f4b6915e89..000000000000
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@@ -1492,8 -1445,8 +1510,8 @@@ static int netlink_bind(struct socket *
>   		return -EINVAL;
>   
>   	/* Only superuser is allowed to listen multicasts */
> - 	if (nladdr->nl_groups) {
> + 	if (groups) {
>  -		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV))
>  +		if (!netlink_allowed(sock, NL_CFG_F_NONROOT_RECV))
>   			return -EPERM;
>   		err = netlink_realloc_groups(sk);
>   		if (err)

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
