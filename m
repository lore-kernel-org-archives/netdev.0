From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] inet_diag: make config INET_DIAG bool
Date: Mon, 24 Sep 2012 16:48:44 +0800
Message-ID: <50601E6C.3070106@cn.fujitsu.com>
References: <b133d67a-cb5f-4d46-b3d8-b1ac9448725e@tahiti.vyatta.com> <alpine.LNX.2.01.1209231540180.15692@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:22213 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755255Ab2IXIsl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 04:48:41 -0400
In-Reply-To: <alpine.LNX.2.01.1209231540180.15692@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B409=E6=9C=8823=E6=97=A5 21:40, Jan Engelhardt =E5=
=86=99=E9=81=93:
> On Sunday 2012-09-23 06:36, Stephen Hemminger wrote:
>=20
>>> when inet_diag being compiled as module, inet_diag_handler_dump
>>> set netlink_dump_control.dump to inet_diag_dump,so if module
>>> inet_diag is unloaded,netlink will still try to call this function
>>> in netlink_dump. this will cause kernel panic.
>>
>> Another way to handle this to just get rid of inet_diag_exit
>> so that module can be loaded but not unloaded.
>=20
> Why don't we unset netlink_dump_control.dump on exit?


Though I like this idea,but it may cause dead lock.
netlink_dimp [mutex_lock(netlink_sock->cb_mutex) here]
   |->inet_diag_dump
	|->__inet_diag_dump
	    |->inet_diag_lock_handler [may try to load tcp_diag here,
					so we need module_mutex lock]

And on module exit,we already get module_mutex lock,
if we unset netlink_sock->cb,we need to get mutex lock of netlink_sock-=
>cb_mutex.

I think this will cause dead lock.

I don't know if I should change this patch as Stephen said,because I do=
n't know
witch one is better.

Any comments?
