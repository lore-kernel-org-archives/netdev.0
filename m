From: Michal Simek <monstr@monstr.eu>
Subject: Re: Zynq macb
Date: Fri, 14 Mar 2014 06:37:08 +0100
Message-ID: <53229584.7000100@monstr.eu>
References: <c6344e9b-fa32-4313-8950-59030c4bffb8@AM1EHSMHS003.ehs.local> <73734ba5-00d3-445d-8c6f-a1a868cdd537@CH1EHSMHS024.ehs.local>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="7EAmv0r3cX2VDXHVioPQRjD023ftaAehV"
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Punnaiah Choudary Kalluri
	<punnaiah.choudary.kalluri@xilinx.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?UTF-8?B?U8O2cmVuIEJyaW5rbWFubg==?= <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <73734ba5-00d3-445d-8c6f-a1a868cdd537@CH1EHSMHS024.ehs.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--7EAmv0r3cX2VDXHVioPQRjD023ftaAehV
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 03/13/2014 11:33 PM, S=C3=B6ren Brinkmann wrote:
> On Thu, 2014-03-13 at 03:16PM -0700, S=C3=B6ren Brinkmann wrote:
>> Hi Nicolas,
>>
>> I did some testing on the current linux-next tree and ran iperf on Zyn=
q.
>> It seems that network and even the whole system can collapse when doin=
g
>> that.
>> I don't really know what's going on, but once I saw the message:
>> 	"inconsistent Rx descriptor chain"
>> printed twice (system frozen afterwards).
>>
>> I don't know what exactly is going wrong, but suspect something around=

>> memory/DMA. I have no clue whether it makes any sense or not, but I
>> tried using the macb_* functions instead of the gem_* ones (see diff b=
elow).
>> That seems to result in a stable system and working Ethernet.
>=20
> That was a little too early. After roughly 25 minutest the system runs
> into a deadlock:
>   BUG: spinlock lockup suspected on CPU#1, iperf/774
>    lock: 0xeda0366c, .magic: dead4ead, .owner: swapper/0/0, .owner_cpu:=
 0
>   CPU: 1 PID: 774 Comm: iperf Tainted: G        W    3.14.0-rc6-next-20=
140312-xilinx-dirty #41
>   [<c00153c0>] (unwind_backtrace) from [<c0011e70>] (show_stack+0x10/0x=
14)
>   [<c0011e70>] (show_stack) from [<c03d6b50>] (dump_stack+0x80/0xcc)
>   [<c03d6b50>] (dump_stack) from [<c00670ac>] (do_raw_spin_lock+0xd4/0x=
190)
>   [<c00670ac>] (do_raw_spin_lock) from [<c03dc79c>] (_raw_spin_lock_irq=
save+0x58/0x64)
>   [<c03dc79c>] (_raw_spin_lock_irqsave) from [<c02b0810>] (macb_start_x=
mit+0x24/0x2d0)
>   [<c02b0810>] (macb_start_xmit) from [<c0321b10>] (dev_hard_start_xmit=
+0x334/0x470)
>   [<c0321b10>] (dev_hard_start_xmit) from [<c0339aa8>] (sch_direct_xmit=
+0x78/0x2f8)
>   [<c0339aa8>] (sch_direct_xmit) from [<c0321f60>] (__dev_queue_xmit+0x=
314/0x704)
>   [<c0321f60>] (__dev_queue_xmit) from [<c034cb3c>] (ip_finish_output+0=
x6c4/0x894)
>   [<c034cb3c>] (ip_finish_output) from [<c034cf24>] (ip_local_out+0x74/=
0x90)
>   [<c034cf24>] (ip_local_out) from [<c034d340>] (ip_queue_xmit+0x400/0x=
5c4)
>   [<c034d340>] (ip_queue_xmit) from [<c03634b8>] (tcp_transmit_skb+0xa1=
8/0xab0)
>   [<c03634b8>] (tcp_transmit_skb) from [<c035856c>] (tcp_recvmsg+0x92c/=
0xae4)
>   [<c035856c>] (tcp_recvmsg) from [<c03806f0>] (inet_recvmsg+0x1c0/0x1f=
c)
>   [<c03806f0>] (inet_recvmsg) from [<c030769c>] (sock_recvmsg+0x7c/0x98=
)
>   [<c030769c>] (sock_recvmsg) from [<c0309988>] (SyS_recvfrom+0x9c/0x10=
8)
>   [<c0309988>] (SyS_recvfrom) from [<c0309a08>] (sys_recv+0x14/0x18)
>   [<c0309a08>] (sys_recv) from [<c000ea60>] (ret_fast_syscall+0x0/0x48)=


Do you have this change in your tree?
https://github.com/Xilinx/linux-xlnx/commit/1a85939af40acca2bf963407b497c=
c31c303ff3e

I don't think we have sent this to mainline yet.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--7EAmv0r3cX2VDXHVioPQRjD023ftaAehV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlMilYQACgkQykllyylKDCEd7wCeL6u+0XBA6Q/34oByqcQQ63vj
J9sAmwU/OOfvfPKEU3QyJBIhoz1niUpL
=KQgz
-----END PGP SIGNATURE-----

--7EAmv0r3cX2VDXHVioPQRjD023ftaAehV--
