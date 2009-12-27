From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Sun, 27 Dec 2009 17:36:48 +0900
Message-ID: <200912271736.GDB17180.OFJHOOQStMFLVF@I-love.SAKURA.ne.jp>
References: <20091227010441.GA12077@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	andi@firstfloor.org, david@lang.hm, socketcan@hartkopp.net,
	alan@lxorguk.ukuu.org.uk, herbert@gondor.apana.org.au,
	Valdis.Kletnieks@vt.edu, bdonlan@gmail.com, zbr@ioremap.net,
	cscott@cscott.net, jmorris@namei.org, ebiederm@xmission.com,
	bernie@codewiz.org, mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, penguin-kernel@i-love.sakura.ne.jp,
	sam@synack.fr, casey@schaufler-ca.com, serue@us.ibm.com,
	pavel@ucw.cz
To: michael@laptop.org, linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091227010441.GA12077@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Stone wrote:
> Further suggestions?

I expect that the future figure of this "disablenetwork" functionality becomes
"disablesyscall" functionality.

What about defining two types of masks, one is applied throughout the rest of
the task_struct's lifetime (inheritable mask), the other is cleared when
execve() succeeds (local mask)?

When an application is sure that "I know I don't need to call execve()" or
"I know execve()d programs need not to call ...()" or "I want execve()d
programs not to call ...()", the application sets inheritable mask.
When an application is not sure about what syscalls the execve()d programs
will call but is sure that "I know I don't need to call ...()", the application
sets local mask.

When I started TOMOYO project in 2003, I implemented above two types of masks.
I found that the characteristics of task_struct (i.e. duplicated upon fork(),
modified upon execve(), deleted upon exit()) suits well for implementing
discretionary dropping privileges.

Application writers know better what syscalls the application will call than
application users. I think that combination of policy based access control
(which restricts operations from outside applications, like SELinux, Smack,
TOMOYO) and voluntary access control (which restricts operations from inside
applications, like disablenetwork) is a good choice. Above two types of masks
can give application writers chance to drop unneeded privileges (in other
words, chance to disable unneeded syscalls).
