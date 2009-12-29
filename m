From: Bryan Donlan <bdonlan@gmail.com>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 15:43:52 -0500
Message-ID: <3e8340490912291243q7ba43fd9v266835ebbda9315b@mail.gmail.com>
References: <20091229050114.GC14362@heat> <m1y6km11lj.fsf@fess.ebiederm.org>
	<20091229151146.GA32153@us.ibm.com> <3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
	<m3oclhzgm4.fsf@ursa.amorsen.dk> <m17hs5y0mg.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Amorsen <benny+usenet@amorsen.dk>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
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
	Pavel Machek <pavel@ucw.cz>,
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752667AbZL2UoS@vger.kernel.org>
In-Reply-To: <m17hs5y0mg.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 29, 2009 at 3:40 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Benny Amorsen <benny+usenet@amorsen.dk> writes:
>
>> Bryan Donlan <bdonlan@gmail.com> writes:
>>
>>> I, for one, think it would be best to handle it exactly like the
>>> nosuid mount option - that is, pretend the file doesn't have any
>>> setuid bits set. There's no reason to deny execution; if the process
>>> would otherwise be able to execute it, it can also copy the file to
>>> make a non-suid version and execute that instead.
>>
>> Execute != read. The executable file may contain secrets which must not
>> be available to the user running the setuid program. If you fail the
>> setuid, the user will be able to ptrace() and then the secret is
>> revealed.
>>
>> It's amazing how many security holes appear from what seems like a very
>> simple request.
>
> Do we have a security hole in nosuid mount option?

Looks like it:
$ /tmp/m/sudo
sudo: must be setuid root
$ ls -l /tmp/m/sudo
-rwsr-x--x 1 root root 123448 2009-06-22 12:14 /tmp/m/sudo
