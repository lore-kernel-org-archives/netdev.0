From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: networking probs in next-20081203
Date: Thu, 04 Dec 2008 14:32:21 -0500
Message-ID: <1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
References: <49381644.8020502@intel.com>
	<20081204175236.GA19808@x200.localdomain>
	<1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>
	<20081204.102138.123959105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jmorris@namei.org, ebiederm@xmission.com,
	eparis@parisplace.org, akpm@linux-foundation.org, adobriyan@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20081204.102138.123959105.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 2008-12-04 at 10:21 -0800, David Miller wrote:
> From: Stephen Smalley <sds@tycho.nsa.gov>
> Date: Thu, 04 Dec 2008 13:11:20 -0500
> 
> > On Thu, 2008-12-04 at 20:52 +0300, Alexey Dobriyan wrote:
> > > On Thu, Dec 04, 2008 at 09:41:24AM -0800, Kok, Auke wrote:
> > > > maybe try disabling selinux?
> > > 
> > > This will work. :^)
> > 
> > SELinux didn't change here.  /proc/net did.
> 
> We've been through this before...

Yep, and we altered SELinux so that they could freely change proc
directories into symlinks to support the earlier proc/net change.  But
now proc/net has turned into its own separate filesystem, with its own
filesystem type, which is unknown to SELinux.  Thus causing it to be
left unlabeled and inaccessible to confined domains.

> And it is a usability issue that people can't change how procfs
> directories work without requiring the user to update their selinux
> policies first.

Introducing a new filesystem type (proc/net) without teaching SELinux
how to handle it is always going to produce denials on accessing that
filesystem.  If they left the filesystem type string as "proc" it
wouldn't be a problem.  Or they can adjust the SELinux code to
automagically handle it.  Regardless, we didn't break anything.

-- 
Stephen Smalley
National Security Agency


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
