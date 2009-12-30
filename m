From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH v2] Unprivileged: Disable raising of privileges
Date: Wed, 30 Dec 2009 12:07:56 -0800
Message-ID: <m1fx6suswz.fsf@fess.ebiederm.org>
References: <m17hs5y0mg.fsf@fess.ebiederm.org>
	<20091229211139.0732a0c1@lxorguk.ukuu.org.uk>
	<m1iqbpwjtp.fsf@fess.ebiederm.org> <20091229223631.GB22578@us.ibm.com>
	<m1aax1uoa3.fsf_-_@fess.ebiederm.org>
	<3e8340490912291954v5a837a26p64bd776102d281d7@mail.gmail.com>
	<m1r5qdt721.fsf@fess.ebiederm.org>
	<3e8340490912292057g3e87eaabn115f85b78af2b08c@mail.gmail.com>
	<m1d41w62zc.fsf_-_@fess.ebiederm.org>
	<551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
	<20091230183513.GC14493@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Andrew G. Morgan" <morgan@kernel.org>,
	Bryan Donlan <bdonlan@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
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
	Casey Schaufler <casey@schaufler-ca.c
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091230183513.GC14493@us.ibm.com> (Serge E. Hallyn's message of "Wed\, 30 Dec 2009 12\:35\:13 -0600")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Quoting Andrew G. Morgan (morgan@kernel.org):
>> Eric,
>> 
>> I'm not clear why capabilities need to be manipulated by this feature
>> (the pure capability support already has a feature for disabling
>> privilege and blocking unsafe, or insufficient privilege, execution).
>
> Not entirely - this option would also prevent file capabilities from
> being honored.

All my patch does is verify the caller doesn't have privilege.

>> Perhaps I'm just unclear what features can be more safely enabled with
>> this in effect - that is, your description suggests that this is why
>> you are doing this, but leaves it unclear what they are. Could you
>> take a few moments to enumerate some of them?
>
> There are two desirable features which are at the moment unsafe for
> unprivileged users, because it allows them to fool privileged (setuid
> or bearing file capabilities) programs.  One is to unconditionally
> restrict privilege to yourself and all your descendents.  The recent
> disablenetwork patchset is one example.  The other is the ability to
> make substantial changes to your environment in a private namespace.
> A private namespace can protect already-running privileged program,
> but cannot protect privilege-bearing binaries.  Unless we prevent
> them from bearing privilege.  Which is what this patch does.

Effectively by ensuring privileges can not be raised this removes
the set of circumstances that lead to the sendmail capabilities bug.

So any kernel feature that requires capabilities only because not
doing so would break backwards compatibility with suid applications.
This includes namespace manipulation, like plan 9.
This includes unsharing pid and network and sysvipc namespaces.

There are probably other useful but currently root only features
that this will allow to be used by unprivileged processes, that
I am not aware of.

In addition to the fact that knowing privileges can not be escalated
by a process is a good feature all by itself.  Run this in a chroot
and the programs will never be able to gain root access even if
there are suid binaries available for them to execute.

Eric
