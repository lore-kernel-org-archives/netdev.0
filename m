From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next] net: revert "sched classifier: make cgroup
 table local"
Date: Thu, 2 Jan 2014 17:21:10 -0800
Message-ID: <20140102172110.38e0c473@nehalam.linuxnetplumber.net>
References: <1388703521-5535-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140102.190323.819558246638891031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:34263 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbaACBVO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 20:21:14 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so15025820pbc.7
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 17:21:13 -0800 (PST)
In-Reply-To: <20140102.190323.819558246638891031.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 02 Jan 2014 19:03:23 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Thu,  2 Jan 2014 14:58:41 -0800
>=20
> > This reverts commit de6fb288b1246a5c4e00c0cdbfe3a838a360b3f4.
> > Otherwise we got:
> >=20
> > net/sched/cls_cgroup.c:106:29: error: static declaration of =A1net_=
cls_subsys=A2 follows non-static declaration
> >  static struct cgroup_subsys net_cls_subsys =3D {
> >                              ^
> > In file included from include/linux/cgroup.h:654:0,
> >                  from net/sched/cls_cgroup.c:18:
> > include/linux/cgroup_subsys.h:35:29: note: previous declaration of =
=A1net_cls_subsys=A2 was here
> >  SUBSYS(net_cls)
> >                              ^
> > make[2]: *** [net/sched/cls_cgroup.o] Error 1
> >=20
> > Cc: Stephen Hemminger <stephen@networkplumber.org>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>=20
> This is so damn unintuitive, and that build error only occurs if you
> build cls_cgroup statically.
>=20
> Applied, but the way this works is terrible.

Just removing from the include file is probably enough to fix it.
