From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 09:52:51 -0700
Message-ID: <4810BAE3.5070406@redhat.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>  <20080424112514.055d8071@the-village.bc.nu>  <alpine.LFD.1.10.0804240828100.2779@woody.linux-foundation.org>  <20080424.083908.147395158.davem@davemloft.net> <517f3f820804240903y788102bar5c7d1fa9bcee1c8a@mail.gmail.com> <alpine.LFD.1.10.0804240921460.2779@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	David Miller <davem@davemloft.net>, alan@lxorguk.ukuu.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55084 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303AbYDXQx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 12:53:27 -0400
In-Reply-To: <alpine.LFD.1.10.0804240921460.2779@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Linus Torvalds wrote:
> So while I don't dislike the indirect system call, I do think that if=
 we=20
> can handle a large case of the problems with an added flag to already=
=20
> existing system calls,

The easy, clean cases I already handled back when.  I wouldn't have
implemented socket this way to preserve the function signature but
that's just me.  It's hopefully over now.

What remains isn't that easy to fix.  We need syscall interface changes=
=2E
 Yes, I'd like to avoid them, too.  But sometimes the existing
interfaces are just wrong and now we have to make a decision: new
syscalls or sys_indirect.  No way around it.

As far as the userlevel interface is concerned, this is not quite the
same.  As explained before, I've anticipated some of the problems.
signalfd, eventfd have no flags parameter in the syscall but I have the=
m
in the userlevel interface.  I.e., any kernel change will be hidden.  A=
t
least as far as the interface signature is concerned.


So, the question still is on the table: do you want sys_indirect?

If yes, then then new sys_accept would use sys_indirect instead of a ne=
w
entry point.  If you don't want sys_indirect, then I'll submit a new
sys_accept syscall (already have the patch here ready to go).

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIELrj2ijCOnn/RHQRAtewAJ4+826rxwtckEvvOaXdiNSr/5ECPACfWwTn
hgt5EYrrj/imBloPE7DxHJA=3D
=3DT6LW
-----END PGP SIGNATURE-----
