From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Sun, 10 Jan 2010 22:58:48 +0100
Message-ID: <20100110215848.GA26609@elf.ucw.cz>
References: <alpine.LRH.2.00.1001110811350.25601@tundra.namei.org>
 <20100110215409.GA3705@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@namei.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Al Viro <viro@ZenIV.linux.or
To: Michael Stone <michael@laptop.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754074Ab0AJV67@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100110215409.GA3705@heat>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun 2010-01-10 16:54:09, Michael Stone wrote:
> On Fri, 1 Jan 2010, Pavel Machek wrote:
> 
> >> > Quoting Michael Stone (michael@laptop.org):
> >> > > Implement security_* hooks for socket_create, socket_bind, socket_connect,
> >> > > socket_sendmsg, and ptrace_access_check which return -EPERM when called from a
> >> > > process with networking restrictions. Exempt AF_UNIX sockets.
> >> > > > > > Signed-off-by: Michael Stone <michael@laptop.org>
> >> > > > Acked-by: Serge Hallyn <serue@us.ibm.com>
> >> > For the record: NAK, as it introduces security holes.
> >
> >Please elaborate.
> 
> Pavel's position is that disablenetwork is likely to permit some attacker
> somewhere to deny network access to some setuid app some day in a way that
> violates some security policy.
> 
> He has mentioned specific concern over scenarios like:

Make that scenario 1.

>   Alice configures PAM auth to 'fail open' by checking login credentials
>   against a restrictive LDAP server and, if the server is unavailable, against
>   a very permissive files database.

Scenario 2:

Mallory calls disablenetwork, calls sendmail as the first user after
boot; sendmail can't deliver anything (its network is disabled), but
starts forking and taking requests for other users, DoSing the mail
delivery.

Scenario 3:

Mallory calls disablenetwork, then keeps hammering on su, knowing that
su can no longer send data to audit subsystem and so he will not get caught.

> My position is that better isolation facilities like disablenetwork will
> prevent far more grievous security faults than they (theoretically) cause.

You can trivialy make disablenetwork disable setuid exec, too. That
will introduce better isolation facilities, but not introduce any new
security problems.

For some reason, you don't want to do the obviously right thing.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
