From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Fri, 01 Jan 2010 08:26:55 -0800
Message-ID: <m1zl4x4wq8.fsf@fess.ebiederm.org>
References: <551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
	<m1fx6suswz.fsf@fess.ebiederm.org> <20091230201712.GA23999@us.ibm.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Andrew G. Morgan" <morgan@kernel.org>,
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
	=?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752148Ab0AAQ1Y@vger.kernel.org>
In-Reply-To: <20100101144300.023f47a5@lxorguk.ukuu.org.uk> (Alan Cox's message of "Fri\, 1 Jan 2010 14\:43\:00 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

>> - unprivileged process took action to prevent gaining a capability.
>> - exec'd suid sendmail.
>> - sendmail took action as root because it could not become someone else.
>
> Which is a classic bug and replicated historically in cpu time, quota and
> other similar "remove rights and then .." attacks.

Exactly.  The problem that most limits the evolution of the unix
userspace API for ordinary processes.  I want a per process disable so
I can use advanced features of the API without being root (or a subset
of root).

>> I would like to trivially stop that entire class of exploit by making
>> execing a suid ( or equivalent ) executable impossible.
>
> Fine the LSM modules can already build such policies or you can add a new
> LSM for it - it doesn't need whacky one off extensions to prctl.

No it needs a proper system call. no_suid_for_me_and_my_children().
Spelled nosuid to keep from breaking peoples fingers.

> Of course you could also have an LSM which undoes restrictions on suid
> apps instead. Thats an equally valid model, just don't load both at once
> and don't assume you have the one true model.

Alan what are you talking about?  LSMs are not allowed to remove
restrictions.

You are quite right that my initial patch is a bit hacky, I am doing
my development in the open, proving that the concept can be sanely
implemented with very little code, and getting feedback from people
who know the area of code better than I do.  I know development in the
open and not having everything perfect and committed to before you
submit a patch is a strange concept on linux-kernel, but I am trying
it out.

My target audience here are application developers.  Not professional
system administrators, not distribution maintainers, and certainly
not professional security trolls.

I am about removing an impediment from the unix API for those
applications that don't need it so they can use features that would
otherwise be reserved to root and only root, because those features
can be used to addle suid applications.

I am sick and fed up with the conversations that go:
- I want to do X.
- X has been implemented.
- Sorry I can't use X as implemented because you have to be root to
  use X.

In this case X was the network namespace, which for non-root
users happens to act just like the proposed disable_network.

Putting something in an LSM versus anywhere else in the kernel still
pollutes the pool and we still have to maintain it forever.  So my
preference is for something small, trivial, that people can easily
audit.

I am not satisfied with my patch to disable suid yet, but it does
look simple and in the right ballpark.  It certainly needs better
integration with securebits and the like.

So Alan would you please give some constructive criticism about:
- Why this is a bad idea.
- How to implement this so it is available to application developers
  in general.

As I see and I may be wrong the LSM and the security modules that
exist today are useless unless you control the entire machine the
kernel runs on.  Which applications short of Oracle do not.

Personally I think I am on the sent of a good general feature that
makes sense, is useful in a lot of situations, is useful to a lot of
different people, and is useful in a lot of different ways.

Anything we merge into the mainstream kernel we have to maintain
forever, LSM or core feature.  I think this is a good backwards
compatible feature that removes impediments to forward compatibility.

Eric
