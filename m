From: Bryan Donlan <bdonlan@gmail.com>
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Wed, 30 Dec 2009 21:44:05 -0500
Message-ID: <3e8340490912301844p4fddaf57ke58ceeba9582e0fa@mail.gmail.com>
References: <m1iqbpwjtp.fsf@fess.ebiederm.org> <m1d41w62zc.fsf_-_@fess.ebiederm.org>
	<551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
	<20091230183513.GC14493@us.ibm.com> <m1fx6suswz.fsf@fess.ebiederm.org>
	<20091230201712.GA23999@us.ibm.com> <m1hbr8tb8q.fsf_-_@fess.ebiederm.org>
	<20091230212931.233003b9@lxorguk.ukuu.org.uk> <m1skasrvnq.fsf@fess.ebiederm.org>
	<20091230230042.5d2e78ac@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	"Andrew G. Morgan" <morgan@kernel.org>,
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
	Casey Schaufler <casey@
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091230230042.5d2e78ac@lxorguk.ukuu.org.uk>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 30, 2009 at 6:00 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wr=
ote:
> On Wed, 30 Dec 2009 13:36:57 -0800
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Alan Cox <alan@lxorguk.ukuu.org.uk> writes:
>>
>> >> Added bprm->nosuid to make remove the need to add
>> >> duplicate error prone checks. =A0This ensures that
>> >> the disabling of suid executables is exactly the
>> >> same as MNT_NOSUID.
>> >
>> > Another fine example of why we have security hooks so that we don'=
t get a
>> > kernel full of other "random security idea of the day" hacks.
>>
>> Well it comes from plan 9. =A0Except there they just simply did not
>> implement suid. =A0What causes you to think dropping the ability
>> to execute suid executables is a random security idea of the day?
>
> Well to be fair its random regurgitated security idea of every year o=
r
> two.
>
> More to the point - we have security_* hooks so this kind of continuo=
us
> security proposal turdstream can stay out of the main part of the ker=
nel.
>
> Cleaning up the mechanism by which NOSUID is handled in kernel seems =
a
> good idea. Adding wacky new prctls and gunk for it doesn't, and belon=
gs
> in whatever security model you are using via the security hooks.

I see this as being a security-model agnostic API - the reason being,
the application is specifying a policy for itself that has meaning in
all existing security models, and which does not require administrator
intervention to configure. Rather than reimplementing this for each
security model, it's far better to do it just once. Moreover, by
having a single, common API, the application can state the general
policy "I will never need to gain priviliges over exec" without
needing to know what LSM is in use.

The future goal of this API is to allow us to relax restrictions on
creating new namespaces, chrooting, and otherwise altering the task's
environment in ways that may confuse privileged applications. Since
security hooks are all about making the existing security restrictions
_stricter_, it's not easy to later relax these using the security hook
model. And once we put in the general requirement that "this task
shall never gain privilege", it should be safe to relax these
restrictions for _all_ security models.

In short, this is something which is meaningful for all existing LSMs
and should be implemented in a central point, it will make things
easier for the namespace folks, and since it will lead to relaxing
restrictions later, it doesn't make sense to put it in a LSM as they
stand now.
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
