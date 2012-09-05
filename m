From: =?UTF-8?Q?=22Sascha_M=C3=BChlbach=22?= <smka2012@email.de>
Subject: Aw: Re: Question regarding kernel panic in net/ipv4/tcp_output.c
Date: Wed, 5 Sep 2012 11:01:43 +0200 (CEST)
Message-ID: <trinity-299e8894-40a0-46ec-bc19-1b74a0090b83-1346835703144@3capp-webde-bs46>
References: <trinity-daf22487-c4bf-4a4e-ae69-ed50d70f6169-1346759712289@3capp-webde-bs16>,
 <1346761388.13121.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:53294 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932475Ab2IEJBq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 05:01:46 -0400
In-Reply-To: <1346761388.13121.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,=0D
=C2=A0=0D
this is the stack trace I could save by making a screenshot of the remo=
te console:=0D
=C2=A0=0D
[<ffffffff8101193b>] ? invalid_op+0x1b/0x20=0D
[<ffffffff81289e6a>] ? tcp_retransmit_skb+0x66/0x5aa=0D
[<ffffffff8128a546>] ? tcp_xmit_retransmit_queue+0x198/0x223=0D
[<ffffffff81286113>] ? tcp_ack+0x1744/0x1952=0D
[<ffffffff81286871>] ? tcp_validate_incoming+0x1ba/0x2be=0D
[<ffffffff81286f5e>] ? tcp_rcv_established+0x5e9/0x6d9=0D
[<ffffffff8128e00f>] ? tcp_v4_do_rcv+0x1bb/0x376=0D
[<ffffffff8128e639>] ? tcp_v4_rcv+0x46f/0x6f8=0D
[<ffffffff81273afa>] ? ip_local_deliver_finish+0x0/0x1e9=0D
[<ffffffff81273afa>] ? ip_local_deliver_finish+0x0/0x1e9=0D
[<ffffffff81273c40>] ? ip_local_deliver_finish+0x146/0x1e9=0D
[<ffffffff8127378f>] ? ip_rcv_finish+0x373/0x38d=0D
[<ffffffffa004d95c>] ? bnx2_poll_work+0x954/0xa7e [bnx2]=0D
[<ffffffffa004d95c>] ? bnx2_poll_work+0x954/0xa7e [bnx2]=0D
[<ffffffff8105aeb6>] ? __mod_timer+0x141/0x153=0D
[<ffffffff810964a1>] ? handle_edge_irq+0xdd/0x101=0D
[<ffffffffa004daae>] ? bnx2_poll_msix+0x28/0xa6 [bnx2]=0D
[<ffffffff8125039f>] ? net_rx_action+0xae/0x1c9=0D
[<ffffffff81053d6f>] ? __do_softirq+0xdd/0x1a6=0D
[<ffffffff81011cac>] ? call_softirq+0x1c/0x30=0D
[<ffffffff8101322b>] ? do_softirq+0x3f/0x7c=0D
[<ffffffff81053bdf>] ? irq_exit+0x36/0x76=0D
[<ffffffff81012922>] ? do_IRQ+0xa0/0xb6=0D
[<ffffffff810114d3>] ? ret_from_intr+0x0/0x11=0D
<E0I> [<ffffffffa0135509>] ? acpi_idle_enter_bm+0x27d/0x2af [processor]=
=0D
[<ffffffffa0135509>] ? acpi_idle_enter_bm+0x27d/0x2af=C2=A0[processor]=0D
[<ffffffffa0135502>] ? acpi_idle_enter_bm+0x276/0x2af=C2=A0[processor]=0D
[<ffffffff8123a2c6>] ? cpuidle_idle_call+0x94/0xee=0D
[<ffffffff8100fe97>] ? cpu_idle+0xa2/0xda=0D
[<ffffffff8151c140>] ? early_idt_handler+0x0/0x71=0D
[<ffffffff8151ccdd>] ? start_kernel+0x3dc/0x3e8=0D
[<ffffffff8151c3b7>] ? x86_64_start_kernel+0xf9/0x106=0D
=0D
Kind Regards,=0D
Sascha=0D
=0D
>Gesendet:=C2=A0Dienstag, 04. September 2012 um 14:23 Uhr=0D
>Von:=C2=A0"Eric Dumazet" <eric.dumazet@gmail.com>=0D
>An:=C2=A0smka2012@email.de=0D
>Cc:=C2=A0netdev@vger.kernel.org=0D
>Betreff:=C2=A0Re: Question regarding kernel panic in net/ipv4/tcp_outp=
ut.c=0D
>On Tue, 2012-09-04 at 13:55 +0200, smka2012@email.de wrote:=0D
>> Hi,=0D
>>=0D
>> I recently had a severe issue with multiple servers that stopped=0D
>> working at the same time. By using the stacktrace, I could locate th=
e=0D
>> following line in the tcp_retransmit_skb function of the tcp_output.=
c=0D
>> kernel source that led to a kernel panic on all servers. I am using=0D
>> Debian 6.0 with the kernel version 2.6.32-45.=0D
>>=0D
>> (gdb) list *(tcp_retransmit_skb+0x66)=0D
>> 0x1a93 is in tcp_retransmit_skb (net/ipv4/tcp_output.c:1905).=0D
>> 1900 if (atomic_read(&sk->sk_wmem_alloc) >=0D
>> 1901 min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2),=0D
>> sk->sk_sndbuf))=0D
>> 1902 return -EAGAIN;=0D
>> 1903=0D
>> 1904 if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {=0D
>>=0D
>> --->=0D
>> 1905 if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))=0D
>> 1906 BUG();=0D
>> <---=0D
>>=0D
>> 1907 if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))=
=0D
>> 1908 return -ENOMEM;=0D
>> 1909 }=0D
>>=0D
>> Now I am interested in getting to know what can lead to a situation=0D
>> that the condition in line 1905 evaluates true and why the kernel go=
es=0D
>> into the BUG() function in that case and does not only return an=0D
>> error. All servers reached this line of code. They all were connecte=
d=0D
>> to a switch that broke the same time. However, I cannot say if the=0D
>> switch broke before the servers and eventually affected the servers =
or=0D
>> if the switch was also itself affected by some external event.=0D
>>=0D
>> Thank you very much for your help.=0D
>>=0D
>> Kind Regards,=0D
>> Sascha=0D
>> --=0D
>=0D
>You can see this BUG() as an early notification of a hard to=0D
>debug/diagnose bug.=0D
>=0D
>We shouldnt take this path at all.=0D
>=0D
>If we do, we have an earlier bug that we should fix anyway, because=0D
>machine is going to crash.=0D
>=0D
>It would be nice you sent the stack trace you had.
