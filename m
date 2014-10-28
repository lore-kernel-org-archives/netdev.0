From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 5/7] fs: Convert show_fdinfo functions to void
Date: Tue, 28 Oct 2014 07:31:32 -0700
Message-ID: <1414506692.6643.2.camel@perches.com>
References: <20140929124246.3e39dac8@gandalf.local.home>
	 <cover.1412031505.git.joe@perches.com>
	 <e37e6e7b76acbdcc3bb4ab2a57c8f8ca1ae11b9a.1412031505.git.joe@perches.com>
	 <20141028101158.3dde9880@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
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
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141028101158.3dde9880@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-10-28 at 10:11 -0400, Steven Rostedt wrote:
> On Mon, 29 Sep 2014 16:08:25 -0700
> Joe Perches <joe@perches.com> wrote:
> 
> > seq_printf functions shouldn't really check the return value.
> > Checking seq_is_full occasionally is used instead.
> > 
> > Update vfs documentation.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> 
> >  
> > -#ifdef CONFIG_PROC_FS
> > -static int eventfd_show_fdinfo(struct seq_file *m, struct file *f)
> > +static void eventfd_show_fdinfo(struct seq_file *m, struct file *f)
> >  {
> > +#ifdef CONFIG_PROC_FS
> >  	struct eventfd_ctx *ctx = f->private_data;
> > -	int ret;
> >  
> >  	spin_lock_irq(&ctx->wqh.lock);
> > -	ret = seq_printf(m, "eventfd-count: %16llx\n",
> > -			 (unsigned long long)ctx->count);
> > +	seq_printf(m, "eventfd-count: %16llx\n",
> > +		   (unsigned long long)ctx->count);
> >  	spin_unlock_irq(&ctx->wqh.lock);
> > -
> > -	return ret;
> > -}
> >  #endif
> > +}
> >  
> >  static const struct file_operations eventfd_fops = {
> > -#ifdef CONFIG_PROC_FS
> >  	.show_fdinfo	= eventfd_show_fdinfo,
> > -#endif
> 
> I wouldn't change logic on this. There's no reason to call this
> function if it isn't doing anything.
> 
> I'll change this to just do the update and not change logic like this.

Fewer #ifdefs
