From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUGS] [CHECKER] 99 synchronization bugs and a lock summary database
Date: Sat, 3 Jul 2004 16:13:20 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040703061320.GA24115@gondor.apana.org.au>
References: <20040702004956.448c95d9.akpm@osdl.org> <E1BgLql-00055X-00@gondolin.me.apana.org.au> <20040702123022.563ee931.akpm@osdl.org> <20040702125008.25e65252@dell_ss3.pdx.osdl.net> <87wu1l3aug.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, Andrew Morton <akpm@osdl.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Content-Disposition: inline
In-Reply-To: <87wu1l3aug.fsf@devron.myhome.or.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jul 03, 2004 at 02:42:47PM +0900, OGAWA Hirofumi wrote:
>  
> @@ -1854,7 +1850,13 @@ out:
>  out_kfree:
>  	kfree(s);
>  	goto out;
> +}
>  
> +static int ipmr_mfc_release(struct inode *inode, struct file *file)
> +{
> +	struct seq_file *seq = file->private_data;
> +	kfree(seq->private);
> +	return seq_release(inode, file);
>  }
>  
>  static struct file_operations ipmr_mfc_fops = {
> @@ -1862,7 +1864,7 @@ static struct file_operations ipmr_mfc_f
>  	.open    = ipmr_mfc_open,
>  	.read    = seq_read,
>  	.llseek  = seq_lseek,
> -	.release = seq_release,
> +	.release = ipmr_mfc_release,
>  };
>  #endif	

This is a good catch.  But you probably need to fix the vif stuff as
well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
