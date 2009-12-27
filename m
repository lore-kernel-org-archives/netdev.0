From: Pavel Machek <pavel@ucw.cz>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Sun, 27 Dec 2009 20:08:02 +0100
Message-ID: <20091227190802.GH11737@elf.ucw.cz>
References: <20091227010441.GA12077@heat>
 <200912271736.GDB17180.OFJHOOQStMFLVF@I-love.SAKURA.ne.jp>
 <20091227083857.GC11737@elf.ucw.cz>
 <200912272049.FIB35755.OMFFOOJQtVLFSH@I-love.SAKURA.ne.jp>
 <20091227150300.GB19414@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	viro@ZenIV.linux.org.uk, michael@laptop.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, andi@firstfloor.org,
	david@lang.hm, socketcan@hartkopp.net, alan@lxorguk.ukuu.org.uk,
	herbert@gondor.apana.org.au, Valdis.Kletnieks@vt.edu,
	bdonlan@gmail.com, zbr@ioremap.net, cscott@cscott.net,
	jmorris@namei.org, ebiederm@xmission.com, bernie@codewiz.org,
	mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, sam@synack.fr, casey@schaufler-ca.com,
	serue@us.ibm.com
To: "Serge E. Hallyn" <serge@hallyn.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091227150300.GB19414@hallyn.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > I think seccomp() is too much restricted to apply for general applications.
> > Most applications will need some other syscalls in addition to exit(), read()
> > and write(). Most applications cannot use seccomp().
> > 
> > What I want to do is similar to seccomp(), but allows userland process to
> > forbid some syscalls like execve(), mount(), chroot(), link(), unlink(),
> > socket(), bind(), listen() etc. selectively.
> 
> The nice thing about the disablenetwork module is that (AFAICS so far)
> it actually is safe for an unprivileged user to do.  I can't think of
> any setuid-root software which, if started with restricted-network by
> an unprivileged user, would become unsafe rather than simply
> failing.

"I can't see" is not strong enough test, I'd say.

For example, I can easily imagine something like pam falling back to
local authentication when network is unavailable. If you disable
network for su...

It would be also extremely easy to DoS something like sendmail -- if
it forks into background and then serves other users' requests.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
