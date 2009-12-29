From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 03:06:16 -0800
Message-ID: <m1y6km11lj.fsf@fess.ebiederm.org>
References: <20091229050114.GC14362@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
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
	Pavel Machek <pavel@ucw.cz>, Al Viro <viro@ZenIV.linux.org.uk>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752796AbZL2LGr@vger.kernel.org>
In-Reply-To: <20091229050114.GC14362@heat> (Michael Stone's message of "Tue\, 29 Dec 2009 00\:01\:14 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Stone <michael@laptop.org> writes:

> Serge,
>
> I think that Pavel's point, at its strongest and most general, could be
> rephrased as:
>
>   "Adding *any* interesting isolation facility to the kernel breaks backwards
>    compatibility for *some* program [in a way that violates security goals]."

*some* privileged program.

> The reason is the one that I identified in my previous note:
>
>   "The purpose of isolation facilities is to create membranes inside which
>    grievous security faults are converted into availability faults."
>
> The question then is simply:
>
>   "How do we want to deal with the compatibility-breaking changes created by
>    introducing new isolation facilities?"

You have a very peculiar taxonomy of the suggestions,
that fails to capture the concerns.

I strongly recommend working out a way to disable
setuid exec.  Ideally we would use capabilities to
achieve this.  

Serge can we have a capability that unprivelged processes
normally have an can drop without privelege?

I can see one of two possible reasons you are avoiding the
suggestion to disable setuid root.
- You have a use for setuid root executables in your contained
  environment.  If you do what is that use?
- Disabling suid root executables is an indirect path to your
  goal.

The problem with the disable_network semantics you want
is that they allow you to perform a denial of service attack
on privileged users.  An unprivileged DOS attack is unsuitable
for a general purpose feature in a general purpose kernel.

Your sysctl, your boot option, your Kconfig option all fail
to be viable options for the same reason.  Your facility is
only valid in an audited userspace.

Disabling setuid-exec especially to a subset of processes is
valid in an unaudited userspace as it does not allow propagating
the DOS to privileged processes.

Eric
