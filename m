From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 3/3][RFC] SELinux: don't check permissions
 for kernel mounts
Date: Fri, 19 Dec 2008 07:52:51 -0500
Message-ID: <1229691171.4948.3.camel@localhost.localdomain>
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
	<alpine.LRH.1.10.0812191206380.4137@tundra.namei.org>
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
In-Reply-To: <alpine.LRH.1.10.0812191206380.4137@tundra.namei.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 2008-12-19 at 12:07 +1100, James Morris wrote:
> Don't bother checking permissions when the kernel performs an internal 
> mount, as this should always be allowed.
> 
> Signed-off-by: James Morris <jmorris@namei.org>

Acked-by:  Stephen Smalley <sds@tycho.nsa.gov>

> ---
>  security/selinux/hooks.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 3897758..4a44903 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -2461,6 +2461,10 @@ static int selinux_sb_kern_mount(struct super_block *sb, int flags, void *data)
>  	if (rc)
>  		return rc;
>  
> +	/* Allow all mounts performed by the kernel */
> +	if (flags & MS_KERNMOUNT)
> +		return 0;
> +
>  	AVC_AUDIT_DATA_INIT(&ad, FS);
>  	ad.u.fs.path.dentry = sb->s_root;
>  	return superblock_has_perm(current, sb, FILESYSTEM__MOUNT, &ad);
-- 
Stephen Smalley
National Security Agency


------------------------------------------------------------------------------
