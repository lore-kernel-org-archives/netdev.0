From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [patch -v2 01/23] sunrpc: use simple_read_from_buffer
Date: Mon, 2 Jun 2008 09:35:52 +0400
Message-ID: <20080602053552.GA6592@martell.zuzino.mipt.ru>
References: <20080601231329.223608711@gmail.com> <20080601231451.529328123@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:42715 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbYFBFkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 01:40:07 -0400
Received: by ug-out-1314.google.com with SMTP id h2so228791ugf.16
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2008 22:40:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080601231451.529328123@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 02, 2008 at 08:13:30AM +0900, akinobu.mita@gmail.com wrote:
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> ---
>  net/sunrpc/cache.c |   15 +++------------
>  1 file changed, 3 insertions(+), 12 deletions(-)
> 
> Index: 2.6-git/net/sunrpc/cache.c
> ===================================================================
> --- 2.6-git.orig/net/sunrpc/cache.c
> +++ 2.6-git/net/sunrpc/cache.c
> @@ -1271,20 +1271,11 @@ static ssize_t read_flush(struct file *f
>  {
>  	struct cache_detail *cd = PDE(file->f_path.dentry->d_inode)->data;
>  	char tbuf[20];
> -	unsigned long p = *ppos;
>  	size_t len;
>  
> -	sprintf(tbuf, "%lu\n", cd->flush_time);
> -	len = strlen(tbuf);
> -	if (p >= len)
> -		return 0;
> -	len -= p;
> -	if (len > count)
> -		len = count;
> -	if (copy_to_user(buf, (void*)(tbuf+p), len))
> -		return -EFAULT;
> -	*ppos += len;
> -	return len;
> +	len = sprintf(tbuf, "%lu\n", cd->flush_time);
> +
> +	return simple_read_from_buffer(buf, count, ppos, tbuf, len);
>  }

Please, switch to seq_file:

	seq_printf(m, "%lu\n", cd->flush_time);
	return 0;

and that's everything module have to worry about.

