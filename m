From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Mon, 11 Jan 2010 13:01:31 +0100
Message-ID: <20100111120131.GB1697@atrey.karlin.mff.cuni.cz>
References: <20100110215848.GA26609@elf.ucw.cz> <20100110224010.GA3825@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Am?rico Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100110224010.GA3825@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> >You can trivialy make disablenetwork disable setuid exec, too. That
> >will introduce better isolation facilities, but not introduce any new
> >security problems.
> >
> >For some reason, you don't want to do the obviously right thing.
> 
> I don't want to do it because it's not "obviously right" to me: I *have* 
> setuid
> programs that I want to be able to raise privileges when network-disabled.
> I *don't have* any setuid programs that will be harmed by disablenetwork.

Well, I do not have any desire to use disablenetwork, but I do not
want my users to use it and DoS sendmail.

> Examples of software that I want to be able to gain privileges normally 
> include:

You'll have to make sure those are not accessed from the
disablenetworked parts, I'd say. Pre-existing unix domain socket
should be the way to go.

>   rainbow, which requires privilege in order to add new accounts to the 
>   system
>   and in order to call setuid() but which does not require networking
>   privileges.
> 
>   qmail-queue, which uses setuid to deliver mail that it reads from fd 0 to
>   local users
> 
>   and other old favorites like mount, fusermount, X, and, presumably, any 
>   audio
>   software that wants to go realtime.

mount certainly wants network access for NFS.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
