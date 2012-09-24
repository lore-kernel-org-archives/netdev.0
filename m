From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] inet_diag: make config INET_DIAG bool
Date: Mon, 24 Sep 2012 18:17:57 +0800
Message-ID: <50603355.4010001@cn.fujitsu.com>
References: <b133d67a-cb5f-4d46-b3d8-b1ac9448725e@tahiti.vyatta.com>  <alpine.LNX.2.01.1209231540180.15692@nerf07.vanv.qr>  <50601E6C.3070106@cn.fujitsu.com> <1348479725.26828.297.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@inai.de>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64929 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751735Ab2IXKR5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 06:17:57 -0400
In-Reply-To: <1348479725.26828.297.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B409=E6=9C=8824=E6=97=A5 17:42, Eric Dumazet =E5=86=
=99=E9=81=93:
> In fact I didnt fully understand the problem you try to address.
>=20
> If you want to prevent module being unloaded, you need to add proper
> module_get()/module_put()
>=20
> So I would add a "struct module *module;" in struct sock_diag_handler
> and use it appropriately.

Yes, I try to add reference of the module,but I can't find a proper
location to call module_get and module_put.

module_get should be called when userspace program use netlink to
send dump request to the kernel,and module_put should be called when
the dump is completed. I am right?

BUT the userspace program may only call netlink_sendmsg without call
netlink_recvmsg.so the reference of the module will be incorrect.

>=20
> But then, I might have totally misunderstood the problem.
>=20
> Care to explain how you trigger the bug ?

It's very easy to trigger this bug,
you can exec "while :; do ss -a ; done" in one terminal
and exec "while :; do rmmod tcp_diag && rmmod inet_diag; done"
in another terminal.
