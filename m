From: James Morris <jmorris@namei.org>
Subject: Re: networking probs in next-20081203
Date: Thu, 11 Dec 2008 21:41:20 +1100 (EST)
Message-ID: <alpine.LRH.1.10.0812112139340.25553@tundra.namei.org>
References: <49381644.8020502@intel.com>
	<20081204175236.GA19808@x200.localdomain>
	<1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>
	<20081204.102138.123959105.davem@davemloft.net>
	<1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
	<1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil>
	<m1bpvrslk0.fsf@frodo.ebiederm.org>
	<1228486339.20274.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	eparis@parisplace.org, akpm@linux-foundation.org, adobriyan@gmail.com
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1228486339.20274.3.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 5 Dec 2008, Stephen Smalley wrote:

> I suspect we need the following un-tested diff to map all of these proc/
> filesystem types to "proc" for the policy lookup at filesystem mount
> time.

I finally got a bootable linux-next, but it seems that the proc/net patch 
is no longer in there.

Any idea if it's coming back?  The patch below looks ok, but it needs 
testing (and I'd suggest perhaps including it any future version of the 
proc/net patch).


> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 9155fa9..3c3ceb7 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -703,7 +703,7 @@ static int selinux_set_mnt_opts(struct super_block *sb,
>  		sbsec->proc = 1;
>  
>  	/* Determine the labeling behavior to use for this filesystem type. */
> -	rc = security_fs_use(sb->s_type->name, &sbsec->behavior, &sbsec->sid);
> +	rc = security_fs_use(sbsec->proc ? "proc" : sb->s_type->name, &sbsec->behavior, &sbsec->sid);
>  	if (rc) {
>  		printk(KERN_WARNING "%s: security_fs_use(%s) returned %d\n",
>  		       __func__, sb->s_type->name, rc);
> 
> -- 
> Stephen Smalley
> National Security Agency
> 

-- 
James Morris
<jmorris@namei.org>

------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
