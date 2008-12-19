From: James Morris <jmorris@namei.org>
Subject: [PATCH 0/3][RFC] Fix security and SELinux handling of
 proc/* filesystems
Date: Fri, 19 Dec 2008 12:04:07 +1100 (EST)
Message-ID: <alpine.LRH.1.10.0812191144370.4137@tundra.namei.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Chris Wright <chrisw@sous-sol.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Al Viro <viro@ftp.linux.org.uk>, Eric Paris <eparis@parisplace.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Smalley <sds@tycho.nsa.gov>, David Miller <davem@davemloft.net>
To: linux-security-module@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.LRH.1.10.0812160021030.10723@tundra.namei.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

These patches address the issues encountered in the recent discussion:

"[E1000-devel] networking probs in next-20081203"
<https://kerneltrap.org/mailarchive/linux-netdev/2008/12/4/4315684/thread>

where making proc/net into its own filesystem to be mounted on a 
per-namespace basis caused SELinux labeling to stop working.

The solution is to first ensure that the filesystem is correctly labeled, 
and then to also allow filesystems being mounted by the kernel to bypass 
SELinux permission checks (these operations should always be allowed).

The mount flags are now passed to security_sb_kern_mount(), so that the 
security module can check whether MS_KERNMOUNT is set.

Please review and ack if ok.

These patches are against 
git://git.kernel.org/pub/scm/linux/kernel/git/adobriyan/proc.git#proc-wip


-- 
James Morris
<jmorris@namei.org>

------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
