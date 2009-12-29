From: Bryan Donlan <bdonlan@gmail.com>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 12:01:39 -0500
Message-ID: <3e8340490912290901y60d7daf2w5778c25f44972955@mail.gmail.com>
References: <20091229050114.GC14362@heat> <m1y6km11lj.fsf@fess.ebiederm.org>
	<20091229151146.GA32153@us.ibm.com> <3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
	<20091229163939.GA6984@us.ibm.com>
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
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091229163939.GA6984@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 29, 2009 at 11:39 AM, Serge E. Hallyn <serue@us.ibm.com> wr=
ote:
> Quoting Bryan Donlan (bdonlan@gmail.com):
>> On Tue, Dec 29, 2009 at 10:11 AM, Serge E. Hallyn <serue@us.ibm.com>=
 wrote:
>> > Eric, let me specifically point out a 'disable setuid-root'
>> > problem on linux: root still owns most of the system even when
>> > it's not privileged. =A0So does "disable setuid-root" mean
>> > we don't allow exec of setuid-root binaries at all, or that
>> > we don't setuid to root, or that we just don't raise privileges
>> > for setuid-root?
>>
>> I, for one, think it would be best to handle it exactly like the
>> nosuid mount option - that is, pretend the file doesn't have any
>> setuid bits set. There's no reason to deny execution; if the process
>> would otherwise be able to execute it, it can also copy the file to
>> make a non-suid version and execute that instead. And some programs
>> can operate with reduced function without setuid. For example, scree=
n
>> comes to mind; it needs root to share screen sessions between multip=
le
>> users, but can operate for a single user just fine without root, and
>> indeed the latter is usually the default configuration.
>
> That's fine with me, seems safe for a fully unprivileged program to
> use, and would make sense to do through one of the securebits set
> with prctl(PR_SET_SECUREBITS).
>
> In addition, I assume we would also refuse to honor file capabilities=
?

Yes - essentially a one-time switch saying "never allow me to gain
capabilities again".
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
