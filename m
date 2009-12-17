From: Bernie Innocenti <bernie@codewiz.org>
Subject: Re: Network isolation with RLIMIT_NETWORK, cont'd.
Date: Thu, 17 Dec 2009 14:23:02 -0500
Message-ID: <1261077782.4073.20.camel@giskard.codewiz.org>
References: <m1ljh7jijk.fsf@fess.ebiederm.org> <20091213142149.GB4777@heat>
	 <fb69ef3c0912170931l5cbf0e3dh81c88e6502651042@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Stone <michael@laptop.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	=?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Linux Containers <containers@lists.osdl.org>
To: Mark Seaborn <mrs@mythic-beasts.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965405AbZLQTXR@vger.kernel.org>
In-Reply-To: <fb69ef3c0912170931l5cbf0e3dh81c88e6502651042@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-12-17 at 17:31 +0000, Mark Seaborn wrote:


> The reason chroot() and clone()/CLONE_NEWNS are privileged is that
> they provide a way to violate the assumptions of setuid/setgid
> executables.  If we add a per-process flag that prevents a process
> from exec'ing setuid executables, we could allow chroot() and
> CLONE_NEWNS when that flag is set.  That fixes (a).

I think this would be great.

> 
> Maybe we could fix (b) by making mount namespaces into first class
> objects that can be named through a file descriptor, so that one
> process can manipulate another process's namespace without itself
> being subject to the namespace.

I think Michael's problem with debugging is much more fundamental:
application programmers get confused when some filesystem operations
fail in the debugged process, while it works fine from the shell.

It would help if the kernel provided a way for a process to switch to
another process' namespace. Even better, it would be great if existing
namespaces could be mounted at an arbitrary position within another
namespace. Then one could use traditional shell tools to inspect it, or
even chroot into it.

</delirium>

-- 
   // Bernie Innocenti - http://codewiz.org/
 \X/  Sugar Labs       - http://sugarlabs.org/
