From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: [PATCH][DECNET] dn_nl_deladdr() almost always returns no error
Date: Thu, 29 Nov 2007 16:35:43 +0000
Message-ID: <20071129163543.GA15456@fogou.chygwyn.com>
References: <474EE8E0.3050107@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick Caulfield <patrick@tykepenguin.com>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	linux-decnet-user@lists.sourceforge.net
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:55840 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761738AbXK2QyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 11:54:22 -0500
Content-Disposition: inline
In-Reply-To: <474EE8E0.3050107@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Nov 29, 2007 at 07:29:20PM +0300, Pavel Emelyanov wrote:
> As far as I see from the err variable initialization
> the dn_nl_deladdr() routine was designed to report errors
> like "EADDRNOTAVAIL" and probaby "ENODEV".
> 
> But the code sets this err to 0 after the first nlmsg_parse
> and goes on, returning this 0 in any case.
> 
> Is this made deliberately, or the patch below is correct?
>
The patch looks good to me.
 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Steve.

> 
> ---
> 
> diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
> index 66e266f..3bc82dc 100644
> --- a/net/decnet/dn_dev.c
> +++ b/net/decnet/dn_dev.c
> @@ -651,16 +651,18 @@ static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
>  	struct dn_dev *dn_db;
>  	struct ifaddrmsg *ifm;
>  	struct dn_ifaddr *ifa, **ifap;
> -	int err = -EADDRNOTAVAIL;
> +	int err;
>  
>  	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy);
>  	if (err < 0)
>  		goto errout;
>  
> +	err = -ENODEV;
>  	ifm = nlmsg_data(nlh);
>  	if ((dn_db = dn_dev_by_index(ifm->ifa_index)) == NULL)
>  		goto errout;
>  
> +	err = -EADDRNOTAVAIL;
>  	for (ifap = &dn_db->ifa_list; (ifa = *ifap); ifap = &ifa->ifa_next) {
>  		if (tb[IFA_LOCAL] &&
>  		    nla_memcmp(tb[IFA_LOCAL], &ifa->ifa_local, 2))
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
