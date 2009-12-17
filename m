From: Bryan Donlan <bdonlan@gmail.com>
Subject: Re: Network isolation with RLIMIT_NETWORK, cont'd.
Date: Thu, 17 Dec 2009 14:53:00 -0500
Message-ID: <3e8340490912171153s56e966d6lb76041fefc52e735@mail.gmail.com>
References: <m1ljh7jijk.fsf@fess.ebiederm.org> <20091213142149.GB4777@heat>
	<fb69ef3c0912170931l5cbf0e3dh81c88e6502651042@mail.gmail.com>
	<3e8340490912171024n2120e88q569c69fe7d09140f@mail.gmail.com>
	<1261078517.4073.32.camel@giskard.codewiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mark Seaborn <mrs@mythic-beasts.com>,
	Michael Stone <michael@laptop.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	=?ISO-8859-1?Q?R=E9mi_Denis=2DCourmont?= <rdenis@simphalempin.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Linux Containers <containers@lists.osdl.org>
To: Bernie Innocenti <bernie@codewiz.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1261078517.4073.32.camel@giskard.codewiz.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 17, 2009 at 2:35 PM, Bernie Innocenti <bernie@codewiz.org> wrote:
> On Thu, 2009-12-17 at 13:24 -0500, Bryan Donlan wrote:
>> Can this be done using openat() and friends currently? It would seem
>> the natural way to implement this; open /proc/(pid)/root, then
>> openat() things from there (or even chdir to it and see the mounts
>> that it sees from there...)
>
> Yeah, but /proc/<pid>/root is just a symlink. It's correct for chroots,
> but I doubt it can be meaningful for per-process namespaces.

The files in /proc/<pid>/fs are 'just symlinks', but opening them can
provide access to objects (eg, deleted files) not accessible through
the normal filesystem namespace. I see no reason, API-wise, why
/proc/<pid>/root couldn't be extended similarly - but I've not looked
at the namespaces implementation, so maybe there's some reason it'd be
difficult to implement...
