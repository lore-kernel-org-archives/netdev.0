From: Valdis.Kletnieks@vt.edu
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Sun, 27 Dec 2009 06:23:40 -0500
Message-ID: <23459.1261913020@localhost>
References: <20091227010441.GA12077@heat>
            <200912271736.GDB17180.OFJHOOQStMFLVF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1261913020_3923P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: michael@laptop.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	andi@firstfloor.org, david@lang.hm, socketcan@hartkopp.net,
	alan@lxorguk.ukuu.org.uk, herbert@gondor.apana.org.au,
	bdonlan@gmail.com, zbr@ioremap.net, cscott@cscott.net,
	jmorris@namei.org, ebiederm@xmission.com, bernie@codewiz.org,
	mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, sam@synack.fr, casey@schaufler-ca.com,
	serue@us.ibm.com, pavel@ucw.cz
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: Your message of "Sun, 27 Dec 2009 17:36:48 +0900."
             <200912271736.GDB17180.OFJHOOQStMFLVF@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1261913020_3923P
Content-Type: text/plain; charset=us-ascii

On Sun, 27 Dec 2009 17:36:48 +0900, Tetsuo Handa said:

> What about defining two types of masks, one is applied throughout the rest of
> the task_struct's lifetime (inheritable mask), the other is cleared when
> execve() succeeds (local mask)?

A mask of permitted syscalls. You've re-invented SECCOMP. ;)

> When an application is sure that "I know I don't need to call execve()" or

OK, you *might* know that. Or more likely you just *think* you know that - ever
had a library routine do an execve() call behind your back?).  Or glibc
decides to do a clone2() call behind your back instead of execve(),
except on ARM where it does either a clone_nommu47() or clone_backflip() :)

> "I know execve()d programs need not to call ...()"

Unless you've done a code review of the exec'ed program, you don't know.

The big problem is that it's *not* sufficient to just run an strace or two
of normal runs and proclaim "this is the set of syscalls I need" - you need
to check all the error paths in all the shared libraries too.  It's no fun
when a program errors out, tries to do a syslog() of the fact - and then
*that* errors out too, causing the program to go into an infinite loop trying
to report the previous syslog() call just failed...

> "I want execve()d programs not to call ...()", 

Congrats - you just re-invented the Sendmail capabilities bug. ;)

This stuff is harder than it looks, especially when you realize that
syscall-granularity is almost certainly not the right security model.

> Application writers know better what syscalls the application will call than
> application users.

But the application user will know better than the writer what *actual*
security constraints need to be applied.  "I don't care *what* syscalls the
program uses, it's not allowed to access resource XYZ".

--==_Exmh_1261913020_3923P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLN0O8cC3lWbTT17ARApdcAKCbYH1wxDbBMnf92J5M+dErCGa9IQCaAr6c
1kDgjnIe+3GW1XJwa6A4Zl8=
=WCw8
-----END PGP SIGNATURE-----

--==_Exmh_1261913020_3923P--

