From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Fri, 1 Jan 2010 22:39:19 +0000
Message-ID: <20100101223919.00b60938@lxorguk.ukuu.org.uk>
References: <551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
	<m1fx6suswz.fsf@fess.ebiederm.org>
	<20091230201712.GA23999@us.ibm.com>
	<m1hbr8tb8q.fsf_-_@fess.ebiederm.org>
	<20091230212931.233003b9@lxorguk.ukuu.org.uk>
	<m1skasrvnq.fsf@fess.ebiederm.org>
	<20091230230042.5d2e78ac@lxorguk.ukuu.org.uk>
	<3e8340490912301844p4fddaf57ke58ceeba9582e0fa@mail.gmail.com>
	<20091231173334.5e3d7557@lxorguk.ukuu.org.uk>
	<20091231175257.GA7210@us.ibm.com>
	<551280e50912311020x2bdc5b1o699a601f67b91662@mail.gmail.com>
	<m1aawzm1tc.fsf@fess.ebiederm.org>
	<20100101144300.023f47a5@lxorguk.ukuu.org.uk>
	<m1zl4x4wq8.fsf@fess.ebiederm.org>
	<4B3E6A8B.7060705@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"Andrew G. Morgan" <morgan@kernel.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Bryan Donlan <bdonlan@gmail.com>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?UTF-8?B?QW3DqXJpY28=?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@syn
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752125Ab0AAWi2@vger.kernel.org>
In-Reply-To: <4B3E6A8B.7060705@schaufler-ca.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Sure. Not that it would be hard to do so. And have a careful look
> at the recent discussions on checkpoint/restart.

Indeed the LSM "no removal of restrictions" is simply a policy decision
that came about early on - no reason to assume it is a right policy
decision if it can be shown otherwise.

> Application developers want systems that work the way the man pages
> say they work. They do not want additional or conditional restrictions.

I disagree somewhat. They want them to work they way they did when they
tested it and the way they believe it works. Most of them never read the
manual or the standards documents. Take a look at the whining when stat()
size data stopped happening by chance to reflect bytes queued in a pipe.

> How many commercial applications start their installation instructions
> with "disable SELinux"? (Hint: lots)

And I am sure it time the sequence is going to go "Why did your business
web site get taken out for four weeks" / "We disabled SELinux as the app
said" / "Sue the app vendor"

If you tell someone to disable the safety systems on a crane you get
prosecuted.


> > I am sick and fed up with the conversations that go:
> > - I want to do X.
> > - X has been implemented.
> > - Sorry I can't use X as implemented because you have to be root to
> >   use X.
> >   
> Exasperated sigh. Privileged operations are privileged for a reason,
> not always a good reason mind you, but a reason nonetheless. If
> your application developers want to do things that require privilege
> you need to teach them how to write privileged programs safely. We've
> been working on exotic variations of system controls for decades
> and in the end your programmers have to write decent code because
> we haven't yet come up with a way to make all the things that people
> want their programs to do safe.

A useful question here would be to ask what it means to containerise
security. At the moment you can do this with virtual machines and while
its a nasty managability/security trade off the choice is there for the
most part and you can point at things like the amazon cloud as working
examples. We don't really have the notion of what setuidness means within
a container or how you can create a container which has its own internal
setuid, security model, LSM and 'superuser' but can't mess anything else
up, only for a virtual machine.

[I'll note Hurd tried to explore this area in part because Hurd was
 designed around a model that history proved bogus - a big computer being
 equitably shared with all the power possible but without messing up other
 users]

Alan
