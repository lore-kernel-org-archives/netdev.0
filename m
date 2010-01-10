From: Bryan Donlan <bdonlan@gmail.com>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Sun, 10 Jan 2010 18:41:10 -0500
Message-ID: <3e8340491001101541tc776ad9r887be13393bcb7fd@mail.gmail.com>
References: <f73f7ab81001101418x3b3f8652j256f6311ad6244c5@mail.gmail.com>
	<20100110230839.GB3825@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Kyle Moffett <kyle@moffetthome.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Pavel Machek <pavel@ucw.cz
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20100110230839.GB3825@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2010 at 6:08 PM, Michael Stone <michael@laptop.org> wrote:
> Paraphrasing Kyle:
>
>> Suppose there exist PAM modules which lazily fork background processes.
>> Now
>> assume that one of those PAM modules is hooked from /etc/pam.d/su, that
>> the
>> module fails closed when the network is unavailable, and that Mallory wins
>> the race to start the daemon. Boom.
>
> I'm not disagreeing that there are configurations of programs, written for
> kernels without disablenetwork, which cease to be correct on kernels that
> provide it. However, all this says to me is that people who need to use
> those
> configurations probably shouldn't use disablenetwork. (Or that we haven't
> found
> exactly the right semantics for disablenetwork yet.)

With the semantics given, the choice for using disablenetwork is given
to the unprivileged process, not to the administrator or privileged
process, so people using these configurations have no choice - the
malicious local user can just use it anyway.

I still think requiring a drop of suid abilities would be best - if
the suid process wants to run in a no-network environment it can still
disablenetwork itself.
