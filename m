From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet_diag: make config INET_DIAG bool
Date: Mon, 24 Sep 2012 13:32:26 +0200
Message-ID: <1348486346.26828.511.camel@edumazet-glaptop>
References: <b133d67a-cb5f-4d46-b3d8-b1ac9448725e@tahiti.vyatta.com>
	 <alpine.LNX.2.01.1209231540180.15692@nerf07.vanv.qr>
	 <50601E6C.3070106@cn.fujitsu.com>
	 <1348479725.26828.297.camel@edumazet-glaptop>
	 <50603355.4010001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@inai.de>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33404 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226Ab2IXLca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 07:32:30 -0400
Received: by eaac11 with SMTP id c11so1765629eaa.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 04:32:29 -0700 (PDT)
In-Reply-To: <50603355.4010001@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 18:17 +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B409=E6=9C=8824=E6=97=A5 17:42, Eric Dumazet =E5=
=86=99=E9=81=93:
> > In fact I didnt fully understand the problem you try to address.
> >=20
> > If you want to prevent module being unloaded, you need to add prope=
r
> > module_get()/module_put()
> >=20
> > So I would add a "struct module *module;" in struct sock_diag_handl=
er
> > and use it appropriately.
>=20
> Yes, I try to add reference of the module,but I can't find a proper
> location to call module_get and module_put.
>=20
> module_get should be called when userspace program use netlink to
> send dump request to the kernel,and module_put should be called when
> the dump is completed. I am right?
>=20
> BUT the userspace program may only call netlink_sendmsg without call
> netlink_recvmsg.so the reference of the module will be incorrect.

check ->dump() and ->done() methods
