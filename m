From: Bernie Innocenti <bernie@codewiz.org>
Subject: Re: Network isolation with RLIMIT_NETWORK, cont'd.
Date: Thu, 17 Dec 2009 14:35:17 -0500
Message-ID: <1261078517.4073.32.camel@giskard.codewiz.org>
References: <m1ljh7jijk.fsf@fess.ebiederm.org> <20091213142149.GB4777@heat>
	 <fb69ef3c0912170931l5cbf0e3dh81c88e6502651042@mail.gmail.com>
	 <3e8340490912171024n2120e88q569c69fe7d09140f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
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
	=?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Linux Containers <containers@lists.osdl.org>
To: Bryan Donlan <bdonlan@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <3e8340490912171024n2120e88q569c69fe7d09140f@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-12-17 at 13:24 -0500, Bryan Donlan wrote:
> Can this be done using openat() and friends currently? It would seem
> the natural way to implement this; open /proc/(pid)/root, then
> openat() things from there (or even chdir to it and see the mounts
> that it sees from there...)

Yeah, but /proc/<pid>/root is just a symlink. It's correct for chroots,
but I doubt it can be meaningful for per-process namespaces.

If we were to implement Mark Seaborn's idea of naming
namespaces, /proc/<pid>/rootfd would be a file descriptor providing
access to the namespace through some fancy ioctls.

Or maybe not. Could such a file-descriptor be used as the source
argument to mount(), perhaps along with a new MS_NS flag?

Alternatively, perhaps one could come up with a userspace solution:
read /proc/<pid>/mounts and repeat all mounts, perhaps with a prefix.
The downsides are that it would require superuser privs and wouldn't
automatically stay synchronized with the real namespace.

-- 
   // Bernie Innocenti - http://codewiz.org/
 \X/  Sugar Labs       - http://sugarlabs.org/

