From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: Tree for Apr 12
Date: Tue, 5 Jun 2012 12:50:19 -0700
Message-ID: <20120605125019.dca1fd02.akpm@linux-foundation.org>
References: <20120412145931.9ec6f2b51655071795d60d1d@canb.auug.org.au>
	<20120412142415.564710b8.akpm@linux-foundation.org>
	<20120604150455.7a80b311.akpm@linux-foundation.org>
	<1338849977.2860.9.camel@localhost>
	<1338864128.17933.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>,
	Stephen Smalley <sds@tycho.nsa.gov>
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1338864128.17933.2.camel@localhost>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 04 Jun 2012 22:42:08 -0400
Eric Paris <eparis@redhat.com> wrote:

> > I really do not want to revert this and feel that the only right fix is
> > going to be to update your selinux policy to allow this new check.  I'd
> > rather not allow (whatever program) to truncate() files willy-nilly (in
> > violation of the intentions of selinux policy)
> > 
> > I'm sorry I never saw it sooner.  We've had it in RHEL for even longer
> > than the 3 months it's been in -next.  I think the 'right' fix is going
> > to have to be an update to SELinux policy (for your long dead system, if
> > you give me the denial I can build you a new policy) rather than leaving
> > the potential security hole in mainline...
> 
> Andrew sent me his audit log and it didn't show anything.  But it got me
> thinking.  Now I think this actually is a code bug.  Andrew, can you
> test this?
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 2e7bd67..20a4315 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -2758,7 +2758,7 @@ static int selinux_inode_setattr(struct dentry *dentry, struct iattr *iattr)
>  			ATTR_ATIME_SET | ATTR_MTIME_SET | ATTR_TIMES_SET))
>  		return dentry_has_perm(cred, dentry, FILE__SETATTR);
>  
> -	if (ia_valid & ATTR_SIZE)
> +	if ((ia_valid & ATTR_SIZE) && selinux_policycap_openperm)
>  		av |= FILE__OPEN;
>  
>  	return dentry_has_perm(cred, dentry, av);

That fixed it.
