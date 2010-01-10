From: Michael Stone <michael@laptop.org>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Sun, 10 Jan 2010 16:54:09 -0500
Message-ID: <20100110215409.GA3705@heat>
References: <alpine.LRH.2.00.1001110811350.25601@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
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
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Pavel Machek <pavel@ucw.cz>,
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.00.1001110811350.25601@tundra.namei.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 1 Jan 2010, Pavel Machek wrote:

> > > Quoting Michael Stone (michael@laptop.org):
> > > > Implement security_* hooks for socket_create, socket_bind, socket_connect,
> > > > socket_sendmsg, and ptrace_access_check which return -EPERM when called from a
> > > > process with networking restrictions. Exempt AF_UNIX sockets.
> > > > 
> > > > Signed-off-by: Michael Stone <michael@laptop.org>
> > > 
> > > Acked-by: Serge Hallyn <serue@us.ibm.com>
> > 
> > For the record: NAK, as it introduces security holes.
> 
> Please elaborate.

Pavel's position is that disablenetwork is likely to permit some attacker
somewhere to deny network access to some setuid app some day in a way that
violates some security policy.

He has mentioned specific concern over scenarios like:

   Alice configures PAM auth to 'fail open' by checking login credentials
   against a restrictive LDAP server and, if the server is unavailable, against
   a very permissive files database.

   Alice updates her kernel to a version with disablenetwork.

   Mallory calls disablenetwork, calls su -, and vanquishes all.

My position is that better isolation facilities like disablenetwork will
prevent far more grievous security faults than they (theoretically) cause.

What is your perspective on the matter?

Regards,

Michael
