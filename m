From: Thomas Dreibholz <dreibh@iem.uni-due.de>
Subject: Re: [PATCH] net: SCTP NULL-pointer dereference problem description and fix
Date: Wed, 15 Sep 2010 14:53:11 +0200
Message-ID: <201009151453.14465.dreibh@iem.uni-due.de>
References: <201009151003.17407.dreibh@iem.uni-due.de> <4C908768.4040502@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Martin Becke <martin.becke@uni-due.de>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.uni-due.de ([132.252.185.19]:37657 "EHLO
	mailout.uni-due.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947Ab0IOMxX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 08:53:23 -0400
In-Reply-To: <4C908768.4040502@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mittwoch 15 September 2010, Shan Wei wrote:
> Thomas Dreibholz wrote, at 09/15/2010 04:03 PM:
> > sctp_assoc_update_retran_path() in net/sctp/associola.c may derefer=
ence a
> > NULL-pointer when compiled with SCTP_DEBUG option: t will be NULL i=
f
> > there is no usable path for retransmission. SCTP_DEBUG_PRINTK_IPADD=
R()
> > makes an access to t->ipaddr.v4.sin_port, without checking t before=
=2E
> > t=3D=3DNULL =3D> oops.
> >=20
> > The patch below against 2.6.36-rc4 (git repository) simply ensures =
that t
> > is checked for not being set to NULL before calling
> > SCTP_DEBUG_PRINTK_IPADDR().
>=20
> This bug has been reported by WeiYongjun and fixed by vlad for severa=
l
> months. About the details see .
> http://marc.info/?l=3Dlinux-sctp&m=3D127359276009851&w=3D2
>=20
> But this patch is still in vlad's net-next tree, not in main tree.
> See the patch:
> http://git.kernel.org/?p=3Dlinux/kernel/git/vxy/lksctp-dev.git;a=3Dco=
mmit;h=3Deb1
> 639d206320e6a09168d6dd77306eaf5f02582

This patch resolves the problem. I am using the main tree. The patch sh=
ould=20
also be applied there.


Best regards
--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
 Dr. Thomas Dreibholz

 University of Duisburg-Essen,                   Room ES210
 Inst. for Experimental Mathematics              Ellernstra=C3=9Fe 29
 Computer Networking Technology Group            D-45326 Essen/Germany
-----------------------------------------------------------------------
 E-Mail:     dreibh@iem.uni-due.de
 Homepage:   http://www.iem.uni-due.de/~dreibh
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
