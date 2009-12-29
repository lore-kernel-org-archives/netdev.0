From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 16:16:28 -0600
Message-ID: <20091229221628.GA22578@us.ibm.com>
References: <20091229050114.GC14362@heat>
 <m1y6km11lj.fsf@fess.ebiederm.org>
 <20091229151146.GA32153@us.ibm.com>
 <3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
 <20091229163939.GA6984@us.ibm.com>
 <3e8340490912290901y60d7daf2w5778c25f44972955@mail.gmail.com>
 <m1fx6ty6ds.fsf@fess.ebiederm.org>
 <3e8340490912291108t7e000e75p8264fa585f831464@mail.gmail.com>
 <20091229212722.GA20178@us.ibm.com>
 <17290.1262123182@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bryan Donlan <bdonlan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>, Al Viro <viro@zeniv.linux.org.uk>
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <17290.1262123182@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Valdis.Kletnieks@vt.edu (Valdis.Kletnieks@vt.edu):
> On Tue, 29 Dec 2009 15:27:22 CST, "Serge E. Hallyn" said:
> > I think i disagree.  A uid is just a uid (or should be).  One day we may
> > have a way for a factotum-style daemon to grant the ability to an unpriv
> > task to setuid without CAP_SETUID.  I think slingling uids and gids
> > around that you already have access to should be fine.
> 
> Yes, but not doing the clear and obvious simple thing now for a "one day
> we may have" consideration seems a poor engineering tradeoff.
> 
> Yes, slinging uids and gids around *would* be nice.  But first we need a clear
> plan for making /usr/bin/newgrp a shell builtin - once that happens, *then*
> we can re-address this code. ;)

Absolutely agreed with the principle, but conflicted on the application.

I know earlier in the thread I said uid 0 even when unprivileged is
actually privileged merely by owning most of the system files.  But
in fact I think it helps to think more clearly when we separately
consider the cases of (a) changing uid, and (b) enhancing privilege.

That's why I was recommending implementation through securebits - what
we're basically saying is the task should never gain privilege.  And
effectively, since it won't have CAP_SETUID (unless it has and keeps it
in pI) it wont' be able to change uids.  But if we right off the bat
confuse changing uids with gaining privilege, I'm afraid we might end
up making some poor decisions.

Still, I won't say no to a check to refuse dropping the ability to
setuid to ensure that ruid=euid=suid and pP=pE=pI=empty.  It may
come back to bite us, but like I say I'm conflicted - willing to
go either way.

-serge
