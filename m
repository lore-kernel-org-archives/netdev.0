From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4] e1000e: Calculate the desc_len based on adapter type
Date: Thu, 22 Aug 2013 22:26:52 +0800
Message-ID: <20130822142652.GA6268@weiyang.vnet.ibm.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1369037707-27026-4-git-send-email-weiyang@linux.vnet.ibm.com>
 <CAL3LdT4K03_4sWWFuTer0TU4nY_sqbSyjK6ETxF14kijZzmkgQ@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:39323 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533Ab3HVO1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 10:27:02 -0400
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Fri, 23 Aug 2013 00:18:33 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id B59112BB0053
	for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 00:26:58 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7MEAwFq65274026
	for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 00:10:59 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7MEQu68003713
	for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 00:26:57 +1000
Content-Disposition: inline
In-Reply-To: <CAL3LdT4K03_4sWWFuTer0TU4nY_sqbSyjK6ETxF14kijZzmkgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

Thanks for letting me know this.

Setting MTU is not tested, maybe this patch introduce some problem in t=
his
case. Sorry for breaking your driver :-(

On Thu, Aug 22, 2013 at 03:57:24AM -0700, Jeff Kirsher wrote:
>Validation ran into issues with this patch and because we could not ap=
ply patch
>4 in this series without patch 3, I have had to drop patch 3 &amp; 4 f=
rom my
>queue.
>
>Here is what validation had to say about this patch...
>
>Aaron Brown wrote:
>This patch introduces a call trace when the interface is up and then t=
he mtu is
>set over 1500, or if the mtu is set above 1500 when the interface is d=
own,
>the call trace appears when the interface is brought up.  The trace is=
 captured
>to demsg and /var/log/messages:
>---------------------------------------------------
>17:14:52 u1307 kernel: Call Trace:
>17:14:52 u1307 kernel: [<ffffffff813ffaeb>] dump_stack+0x19/0x1e
>17:14:52 u1307 kernel: [<ffffffff8104ae80>] __might_sleep+0xe2/0xe4
>17:14:52 u1307 kernel: [<ffffffff81400e63>] down_read+0x1f/0x31
>17:14:52 u1307 kernel: [<ffffffff8102c1b7>] exit_mm+0x3a/0x164
>17:14:52 u1307 kernel: [<ffffffff8102da09>] do_exit+0x1ef/0x2f7
>17:14:52 u1307 kernel: [<ffffffff81403bce>] oops_end+0x8f/0x94
>17:14:52 u1307 kernel: [<ffffffff81020ca5>] no_context+0x1a4/0x1b3
>17:14:52 u1307 kernel: [<ffffffff81020e6c>] __bad_area_nosemaphore+0x1=
b8/0x1d8
>17:14:52 u1307 kernel: [<ffffffff81020e9a>] bad_area_nosemaphore+0xe/0=
x10
>17:14:52 u1307 kernel: [<ffffffff81405a69>] __do_page_fault+0x44f/0x48=
e
>17:14:52 u1307 kernel: [<ffffffff81004494>] ? print_context_stack+0xa2=
/0xbe
>17:14:52 u1307 kernel: [<ffffffff81003488>] ? dump_trace+0x282/0x2aa
>17:14:52 u1307 kernel: [<ffffffff81402bf0>] ? _raw_spin_unlock_irqrest=
ore+0x1d/
>0x3a
>17:14:52 u1307 kernel: [<ffffffff81405ab1>] do_page_fault+0x9/0xb
>17:14:52 u1307 kernel: [<ffffffff814031e2>] page_fault+0x22/0x30
>17:14:52 u1307 kernel: [<ffffffffa00238ef>] ? e1000_alloc_rx_buffers_p=
s+0x1d9/
>0x421 [e1000e]
>17:14:52 u1307 kernel: [<ffffffffa00238a3>] ? e1000_alloc_rx_buffers_p=
s+0x18d/
>0x421 [e1000e]
>17:14:52 u1307 kernel: [<ffffffffa0022bd6>] e1000_configure+0xe7/0xf0 =
[e1000e]
>17:14:52 u1307 kernel: [<ffffffffa0022bee>] e1000e_up+0xf/0xe7 [e1000e=
]
>17:14:52 u1307 kernel: [<ffffffffa00282da>] e1000_change_mtu+0x142/0x1=
62
>[e1000e]
>17:14:52 u1307 kernel: [<ffffffff8135a98b>] dev_set_mtu+0x3f/0x5e
>17:14:52 u1307 kernel: [<ffffffff81369280>] dev_ifsioc+0xec/0x329
>17:14:52 u1307 kernel: [<ffffffff81369a24>] dev_ioctl+0x309/0x3bd
>17:14:52 u1307 kernel: [<ffffffff81348035>] sock_ioctl+0x21e/0x22b
>17:14:52 u1307 kernel: [<ffffffff810ce1b4>] do_vfs_ioctl+0x28e/0x2aa
>17:14:52 u1307 kernel: [<ffffffff810ce217>] SyS_ioctl+0x47/0x69
>17:14:52 u1307 kernel: [<ffffffff81407b12>] system_call_fastpath+0x16/=
0x1b
>17:14:52 u1307 kernel: ------------[ cut here ]------------
>17:14:52 u1307 kernel: WARNING: at kernel/softirq.c:160
>local_bh_enable_ip+0x3c/0x9a()
>17:14:52 u1307 kernel: Modules linked in: bridge stp llc nfsd lockd ex=
portfs
>sunrpc e1000e ptp pps_core
>17:14:52 u1307 kernel: CPU: 6 PID: 5289 Comm: ifconfig Tainted: G     =
 D
>3.10.0-rc1_net-next_e1000e_2850dce_regress-11638-gb471f26 #5
>17:14:52 u1307 kernel: Hardware name: Supermicro X9SCL/X9SCM/X9SCL/X9S=
CM, BIOS
>2.0b 09/17/2012
>17:14:52 u1307 kernel: ffffffff816e7023 ffff880222b2b808 ffffffff813ff=
aeb
>ffff880222b2b848
>17:14:52 u1307 kernel: ffffffff810287e6 ffffffff81a25188 0000000000000=
000
>ffff880221f91bc0
>17:14:52 u1307 kernel: ffff880221f91dd8 ffff880221f91f70 0000000000000=
000
>ffff880222b2b858
>----------------------------------------------------------------------=
---------
>
>The system remains up but unstable, attempts to access the network int=
erface
>causes a hang, attempts to login to a new session on the console somet=
imes
>hang.
>This is happening with all adapters I've tried so far, 82579, 82578, 8=
2574,
>ich10, ich9...
>
>
>On Mon, May 20, 2013 at 1:15 AM, Wei Yang <weiyang@linux.vnet.ibm.com>=
 wrote:
>     desc_len represents the size of descriptor in rx_ring. There are =
two
>     kinds of
>     rx descriptors, e1000_rx_desc_packet_split(32 byte) and
>     e1000_rx_desc_extended(16 byte). Different adapter will use diffe=
rent
>     rx
>     descriptors.
>
>     When allocating the dma space for this descriptor in current
>     implementation,
>     the code ignore the descriptor type and take it as
>     e1000_rx_desc_packet_split
>     in any case. This behavior will not effect the function, but will
>     require
>     double size of dma space.
>
>     This patch will calculate the desc_len based on the adapter type.
>
>     Tested on T420, which use e1000_rx_desc_extended and works fine.
>
>     Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>     ---
>     =C2=A0drivers/net/ethernet/intel/e1000e/netdev.c | =C2=A0 =C2=A07=
 ++++++-
>     =C2=A01 files changed, 6 insertions(+), 1 deletions(-)
>
>     diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers=
/
>     net/ethernet/intel/e1000e/netdev.c
>     index 5cb8321..a2e8a53 100644
>     --- a/drivers/net/ethernet/intel/e1000e/netdev.c
>     +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
>     @@ -2364,7 +2364,12 @@ int e1000e_setup_rx_resources(struct
>     e1000_ring *rx_ring)
>     =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 goto err_pages;
>     =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>
>     - =C2=A0 =C2=A0 =C2=A0 desc_len =3D sizeof(union e1000_rx_desc_pa=
cket_split);
>     + =C2=A0 =C2=A0 =C2=A0 if (adapter->rx_ps_pages) {
>     + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* this is a 3=
2 byte descriptor */
>     + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 desc_len =3D s=
izeof(union
>     e1000_rx_desc_packet_split);
>     + =C2=A0 =C2=A0 =C2=A0 } else {
>     + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 desc_len =3D s=
izeof(union
>     e1000_rx_desc_extended);
>     + =C2=A0 =C2=A0 =C2=A0 }
>
>     =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Round up to nearest 4K */
>     =C2=A0 =C2=A0 =C2=A0 =C2=A0 rx_ring->size =3D rx_ring->count * de=
sc_len;
>     --
>     1.7.5.4
>
>     --
>     To unsubscribe from this list: send the line &quot;unsubscribe
>     netdev&quot; in
>     the body of a message to majordomo@vger.kernel.org
>     More majordomo info at =C2=A0http://vger.kernel.org/majordomo-inf=
o.html
>
>
>
>--
>Cheers,
>Jeff

--=20
Richard Yang
Help you, Help me
