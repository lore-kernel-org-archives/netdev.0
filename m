From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] sysfs_rename_link() and its usage
Date: Wed, 15 Jan 2014 18:32:43 -0500
Message-ID: <20140115233243.GB22237@mtj.dyndns.org>
References: <20140114171740.GB1867@redhat.com>
 <20140114182135.GA29296@kroah.com>
 <20140114191208.GA9942@redhat.com>
 <20140114193139.GA3636@kroah.com>
 <20140114210610.GC9942@redhat.com>
 <87iotmc9ic.fsf@xmission.com>
 <20140115141618.GD7950@htj.dyndns.org>
 <87fvoo25gj.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87fvoo25gj.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey, Eric.

On Wed, Jan 15, 2014 at 03:25:16PM -0800, Eric W. Biederman wrote:
> diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
> index 3ae3f1bf1a09..651444a9d1c5 100644
> --- a/fs/sysfs/symlink.c
> +++ b/fs/sysfs/symlink.c
> @@ -194,12 +194,10 @@ EXPORT_SYMBOL_GPL(sysfs_remove_link);
>   *	@targ:	object we're pointing to.
>   *	@old:	previous name of the symlink.
>   *	@new:	new name of the symlink.
> - *	@new_ns: new namespace of the symlink.
> - *
>   *	A helper function for the common rename symlink idiom.
>   */
> -int sysfs_rename_link_ns(struct kobject *kobj, struct kobject *targ,
> -			 const char *old, const char *new, const void *new_ns)
> +int sysfs_rename_link(struct kobject *kobj, struct kobject *targ,
> +		      const char *old, const char *new)
>  {
>  	struct sysfs_dirent *parent_sd, *sd = NULL;
>  	const void *old_ns = NULL;
> @@ -224,13 +222,13 @@ int sysfs_rename_link_ns(struct kobject *kobj, struct kobject *targ,
>  	if (sd->s_symlink.target_sd->s_dir.kobj != targ)
>  		goto out;
>  
> -	result = sysfs_rename(sd, parent_sd, new, new_ns);
> +	result = sysfs_rename(sd, parent_sd, new, kobject_namespace(targ));

Oh yeah, this is a lot better.  It's kinda weird that it requires
sysfs user to invoke sysfs_rename_link() without actually specifying
anything which has changed after namespace update tho.  The best thing
would be just tying the namespace of symlink to its target so that it
gets updated automatically along with the target without requiring
this separate step.  Ah well, we don't maintain backlinks (yet), so
this should do for now, I suppose.

Thanks.

-- 
tejun
