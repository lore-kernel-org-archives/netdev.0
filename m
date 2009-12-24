From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] Security: Add prctl(PR_{GET,SET}_NETWORK)
Date: Thu, 24 Dec 2009 04:37:41 -0800
Message-ID: <m1r5qkim3u.fsf@fess.ebiederm.org>
References: <20091224061322.GB24396@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
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
	=?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091224061322.GB24396@heat> (Michael Stone's message of "Thu\, 24 Dec 2009 01\:13\:23 -0500")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Stone <michael@laptop.org> writes:

>> Eric Biederman writes:
>>> Alan Cox <alan@lxorguk.ukuu.org.uk> writes:
>>>> Michael Stone writes:
>>>>> the LSM-based version *does not* resolve the situation to my satisfaction as a
>>>>> userland hacker due to the well-known and long-standing adoption and
>>>>> compositionality problems facing small LSMs. ;)
>>>>
>>>> For things like Fedora it's probably an "interesting idea, perhaps we
>>>> should do it using SELinux" sort of problem, but a config option for a
>>>> magic network prctl is also going to be hard to adopt without producing a
>>>> good use case - and avoiding that by dumping crap into everyones kernel
>>>> fast paths isn't a good idea either.
>>
>>If I understand the problem the goal is to disable access to ipc
>>mechanism that don't have the usual unix permissions.  To get
>>something that is usable for non-root processes, and to get something
>>that is widely deployed so you don't have to jump through hoops in
>>end user applications to use it.
>
> Eric,
>
> You understand correctly. Thank you for this cogent restatement.
>
>>We have widely deployed mechanisms that are what you want or nearly
>>what you want already in the form of the various namespaces built for
>>containers.
>
> It's true that your work is closer to what I want than anything else that I've
> seen so far...
>
>> I propose you introduce a permanent disable of executing suid applications. 
>
> I'm open to the idea but I don't understand the need that motivates it yet.
> Could you please explain further? (or point me to an existing explanation?)

With namespaces it is possible to masquarade as a trusted source,
of information to a suid program such as /etc/passwd or a NIS server.

A one-way removal of the ability to exec suid programs is generally
simple and handy like chroot, and removes the need for CAP_SYS_ADMIN
in most cases.

Plan 9 did not support suid executables and supported an unprivileged
equivalent of unshare(NEWNS).

I need the full unprivileged unshare of USERNS for my primary
uses today as I need to perform normally root only activities
like mounting loopback devices, and setting up networking. Your
uses of limiting of ipc do not appear to require that.

>>After which point it is another trivial patch to allow unsharing of
>>the network namespace if executing suid applications are disabled.
>
> How do you propose to address the problem with the Unix sockets?

Careful code review of the patch to allow talking between network
namespaces with unix domain sockets.  This is a feature that we
simply have not merged yet.  Semantically it is fine today. It is
simply no one has answered the question what other implications
could there be.  Now that I know of 2 or 3 compelling use
cases and most of the rest of the work done.  It seems time to
relax the restriction.

Eric
