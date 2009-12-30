From: Bryan Donlan <bdonlan@gmail.com>
Subject: Re: [RFC][PATCH] Unprivileged: Disable acquisition of privileges
Date: Tue, 29 Dec 2009 23:57:50 -0500
Message-ID: <3e8340490912292057g3e87eaabn115f85b78af2b08c@mail.gmail.com>
References: <20091229050114.GC14362@heat> <3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
	<m3oclhzgm4.fsf@ursa.amorsen.dk> <m17hs5y0mg.fsf@fess.ebiederm.org>
	<20091229211139.0732a0c1@lxorguk.ukuu.org.uk> <m1iqbpwjtp.fsf@fess.ebiederm.org>
	<20091229223631.GB22578@us.ibm.com> <m1aax1uoa3.fsf_-_@fess.ebiederm.org>
	<3e8340490912291954v5a837a26p64bd776102d281d7@mail.gmail.com>
	<m1r5qdt721.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
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
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>,
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <m1r5qdt721.fsf@fess.ebiederm.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 29, 2009 at 11:33 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Bryan Donlan <bdonlan@gmail.com> writes:
>
>> Is this sufficient for other security models such as selinux or
>> TOMOYO? Can processes in these models gain privileges through means
>> not restricted here?
>
> The LSM is primarily about returning -EPERM more often.
> Except for the prctl and the capability hooks I am not aware
> of anywhere a LSM can increase a processes capabilities.

I'm more concerned about a case where a privilege that the LSM
currently denies is lifted by execing some executable - this is still
an increase in privilege, even though the LSM only adds additional
restrictions. That is:

1) Initial state: LSM denies access to /somefile (although normal
POSIX permissions would permit access)
2) Disable capability-gaining
3) Disable network access with proposed API
4) Exec some application, which is labeled in a way that permits
access to /somefile
5) Application fails to access the network, then does something to /somefile

I'm not entirely sure if step 4) can happen in any of the currently
existing LSMs - if it's not possible to gain privileges in them via a
suid-like mechanism, this isn't a problem, but it's something that
needs to be checked for.
