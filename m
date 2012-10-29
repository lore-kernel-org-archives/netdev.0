From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: huh, entered softirq 3 NET_RX 082db810 preempt_count 00000101,
 exited with fffefc05?
Date: Mon, 29 Oct 2012 08:09:01 +0000 (UTC)
Message-ID: <k6ldit$kkk$1@ger.gmane.org>
References: <508AF3D4.4020707@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:60913 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754702Ab2J2IJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 04:09:13 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TSkPP-0000cQ-O2
	for netdev@vger.kernel.org; Mon, 29 Oct 2012 09:09:19 +0100
Received: from 112.132.138.96 ([112.132.138.96])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 09:09:19 +0100
Received: from xiyou.wangcong by 112.132.138.96 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 09:09:19 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Oct 2012 at 20:34 GMT, Toralf F=C3=B6rster <toralf.foerster@=
gmx.de> wrote:
> At a user mode linux image (unstable Gentoo) I experienced a hang
> (100% CPU of the linux process), no reaction anymore.
>
> The last lines in the syslog of the UML gave:
>
> ...
> Oct 26 22:18:07 n22_uml kernel: Virtual console 6 assigned device '/d=
ev/pts/5'                                              =20
> Oct 26 22:18:07 n22_uml kernel: Virtual console 4 assigned device '/d=
ev/pts/6'                                                             =20
> Oct 26 22:18:07 n22_uml kernel: Virtual console 5 assigned device '/d=
ev/pts/8'                                                             =20
> Oct 26 22:18:07 n22_uml kernel: Virtual console 3 assigned device '/d=
ev/pts/9'                                                             =20
> Oct 26 22:18:07 n22_uml kernel: Virtual console 2 assigned device '/d=
ev/pts/10'                                                            =20
> Oct 26 22:18:07 n22_uml kernel: Virtual console 1 assigned device '/d=
ev/pts/11'                                                            =20
> Oct 26 22:19:05 n22_uml kernel: ------------[ cut here ]------------ =
                                                                      =20
> Oct 26 22:19:05 n22_uml kernel: WARNING: at kernel/softirq.c:160 loca=
l_bh_enable+0x8f/0xa0()                                               =20
> Oct 26 22:19:05 n22_uml kernel: 384fa37c:  [<0836bc48>] dump_stack+0x=
22/0x24                                                               =20
> Oct 26 22:19:05 n22_uml kernel: 384fa394:  [<0807fc2a>] warn_slowpath=
_common+0x5a/0x80                                                     =20
> Oct 26 22:19:05 n22_uml kernel: 384fa3bc:  [<0807fd03>] warn_slowpath=
_null+0x23/0x30                                                       =20
> Oct 26 22:19:05 n22_uml kernel: 384fa3cc:  [<0808733f>] local_bh_enab=
le+0x8f/0xa0                                                           =
                    =20
> Oct 26 22:19:05 n22_uml kernel: 384fa3e0:  [<082da6f8>] dev_queue_xmi=
t+0xe8/0x270                                                           =
                    =20
> Oct 26 22:19:05 n22_uml kernel: 384fa410:  [<082fd15f>] ip_finish_out=
put+0x1af/0x370                                                        =
                    =20
> Oct 26 22:19:05 n22_uml kernel: 384fa444:  [<082fd373>] ip_output+0x5=
3/0x60                                                                 =
                    =20
> Oct 26 22:19:05 n22_uml kernel: 384fa45c:  [<082fc243>] ip_local_out+=
0x23/0x30                                                              =
                    =20
> Oct 26 22:19:05 n22_uml kernel: 384fa46c:  [<082fc384>] ip_build_and_=
send_pkt+0x134/0x1f0                                                   =
                    =20
> Oct 26 22:19:05 n22_uml kernel: 384fa4a8:  [<08319dc0>] tcp_v4_conn_r=
equest+0x7c0/0xcc0                                                     =
                    =20

Seems we want to send some packet inside tcp_v4_conn_request()
while we just receive one in softIRQ, not sure why we defer it.

Thanks.
