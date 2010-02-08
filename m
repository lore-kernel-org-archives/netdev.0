From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem wit route cache
Date: Mon, 08 Feb 2010 15:32:29 +0100
Message-ID: <1265639549.3048.33.camel@edumazet-laptop>
References: <4B700EC2.5090207@itcare.pl>
	 <1265635690.3048.8.camel@edumazet-laptop>  <4B7012BC.9000702@itcare.pl>
	 <1265637067.3048.14.camel@edumazet-laptop>  <4B7018DF.8060600@itcare.pl>
	 <1265638014.3048.20.camel@edumazet-laptop>  <4B701CA8.7050205@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f223.google.com ([209.85.218.223]:53522 "EHLO
	mail-bw0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599Ab0BHOcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 09:32:33 -0500
Received: by bwz23 with SMTP id 23so1157346bwz.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 06:32:31 -0800 (PST)
In-Reply-To: <4B701CA8.7050205@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 f=C3=A9vrier 2010 =C3=A0 15:16 +0100, Pawe=C5=82 Staszewski=
 a =C3=A9crit :

> >   =20
> Some day ago after info about route cache i was have  also this info:

> Code: fe 79 4c 00 48 85 db 74 14 48 8b 74 24 10 48 89 ef ff 13 48 83 =
c3 08 48
> 83 3b 00 eb ea 48 83 c4 18 5b 5d 41 5c 41 5d 41 5e 41 5f<c3>  55 48 8=
9 f5 53 48
> 89 fb 48 83 ec 08 48 8b 76 18 48 2b 75 10
> Call Trace:
>   <IRQ>   [<ffffffff8126826f>] ? e1000_put_txbuf+0x62/0x74
>   [<ffffffff8126834a>] ? e1000_clean_tx_irq+0xc9/0x235
>   [<ffffffff8126b71b>] ? e1000_clean+0x5c/0x21c
>   [<ffffffff812f29a3>] ? net_rx_action+0x71/0x15d
>   [<ffffffff81035311>] ? __do_softirq+0xd7/0x196
>   [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
>   [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
>   [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
>   <EOI>   [<ffffffff81004599>] ? do_softirq+0x31/0x63
>   [<ffffffff81034ec1>] ? local_bh_enable_ip+0x75/0x86
>   [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
>   [<ffffffff812f775d>] ? dst_gc_task+0xce/0x1a7
>   [<ffffffff8136b08c>] ? schedule+0x82c/0x906
>   [<ffffffff8103c44f>] ? lock_timer_base+0x26/0x4b
>   [<ffffffff810a41d6>] ? cache_reap+0x0/0x11d
>   [<ffffffff81044c38>] ? worker_thread+0x14c/0x1dc
>   [<ffffffff81047dcd>] ? autoremove_wake_function+0x0/0x2e
>   [<ffffffff81044aec>] ? worker_thread+0x0/0x1dc
>   [<ffffffff810479bd>] ? kthread+0x79/0x81
>   [<ffffffff81002cb4>] ? kernel_thread_helper+0x4/0x10
>   [<ffffffff81047944>] ? kthread+0x0/0x81
>=20
>=20
>   [<ffffffff81002cb0>] ? kernel_thread_helper+0x0/0x10
>=20
>=20

This trace is indeed very interesting, since dst_gc_task() is run from =
a
work queue, and there is no scheduling point in it.

We might need add a scheduling point in dst_gc_task() in case huge
number of entries were flushed.



