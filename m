From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 2/3][RFC] security: pass mount flags to
 security_sb_kern_mount()
Date: Fri, 19 Dec 2008 07:52:35 -0500
Message-ID: <1229691155.4948.2.camel@localhost.localdomain>
References: <49381644.8020502@intel.com>
	<20081204175236.GA19808@x200.localdomain>
	<1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>
	<20081204.102138.123959105.davem@davemloft.net>
	<1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
	<1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil>
	<m1bpvrslk0.fsf@frodo.ebiederm.org>
	<1228486339.20274.3.camel@localhost.localdomain>
	<alpine.LRH.1.10.0812112139340.25553@tundra.namei.org>
	<20081212052420.GA14948@x200.localdomain>
	<alpine.LRH.1.10.0812122022520.32426@tundra.namei.org>
	<1229117086.3134.22.camel@localhost.localdomain>
	<alpine.LRH.1.10.0812160021030.10723@tundra.namei.org>
	<alpine.LRH.1.10.0812191144370.4137@tundra.namei.org>
	<alpine.LRH.1.10.0812191205530.4137@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Chris Wright <chrisw@sous-sol.org>, linux-security-module@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Al Viro <viro@ftp.linux.org.uk>, Eric Paris <eparis@parisplace.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: James Morris <jmorris@namei.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.LRH.1.10.0812191205530.4137@tundra.namei.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 2008-12-19 at 12:06 +1100, James Morris wrote:
> Pass mount flags to security_sb_kern_mount(), so security modules
> can determine if a mount operation is being performed by the kernel.
> 
> Signed-off-by: James Morris <jmorris@namei.org>

Acked-by:  Stephen Smalley <sds@tycho.nsa.gov>

> ---
>  fs/super.c                 |    2 +-
>  include/linux/security.h   |    6 +++---
>  security/capability.c      |    2 +-
>  security/security.c        |    4 ++--
>  security/selinux/hooks.c   |    2 +-
>  security/smack/smack_lsm.c |    3 ++-
>  6 files changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/super.c b/fs/super.c
> index 400a760..ddba069 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -914,7 +914,7 @@ vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void
>  		goto out_free_secdata;
>  	BUG_ON(!mnt->mnt_sb);
>  
> - 	error = security_sb_kern_mount(mnt->mnt_sb, secdata);
> + 	error = security_sb_kern_mount(mnt->mnt_sb, flags, secdata);
>   	if (error)
>   		goto out_sb;
>  
> diff --git a/include/linux/security.h b/include/linux/security.h
> index c13f1ce..dff563b 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -1327,7 +1327,7 @@ struct security_operations {
>  	int (*sb_alloc_security) (struct super_block *sb);
>  	void (*sb_free_security) (struct super_block *sb);
>  	int (*sb_copy_data) (char *orig, char *copy);
> -	int (*sb_kern_mount) (struct super_block *sb, void *data);
> +	int (*sb_kern_mount) (struct super_block *sb, int flags, void *data);
>  	int (*sb_show_options) (struct seq_file *m, struct super_block *sb);
>  	int (*sb_statfs) (struct dentry *dentry);
>  	int (*sb_mount) (char *dev_name, struct path *path,
> @@ -1596,7 +1596,7 @@ int security_bprm_secureexec(struct linux_binprm *bprm);
>  int security_sb_alloc(struct super_block *sb);
>  void security_sb_free(struct super_block *sb);
>  int security_sb_copy_data(char *orig, char *copy);
> -int security_sb_kern_mount(struct super_block *sb, void *data);
> +int security_sb_kern_mount(struct super_block *sb, int flags, void *data);
>  int security_sb_show_options(struct seq_file *m, struct super_block *sb);
>  int security_sb_statfs(struct dentry *dentry);
>  int security_sb_mount(char *dev_name, struct path *path,
> @@ -1877,7 +1877,7 @@ static inline int security_sb_copy_data(char *orig, char *copy)
>  	return 0;
>  }
>  
> -static inline int security_sb_kern_mount(struct super_block *sb, void *data)
> +static inline int security_sb_kern_mount(struct super_block *sb, int flags, void *data)
>  {
>  	return 0;
>  }
> diff --git a/security/capability.c b/security/capability.c
> index 2458748..0f6612d 100644
> --- a/security/capability.c
> +++ b/security/capability.c
> @@ -64,7 +64,7 @@ static int cap_sb_copy_data(char *orig, char *copy)
>  	return 0;
>  }
>  
> -static int cap_sb_kern_mount(struct super_block *sb, void *data)
> +static int cap_sb_kern_mount(struct super_block *sb, int flags, void *data)
>  {
>  	return 0;
>  }
> diff --git a/security/security.c b/security/security.c
> index c0acfa7..5a37d79 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -266,9 +266,9 @@ int security_sb_copy_data(char *orig, char *copy)
>  }
>  EXPORT_SYMBOL(security_sb_copy_data);
>  
> -int security_sb_kern_mount(struct super_block *sb, void *data)
> +int security_sb_kern_mount(struct super_block *sb, int flags, void *data)
>  {
> -	return security_ops->sb_kern_mount(sb, data);
> +	return security_ops->sb_kern_mount(sb, flags, data);
>  }
>  
>  int security_sb_show_options(struct seq_file *m, struct super_block *sb)
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 470763a..3897758 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -2452,7 +2452,7 @@ out:
>  	return rc;
>  }
>  
> -static int selinux_sb_kern_mount(struct super_block *sb, void *data)
> +static int selinux_sb_kern_mount(struct super_block *sb, int flags, void *data)
>  {
>  	struct avc_audit_data ad;
>  	int rc;
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index 6e2dc0b..f23e927 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -248,11 +248,12 @@ static int smack_sb_copy_data(char *orig, char *smackopts)
>  /**
>   * smack_sb_kern_mount - Smack specific mount processing
>   * @sb: the file system superblock
> + * @flags: the mount flags
>   * @data: the smack mount options
>   *
>   * Returns 0 on success, an error code on failure
>   */
> -static int smack_sb_kern_mount(struct super_block *sb, void *data)
> +static int smack_sb_kern_mount(struct super_block *sb, int flags, void *data)
>  {
>  	struct dentry *root = sb->s_root;
>  	struct inode *inode = root->d_inode;
-- 
Stephen Smalley
National Security Agency


------------------------------------------------------------------------------
