From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Thu, 10 Apr 2008 08:51:22 -0400
Message-ID: <1207831882.21223.694.camel@moss-spartans.epoch.ncsc.mil>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp>
	 <20080404122408.986477936@I-love.SAKURA.ne.jp>
	 <200804071140.59247.paul.moore@hp.com>  <47FC8052.9070409@nttdata.co.jp>
	 <1207745357.21223.391.camel@moss-spartans.epoch.ncsc.mil>
	 <47FDAC57.9000701@nttdata.co.jp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Toshiharu Harada <haradats@nttdata.co.jp>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <47FDAC57.9000701@nttdata.co.jp>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2008-04-10 at 14:57 +0900, Toshiharu Harada wrote:
> On 4/9/2008 9:49 PM, Stephen Smalley wrote:
> >> We cordially request LSM changes to pass vfsmount parameters.
> > 
> > Don't cordially request it - submit patches to make it happen.  Or work
> > with others who have been submitting such patches.
> 
> You are (always) right. :)

Definitely not always.

> > There are two options:
> > 1) Submit patches to pass down the vfsmounts to the vfs helpers so that
> > they can be passed to the existing security_inode hooks. -or-
> > 2) Submit patches to add new security hooks to the callers where the
> > vfsmount is already available (some have suggested moving the existing
> > security_inode hooks to the callers, but that would cause problems for
> > SELinux as I've posted elsewhere, so adding new hooks is preferable, and
> > then SELinux can just default to the dummy functions for those new
> > hooks).
> 
> Thank you for your suggestions. I drew a diagram. Is this correct?

I think the text above is self-explanatory; I'm not sure what the
diagram adds.  Also, Matthew Wilcox pointed out a third option that you
ought to consider, and you can look to the example of audit filesystem
watches there, which leverages inotify internally.

If that isn't feasible for some reason, then option (2) should be fairly
straightforward - you just define and insert some new security hooks in
the callers where the vfsmount is already available.

-- 
Stephen Smalley
National Security Agency

