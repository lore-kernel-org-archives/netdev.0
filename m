From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: networking probs in next-20081203
Date: Fri, 12 Dec 2008 08:24:20 +0300
Message-ID: <20081212052420.GA14948@x200.localdomain>
References: <49381644.8020502@intel.com>
	<20081204175236.GA19808@x200.localdomain>
	<1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>
	<20081204.102138.123959105.davem@davemloft.net>
	<1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
	<1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil>
	<m1bpvrslk0.fsf@frodo.ebiederm.org>
	<1228486339.20274.3.camel@localhost.localdomain>
	<alpine.LRH.1.10.0812112139340.25553@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>,
	eparis@parisplace.org, akpm@linux-foundation.org,
	Stephen Smalley <sds@tycho.nsa.gov>, David Miller <davem@davemloft.net>
To: James Morris <jmorris@namei.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <alpine.LRH.1.10.0812112139340.25553@tundra.namei.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Dec 11, 2008 at 09:41:20PM +1100, James Morris wrote:
> On Fri, 5 Dec 2008, Stephen Smalley wrote:
> 
> > I suspect we need the following un-tested diff to map all of these proc/
> > filesystem types to "proc" for the policy lookup at filesystem mount
> > time.
> 
> I finally got a bootable linux-next, but it seems that the proc/net patch 
> is no longer in there.
> 
> Any idea if it's coming back?  The patch below looks ok, but it needs 
> testing

Yes, please, someone test it.

> (and I'd suggest perhaps including it any future version of the proc/net patch).

I placed it into proc-wip branch to not screw testers with SELinux meanwhile

	git-remote add proc git://git.kernel.org/pub/scm/linux/kernel/git/adobriyan/proc.git

> > --- a/security/selinux/hooks.c
> > +++ b/security/selinux/hooks.c
> > @@ -703,7 +703,7 @@ static int selinux_set_mnt_opts(struct super_block *sb,
> >  		sbsec->proc = 1;
> >  
> >  	/* Determine the labeling behavior to use for this filesystem type. */
> > -	rc = security_fs_use(sb->s_type->name, &sbsec->behavior, &sbsec->sid);
> > +	rc = security_fs_use(sbsec->proc ? "proc" : sb->s_type->name, &sbsec->behavior, &sbsec->sid);

------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
