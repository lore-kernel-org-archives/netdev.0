From: Bryan Donlan <bdonlan@gmail.com>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 11:05:09 -0500
Message-ID: <3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
References: <20091229050114.GC14362@heat> <m1y6km11lj.fsf@fess.ebiederm.org>
	<20091229151146.GA32153@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>, Al Viro <viro@zeniv.linux.org.uk>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:55444 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbZL2QFc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 11:05:32 -0500
In-Reply-To: <20091229151146.GA32153@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2009 at 10:11 AM, Serge E. Hallyn <serue@us.ibm.com> wr=
ote:
> Eric, let me specifically point out a 'disable setuid-root'
> problem on linux: root still owns most of the system even when
> it's not privileged. =A0So does "disable setuid-root" mean
> we don't allow exec of setuid-root binaries at all, or that
> we don't setuid to root, or that we just don't raise privileges
> for setuid-root?

I, for one, think it would be best to handle it exactly like the
nosuid mount option - that is, pretend the file doesn't have any
setuid bits set. There's no reason to deny execution; if the process
would otherwise be able to execute it, it can also copy the file to
make a non-suid version and execute that instead. And some programs
can operate with reduced function without setuid. For example, screen
comes to mind; it needs root to share screen sessions between multiple
users, but can operate for a single user just fine without root, and
indeed the latter is usually the default configuration.
