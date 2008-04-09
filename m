From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Wed, 09 Apr 2008 09:26:26 -0400
Message-ID: <1207747586.21223.413.camel@moss-spartans.epoch.ncsc.mil>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp>
	 <20080404122408.986477936@I-love.SAKURA.ne.jp>
	 <200804071140.59247.paul.moore@hp.com> <47FC8052.9070409@nttdata.co.jp>
	 <20080409131151.GK11962@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Toshiharu Harada <haradats@nttdata.co.jp>,
	Paul Moore <paul.moore@hp.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080409131151.GK11962@parisc-linux.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2008-04-09 at 07:11 -0600, Matthew Wilcox wrote:
> On Wed, Apr 09, 2008 at 05:37:38PM +0900, Toshiharu Harada wrote:
> > LWN article 239962 says, "At the 2006 summit, Linus took a clear
> > position that the use of pathnames for security policies seemed
> > reasonable to him". Current LSM implementation is sufficient for SELinux
> > and other label based MACs but not for pathname-based MACs.
> > This has been argued in the AppAmor thread for quite a long time.
> > Though proposals had been posted by AppArmor and TOMOYO Linux project,
> > none has been merged until now.
> 
> How about an approach which doesn't require the vfsmount to be passed
> down?
> 
> When the rule is put in place, say "No modifications to /etc/passwd",
> look up the inode and major:minor of /etc/passwd.  If there's a rename,
> look up the new inode number.  If it's mounted elsewhere, it doesn't
> matter, they still can't modify it because it has the same
> major:minor:inode.
> 
> Is this workable?

Sounds similar to audit watches, e.g. see audit_add_watch() and
audit_handle_ievent().  That leverages inotify internally.

-- 
Stephen Smalley
National Security Agency

