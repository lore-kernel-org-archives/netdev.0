From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] socket: use iov_length()
Date: Wed, 14 Jan 2015 16:45:28 -0500 (EST)
Message-ID: <20150114.164528.230093054757243054.davem@davemloft.net>
References: <1421230070-4104-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbbANVpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 16:45:31 -0500
In-Reply-To: <1421230070-4104-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 14 Jan 2015 11:07:50 +0100

> @@ -883,10 +883,8 @@ static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
>  {
>  	struct socket *sock = file->private_data;
>  	size_t size = 0;
> -	int i;
>  
> -	for (i = 0; i < nr_segs; i++)
> -		size += iov[i].iov_len;
> +	size = iov_length(iov, nr_segs);

In both of these cases you can now remove the initialization of size to '0'.
