From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Re: [PATCH 1/3][RFC] SELinux: correctly detect proc
	filesystems of	the form "proc/foo"
Date: Fri, 19 Dec 2008 07:29:33 -0500
Message-ID: <1229689773.31766.30.camel@moss-terrapins.epoch.ncsc.mil>
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
	<alpine.LRH.1.10.0812191204390.4137@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Chris Wright <chrisw@sous-sol.org>, linux-security-module@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Al Viro <viro@ftp.linux.org.uk>, Eric Paris <eparis@parisplace.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Smalley <sds@tycho.nsa.gov>, David Miller <davem@davemloft.net>
To: James Morris <jmorris@namei.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.LRH.1.10.0812191204390.4137@tundra.namei.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 2008-12-19 at 12:05 +1100, James Morris wrote:
> From: Stephen Smalley <sds@tycho.nsa.gov>
> 
> Map all of these proc/ filesystem types to "proc" for the policy lookup at
> filesystem mount time.
> 
> Signed-off-by: James Morris <jmorris@namei.org>
> ---
>  security/selinux/hooks.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index d337748..470763a 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -672,7 +672,7 @@ static int selinux_set_mnt_opts(struct super_block *sb,
>  		sbsec->proc = 1;
>  
>  	/* Determine the labeling behavior to use for this filesystem type. */
> -	rc = security_fs_use(sb->s_type->name, &sbsec->behavior, &sbsec->sid);
> +	rc = security_fs_use(sbsec->proc ? "proc" : sb->s_type->name, &sbsec->behavior, &sbsec->sid);
>  	if (rc) {
>  		printk(KERN_WARNING "%s: security_fs_use(%s) returned %d\n",
>  		       __func__, sb->s_type->name, rc);

I'm  not sure if you took the patches I sent out for condensing the
flags and adding a /proc/mount notification for label support but if you
did then your patches haven't been updated to use them. sbsec->proc
should no longer exist and instead it should be sbsec->flags &
SE_SBPROC.

Dave


------------------------------------------------------------------------------
