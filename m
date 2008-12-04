From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: networking probs in next-20081203
Date: Thu, 4 Dec 2008 20:52:36 +0300
Message-ID: <20081204175236.GA19808@x200.localdomain>
References: <20081203171834.86903d39.akpm@linux-foundation.org>
	<20081204151436.GA18783@x200.localdomain>
	<49381644.8020502@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ebiederm@xmission.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <49381644.8020502@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Dec 04, 2008 at 09:41:24AM -0800, Kok, Auke wrote:
> Alexey Dobriyan wrote:
> > On Wed, Dec 03, 2008 at 05:18:34PM -0800, Andrew Morton wrote:
> >> x86_64, CONFIG_E1000E=y.
> >>
> >> Current Linus mainline is OK, but with linux-next I'm seeing the following:
> >>
> >> - During boot I see a "cannot open /proc/net/dev" fly past.  But when
> >>   it gets to the login prompt, I can read /proc/net/dev.
> > 
> > I _suspect_ it might me something with /proc/net changes (again) and initcall
> > ordering.
> > 
> > Andrew, as rejectless quick test, you can do
> > 
> > 	git checkout -f 26b0d981e7dd1d5b4852ed5719bd1388c7994163	# sic
> > 
> > which is the last tree merged before proc tree in that next tree.
> > 
> >> - Networking won't come up.  `ifup eth0' says "determining ip address
> >>   ...  failed", and the failure is immediate.
> >>
> >> - eth0 appears in the ifconfig oputput as normal - it just won't come up.
> >>
> >> - nothing interesting in dmesg
> >>
> >>
> >> Here's the dmesg: http://userweb.kernel.org/~akpm/dmesg-dead-net.txt
> >> (that dmesg was generated with E1000=y, E1000E=y, but that doesn't seem
> >> to matter)
> >>
> >> The .config: http://userweb.kernel.org/~akpm/config-dead-net.txt
> 
> perhaps this line has something to do with it?
> 
> [   50.539326] type=1400 audit(1228348149.537:4): avc:  denied  { mount } for
> pid=11636 comm="ifconfig" name="/" dev=proc/net ino=4026531842
> scontext=system_u:system_r:ifconfig_t:s0 tcontext=system_u:object_r:unlabeled_t:s0
> tclass=filesystem

Of course!

> maybe try disabling selinux?

This will work. :^)

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
