From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Wed, 9 Apr 2008 07:11:52 -0600
Message-ID: <20080409131151.GK11962@parisc-linux.org>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp> <20080404122408.986477936@I-love.SAKURA.ne.jp> <200804071140.59247.paul.moore@hp.com> <47FC8052.9070409@nttdata.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Toshiharu Harada <haradats@nttdata.co.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47FC8052.9070409@nttdata.co.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 09, 2008 at 05:37:38PM +0900, Toshiharu Harada wrote:
> LWN article 239962 says, "At the 2006 summit, Linus took a clear
> position that the use of pathnames for security policies seemed
> reasonable to him". Current LSM implementation is sufficient for SELinux
> and other label based MACs but not for pathname-based MACs.
> This has been argued in the AppAmor thread for quite a long time.
> Though proposals had been posted by AppArmor and TOMOYO Linux project,
> none has been merged until now.

How about an approach which doesn't require the vfsmount to be passed
down?

When the rule is put in place, say "No modifications to /etc/passwd",
look up the inode and major:minor of /etc/passwd.  If there's a rename,
look up the new inode number.  If it's mounted elsewhere, it doesn't
matter, they still can't modify it because it has the same
major:minor:inode.

Is this workable?

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
