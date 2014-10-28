From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 5/7] fs: Convert show_fdinfo functions to void
Date: Tue, 28 Oct 2014 10:11:58 -0400
Message-ID: <20141028101158.3dde9880@gandalf.local.home>
References: <20140929124246.3e39dac8@gandalf.local.home>
	<cover.1412031505.git.joe@perches.com>
	<e37e6e7b76acbdcc3bb4ab2a57c8f8ca1ae11b9a.1412031505.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Petr Mladek <pmladek@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Jeff Layton <jlayton@poochiereds.net>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <e37e6e7b76acbdcc3bb4ab2a57c8f8ca1ae11b9a.1412031505.git.joe@perches.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Sep 2014 16:08:25 -0700
Joe Perches <joe@perches.com> wrote:

> seq_printf functions shouldn't really check the return value.
> Checking seq_is_full occasionally is used instead.
> 
> Update vfs documentation.
> 
> Signed-off-by: Joe Perches <joe@perches.com>


>  
> -#ifdef CONFIG_PROC_FS
> -static int eventfd_show_fdinfo(struct seq_file *m, struct file *f)
> +static void eventfd_show_fdinfo(struct seq_file *m, struct file *f)
>  {
> +#ifdef CONFIG_PROC_FS
>  	struct eventfd_ctx *ctx = f->private_data;
> -	int ret;
>  
>  	spin_lock_irq(&ctx->wqh.lock);
> -	ret = seq_printf(m, "eventfd-count: %16llx\n",
> -			 (unsigned long long)ctx->count);
> +	seq_printf(m, "eventfd-count: %16llx\n",
> +		   (unsigned long long)ctx->count);
>  	spin_unlock_irq(&ctx->wqh.lock);
> -
> -	return ret;
> -}
>  #endif
> +}
>  
>  static const struct file_operations eventfd_fops = {
> -#ifdef CONFIG_PROC_FS
>  	.show_fdinfo	= eventfd_show_fdinfo,
> -#endif

I wouldn't change logic on this. There's no reason to call this
function if it isn't doing anything.

I'll change this to just do the update and not change logic like this.

-- Steve

>  	.release	= eventfd_release,
>  	.poll		= eventfd_poll,
>  	.read		= eventfd_read,



> diff --git a/fs/proc/fd.c b/fs/proc/fd.c
> index e11d7c5..4c3c253 100644
> --- a/fs/proc/fd.c
> +++ b/fs/proc/fd.c
> @@ -53,7 +53,7 @@ static int seq_show(struct seq_file *m, void *v)
>  			   (long long)file->f_pos, f_flags,
>  			   real_mount(file->f_path.mnt)->mnt_id);
>  		if (file->f_op->show_fdinfo)
> -			ret = file->f_op->show_fdinfo(m, file);
> +			file->f_op->show_fdinfo(m, file);
>  		fput(file);
>  	}
>  
