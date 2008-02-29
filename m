From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH net-2.6.26 3/4] Use seq_open_private in appletalk and
	decnet.
Date: Fri, 29 Feb 2008 11:10:59 -0300
Message-ID: <20080229141059.GK4306@ghostprotocols.net>
References: <47C80D28.9020009@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christine Caulfield <christine.caulfield@googlemail.com>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53184 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751102AbYB2OLH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 09:11:07 -0500
Content-Disposition: inline
In-Reply-To: <47C80D28.9020009@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Feb 29, 2008 at 04:48:24PM +0300, Pavel Emelyanov escreveu:
> These two also perform manual seq_open_private, so patch them both
> at once. But unlike ATM code, these already use the seq_release_private, 
> so I splitted this patch from the previous one.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
 
> ---
> 
> diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
> index 18058bb..61166f6 100644
> --- a/net/appletalk/aarp.c
> +++ b/net/appletalk/aarp.c
> @@ -1033,25 +1033,8 @@ static const struct seq_operations aarp_seq_ops = {
>  
>  static int aarp_seq_open(struct inode *inode, struct file *file)
>  {
> -	struct seq_file *seq;
> -	int rc = -ENOMEM;
> -	struct aarp_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
> -
> -	if (!s)
> -		goto out;
> -
> -	rc = seq_open(file, &aarp_seq_ops);
> -	if (rc)
> -		goto out_kfree;
> -
> -	seq	     = file->private_data;
> -	seq->private = s;
> -	memset(s, 0, sizeof(*s));
> -out:
> -	return rc;
> -out_kfree:
> -	kfree(s);
> -	goto out;
> +	return seq_open_private(file, &aarp_seq_ops,
> +			sizeof(struct aarp_iter_state));
>  }
>  
>  const struct file_operations atalk_seq_arp_fops = {
> 
> diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
> index acd48ee..23fd95a 100644
> --- a/net/decnet/af_decnet.c
> +++ b/net/decnet/af_decnet.c
> @@ -2320,25 +2320,8 @@ static const struct seq_operations dn_socket_seq_ops = {
>  
>  static int dn_socket_seq_open(struct inode *inode, struct file *file)
>  {
> -	struct seq_file *seq;
> -	int rc = -ENOMEM;
> -	struct dn_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
> -
> -	if (!s)
> -		goto out;
> -
> -	rc = seq_open(file, &dn_socket_seq_ops);
> -	if (rc)
> -		goto out_kfree;
> -
> -	seq		= file->private_data;
> -	seq->private	= s;
> -	memset(s, 0, sizeof(*s));
> -out:
> -	return rc;
> -out_kfree:
> -	kfree(s);
> -	goto out;
> +	return seq_open_private(file, &dn_socket_seq_ops,
> +			sizeof(struct dn_iter_state));
>  }
>  
>  static const struct file_operations dn_socket_seq_fops = {
> 
