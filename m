From: Harald Welte <laforge@netfilter.org>
Subject: Re: [Patch]: IPv6 Connection Tracking
Date: Thu, 25 Sep 2003 11:28:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925092806.GC5758@sunbeam.de.gnumonks.org>
References: <200309250521.OAA29293@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nmemrqcdn5VTmUEE"
Cc: coreteam@netfilter.org, netfilter-devel@lists.netfilter.org,
        netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Content-Disposition: inline
In-Reply-To: <200309250521.OAA29293@toshiba.co.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--nmemrqcdn5VTmUEE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 25, 2003 at 02:21:10PM +0900, Yasuyuki Kozakai wrote:
> I failed to send this message, so I resend.

I perfectly received the message you sent yesterday.=20

> Hello,
> I'm writing to you for the first time.
> I'm a member of USAGI Project.

Yes, Yoshifuji Hideaki already informed me at OLS that there is some
effort on IPv6 connection tracking within the USAGI project.

> I completed that, so I send the patch.

Thank you very much.

First of all, it is great that somebody is working on this subject, and
that there is now working code.

However, we are now facing the problem on how we want to proceed.

Your ipv6 connection tracking is what I would like to call a
'copy+paste' port.  (please don't misunderstand me, this does _not_ mean
your work is not appreciated!)

We've already had the same kind of copy+paste port from iptables to
ip6tables (and now arptables).  Maintaining the same codebase for
different l3 protocols introduces the usual problems of code
duplication:
- large parts of the object code doing the same job
- bug fixes get applied only to one tree, not to the other
- will lead to further code replication (ipt_mac / ip6t_mac, userspace
  tools, ...)

So we've had some very painful experience with this kind of 'port'
throughout the last two years.  This is the main reason why I am now
working on a replacement for all those copy+paste ports in order to have
one unified codebase again (pkttables).

Thus, for conntrack we are now facing the same problem :(

On the one hand it is tempting to include your ip6_conntrack into the
2.6.x kernel series 'as is'.  On the other hand, this would really
increase the maintainance work needed.

On the other hand, I'd much rather see some work done on a layer 3
independent connection tracking core.  By this I mean splitting the
current ip_contnrack into nf_conntrack and nf_conntrack_ipv4 - a generic
part and a ipv4 specific part.  Then it is very easy to add the ipv6
specific part to it - and we have a even more powerful and clean
infrastructure [that would even allow us to have one end of the
connection reside in ipv4 address space, the other one in ipv6 and do
some stateful ipv4-to-ivp6 nat at a minimal cost].

Yasuyuki, what is your take on this?  Do you (or your company) regard
the work as 'finished' now, or are you interested on helping us to
implement a l3 independent connection tracking (and write the ipv6 part
of it)?

To summarize, I see the following options:

1) submit ip6_conntrack to the 2.6.x kernel
   We would then need somebody committe to maintaining it, assuring
   it keeps in sync with the work done on ip_conntrack.  I do not want
   to put the burden of ip_conntrack / ip6_conntrack synchronization on
   everybody who submits patches/bugfixes/...

2) keep ip6_conntrack in patch-o-matic and start work on a l3
   independent conntrack system.
   This would give more users to the code, since most advanced=20
   netfilter users are using patch-o-matic anyway.

> Regards
> Yasuyuki KOZAKAI
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--nmemrqcdn5VTmUEE
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/crUmXaXGVTD0i/8RAvweAJ0UwcwHbCXaxsYz2EQBAwu0aTmOmgCfQ32/
zujA7MLGQO6puFFfHRc4kWI=
=fSR6
-----END PGP SIGNATURE-----

--nmemrqcdn5VTmUEE--
