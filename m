From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] fix return values of l2tp_dfs_seq_open()
Date: Sun, 05 Jun 2011 12:05:25 +0100
Message-ID: <4DEB62F5.70005@katalix.com>
References: <20110604222531.GA11521@ZenIV.linux.org.uk> <20110605103735.GB11521@ZenIV.linux.org.uk> <20110605105403.GC11521@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:39501 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755605Ab1FELOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jun 2011 07:14:44 -0400
In-Reply-To: <20110605105403.GC11521@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2011 11:54, Al Viro wrote:
> More fallout from struct net lifetime rules review: PTR_ERR() is *already*
> negative and failing ->open() should return negatives on failure.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
> diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
> index b8dbae8..7613013 100644
> --- a/net/l2tp/l2tp_debugfs.c
> +++ b/net/l2tp/l2tp_debugfs.c
> @@ -258,7 +258,7 @@ static int l2tp_dfs_seq_open(struct inode *inode, struct file *file)
>  	 */
>  	pd->net = get_net_ns_by_pid(current->pid);
>  	if (IS_ERR(pd->net)) {
> -		rc = -PTR_ERR(pd->net);
> +		rc = PTR_ERR(pd->net);
>  		goto err_free_pd;
>  	}
>  

Whoops. Thanks Al.

Signed-off-by: James Chapman <jchapman@katalix.com>


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

