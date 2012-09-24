From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet_diag: make config INET_DIAG bool
Date: Mon, 24 Sep 2012 11:42:05 +0200
Message-ID: <1348479725.26828.297.camel@edumazet-glaptop>
References: <b133d67a-cb5f-4d46-b3d8-b1ac9448725e@tahiti.vyatta.com>
	 <alpine.LNX.2.01.1209231540180.15692@nerf07.vanv.qr>
	 <50601E6C.3070106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@inai.de>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62296 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520Ab2IXJmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 05:42:10 -0400
Received: by eekb15 with SMTP id b15so99404eek.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 02:42:09 -0700 (PDT)
In-Reply-To: <50601E6C.3070106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 16:48 +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B409=E6=9C=8823=E6=97=A5 21:40, Jan Engelhardt =E5=
=86=99=E9=81=93:
> > On Sunday 2012-09-23 06:36, Stephen Hemminger wrote:
> >=20
> >>> when inet_diag being compiled as module, inet_diag_handler_dump
> >>> set netlink_dump_control.dump to inet_diag_dump,so if module
> >>> inet_diag is unloaded,netlink will still try to call this functio=
n
> >>> in netlink_dump. this will cause kernel panic.
> >>
> >> Another way to handle this to just get rid of inet_diag_exit
> >> so that module can be loaded but not unloaded.
> >=20
> > Why don't we unset netlink_dump_control.dump on exit?
>=20
>=20
> Though I like this idea,but it may cause dead lock.
> netlink_dimp [mutex_lock(netlink_sock->cb_mutex) here]
>    |->inet_diag_dump
> 	|->__inet_diag_dump
> 	    |->inet_diag_lock_handler [may try to load tcp_diag here,
> 					so we need module_mutex lock]
>=20
> And on module exit,we already get module_mutex lock,
> if we unset netlink_sock->cb,we need to get mutex lock of netlink_soc=
k->cb_mutex.
>=20
> I think this will cause dead lock.
>=20
> I don't know if I should change this patch as Stephen said,because I =
don't know
> witch one is better.
>=20
> Any comments?

In fact I didnt fully understand the problem you try to address.

If you want to prevent module being unloaded, you need to add proper
module_get()/module_put()

So I would add a "struct module *module;" in struct sock_diag_handler
and use it appropriately.

But then, I might have totally misunderstood the problem.

Care to explain how you trigger the bug ?
