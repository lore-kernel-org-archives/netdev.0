From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: make /proc/net/protocols namespace aware
Date: Mon, 17 Nov 2008 14:15:16 +0300
Message-ID: <20081117111516.GA10542@x200.localdomain>
References: <49214C74.3020303@cosmosbay.com> <49214D37.2090502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"Denis V. Lunev" <den@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:60070 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbYKQLLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 06:11:41 -0500
Received: by ug-out-1314.google.com with SMTP id 39so372470ugf.37
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 03:11:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49214D37.2090502@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 17, 2008 at 11:53:43AM +0100, Eric Dumazet wrote:
> --- a/net/core/sock.c
> +++ b/net/core/sock.c

> @@ -2230,7 +2230,8 @@ static const struct seq_operations proto_seq_ops = {
>  
>  static int proto_seq_open(struct inode *inode, struct file *file)
>  {
> -	return seq_open(file, &proto_seq_ops);
> +	return seq_open_net(inode, file, &proto_seq_ops,
> +			    sizeof(struct seq_net_private));

You have to hook seq_release_net if you do this.

>  }
>  
>  static const struct file_operations proto_seq_fops = {
> @@ -2241,10 +2242,28 @@ static const struct file_operations proto_seq_fops = {
>  	.release	= seq_release,
	+.release	= seq_release_net,
