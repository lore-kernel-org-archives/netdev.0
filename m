From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: How can OOM killer detect process consuming much kernel memory?
Date: Thu, 2 Sep 2010 06:33:46 +0900
Message-ID: <201009020633.DHJ01355.OQFMLtHSVOOJFF@I-love.SAKURA.ne.jp>
References: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp>
	<AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com>
	<201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kosaki.motohiro@jp.fujitsu.com, spender@grsecurity.net,
	eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I contacted Brad Spengler regarding below topic

  http://kerneltrap.org/mailarchive/linux-netdev/2010/8/21/6283491

and received some comments.

Brad Spengler wrote:
> Tetsuo Handa wrote:
> > Brad Spengler wrote:
> > > Nice find, seems like the problem isn't just the exhaustion of the space 
> > > itself, but that a single non-root user can completely exhaust it with 
> > > no limitation (given enough RAM).  There should be some per-user 
> > > resource limit for this (similar to RLIMIT_NPROC) or the space should be 
> > > made less rigid.
> > > 
> > I posted a patch in the third message of that thread, but no response so far.
> > I don't know whether we should allow 4294967296 names or not
> > because more RAM will be consumed by attacker if more names are allowed.
> 
> The max size for sun_path is considerably large; why couldn't we encode 
> the uid/namespace into it somehow and reduce the amount each user can 
> allocate?  (conceptually it'd be something like, <namespace 
> uuid><uid><hex to operate on as previously>)  The OOM killer needs to 
> make sure creators of large numbers of these get killed, but 
> implementing a per-user limit on this keeps it from turning into a DoS.

Is it possible to make OOM killer to kill processes consuming kernel memory
rather than userspace memory?

I'm happy if OOM killer can select victim process based on both kernel memory
usage and userspace memory usage. For example, opening a file requires kernel
memory allocation (e.g. /sys/kernel/security/tomoyo/self_domain allocates 8KB
of kernel memory). Therefore, I refuse allowing everybody to open that file
even if the content is public (because an attacker would open
/sys/kernel/security/tomoyo/self_domain as many as possible using
fork() and open() in order to exhaust kernel memory).
