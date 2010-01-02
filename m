From: Peter Dolding <oiaohm@gmail.com>
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Sat, 2 Jan 2010 10:42:17 +1000
Message-ID: <e7d8f83e1001011642g3b642ca8ua255947c44049fcf@mail.gmail.com>
References: <551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
	 <3e8340490912301844p4fddaf57ke58ceeba9582e0fa@mail.gmail.com>
	 <20091231173334.5e3d7557@lxorguk.ukuu.org.uk>
	 <20091231175257.GA7210@us.ibm.com>
	 <551280e50912311020x2bdc5b1o699a601f67b91662@mail.gmail.com>
	 <m1aawzm1tc.fsf@fess.ebiederm.org>
	 <20100101144300.023f47a5@lxorguk.ukuu.org.uk>
	 <m1zl4x4wq8.fsf@fess.ebiederm.org> <4B3E6A8B.7060705@schaufler-ca.com>
	 <20100101223919.00b60938@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Andrew G. Morgan" <morgan@kernel.org>,
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
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:61713 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059Ab0ABAmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jan 2010 19:42:19 -0500
In-Reply-To: <20100101223919.00b60938@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 2, 2010 at 8:39 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>> Sure. Not that it would be hard to do so. And have a careful look
>> at the recent discussions on checkpoint/restart.
>
> Indeed the LSM "no removal of restrictions" is simply a policy decision
> that came about early on - no reason to assume it is a right policy
> decision if it can be shown otherwise.
>
>> Application developers want systems that work the way the man pages
>> say they work. They do not want additional or conditional restrictions.
>
> I disagree somewhat. They want them to work they way they did when they
> tested it and the way they believe it works. Most of them never read the
> manual or the standards documents. Take a look at the whining when stat()
> size data stopped happening by chance to reflect bytes queued in a pipe.
>
>> How many commercial applications start their installation instructions
>> with "disable SELinux"? (Hint: lots)
>
> And I am sure it time the sequence is going to go "Why did your business
> web site get taken out for four weeks" / "We disabled SELinux as the app
> said" / "Sue the app vendor"
>
> If you tell someone to disable the safety systems on a crane you get
> prosecuted.
>
>
The disable SELinux is the same problem I pointed to.

"There is no generic LSM API for application or users to talk to the
LSM and say I want the following restricted."

I should expand that to say "There is no generic way for applications
to say I want the following restricted and I need the following to
operate."

SELinux is far more complex that want application developers need to know about.

To an application developers.
1) Mandatory access controls that relate to what the application need
to do is of interest.
2) mandatory integrity controls that relate to what the application
needs protected of interest.

Notice something here User related stuff like  role-based access
control not really of interest.   The user related stuff could be
configured different between modules and distributions.  User based
configurations own to the administrator of the network not application
developers.

Application developers need generic interfaces so they can code.
Administrators need replaceable modules so if one secuirty framework
gets breached or they need different user controls they can swap it.

Meeting both requirements is possible.   Will make Administrators and
Distributions job simpler because it will not longer be guessing
blind.

Current problem we have here is that what should be application
developers and what should be administrators of the network are mixing
up in one big mother of a mess.

The simple problem here is that SELinux along with Smack and others
because its too complex with too many variables making its config
files too hard for applications makers to release ones that work.

Remember safety systems can kill just as much save.  In this case we
as a kernel could be prosecuted for a too complex interface to
secuirty system when a simpler could be done to achieve the same level
of secuirty.  There have been cases where companys who have put too
complex of secuirty on devices have been sued and lost.  Due to the
fact it too so long to start up a machine to move weight off a person
that they died from crushing.

Currently Application Developers are being crushed under too large of
problem so they are responding with the only valid path remove the
defective secuirty.

Basically the One size fits all is the problem.  We currently have a
shoe that fits no one well.   We need 2 shoes one for the application
developer(Generic LSM interface for applications) one for the
administrators(Very much the current LSM system cleaned up) that fits
over the same socks(Linux) no problems.

Please don't over look Alan Cox that items like Selinux are spreading
arms out in stuff like postgresql and X11.  These interfaces really
should have been generic interfaces or the same crap of duplication
you are fighting against in kernel is going to happen every where else
in Userspace.

The compete user-space application side interfaces for LSM has been
baddy neglected.  It seams to be the idea that Applications have no
right to talk to LSM becuase that way everything will be more secure.
 LSM with application control can run finer secuirty than LSM without
application control.   Reason application know what it is doing in
each thread so can tell LSM to disable what is not need in that thread
so reducing attack points to get access where the LSM without
application control has to provide an access rights over the complete
applications.

Basically current model is defective secuirty.   So we have complex
hard to use secuirty that does not work as good as what it could.  No
wonder application developers are disabling it.   We should be more
serious about addressing the problem.

Peter Dolding
