From: Bryan Donlan <bdonlan@gmail.com>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 14:08:30 -0500
Message-ID: <3e8340490912291108t7e000e75p8264fa585f831464@mail.gmail.com>
References: <20091229050114.GC14362@heat> <m1y6km11lj.fsf@fess.ebiederm.org>
	<20091229151146.GA32153@us.ibm.com> <3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
	<20091229163939.GA6984@us.ibm.com> <3e8340490912290901y60d7daf2w5778c25f44972955@mail.gmail.com>
	<m1fx6ty6ds.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
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
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752363AbZL2TIy@vger.kernel.org>
In-Reply-To: <m1fx6ty6ds.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 29, 2009 at 1:36 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Bryan Donlan <bdonlan@gmail.com> writes:
>
>> On Tue, Dec 29, 2009 at 11:39 AM, Serge E. Hallyn <serue@us.ibm.com>=
 wrote:
>>> Quoting Bryan Donlan (bdonlan@gmail.com):
>>>> On Tue, Dec 29, 2009 at 10:11 AM, Serge E. Hallyn <serue@us.ibm.co=
m> wrote:
>>>> > Eric, let me specifically point out a 'disable setuid-root'
>>>> > problem on linux: root still owns most of the system even when
>>>> > it's not privileged. =A0So does "disable setuid-root" mean
>>>> > we don't allow exec of setuid-root binaries at all, or that
>>>> > we don't setuid to root, or that we just don't raise privileges
>>>> > for setuid-root?
>>>>
>>>> I, for one, think it would be best to handle it exactly like the
>>>> nosuid mount option - that is, pretend the file doesn't have any
>>>> setuid bits set. There's no reason to deny execution; if the proce=
ss
>>>> would otherwise be able to execute it, it can also copy the file t=
o
>>>> make a non-suid version and execute that instead. And some program=
s
>>>> can operate with reduced function without setuid. For example, scr=
een
>>>> comes to mind; it needs root to share screen sessions between mult=
iple
>>>> users, but can operate for a single user just fine without root, a=
nd
>>>> indeed the latter is usually the default configuration.
>>>
>>> That's fine with me, seems safe for a fully unprivileged program to
>>> use, and would make sense to do through one of the securebits set
>>> with prctl(PR_SET_SECUREBITS).
>>>
>>> In addition, I assume we would also refuse to honor file capabiliti=
es?
>>
>> Yes - essentially a one-time switch saying "never allow me to gain
>> capabilities again".
>
> That is what I was thinking. =A0Does setresuid case problems? =A0Assu=
ming
> the application that drop permissions could have successfully
> called setresuid?

It's probably reasonable to require that real =3D=3D effective =3D=3D s=
aved =3D=3D
fs UID (and same for GID); anything else brings up sticky issues of
"which UID is a higher capability?"
If a process does this call, it's effectively saying that the only way
it's going to be accessing resources beyond its current UID and
capabilities is by talking to another process over a (unix domain)
socket.
