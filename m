From: "Parag Warudkar" <parag.lkml@gmail.com>
Subject: Re: PROBLEM: linksys USB1000linksys, asix driver (2.6.26.5)
Date: Mon, 6 Oct 2008 16:02:17 -0400
Message-ID: <f7848160810061302n49eead0bo337c2d9bde5ab214@mail.gmail.com>
References: <Pine.LNX.4.64.0810062130180.23753@ares.softexpert.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "=?ISO-8859-1?Q?Reigo_K=FCngas?=" <reigo@itx.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:30950 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798AbYJFUCR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 16:02:17 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1568586wah.21
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2008 13:02:17 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810062130180.23753@ares.softexpert.eu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ CC netdev for network related things ]

On Mon, Oct 6, 2008 at 3:19 PM, Reigo K=FCngas <reigo@itx.ee> wrote:
> Hi,
>
> I have problem with linksys usb1000 gigabit network adapter - interfa=
ce is
> stop working after random period. Reloading asix driver will restore
> interface work.
>

It is hitting the below warning -

1451        if (WARN_ON(skb->ip_summed !=3D CHECKSUM_PARTIAL)) {
1452                if (skb_header_cloned(skb) &&
1453                    (err =3D pskb_expand_head(skb, 0, 0, GFP_ATOMIC=
)))
1454                        return ERR_PTR(err);
1455        }

Which seems to be related to GSO - so what happens if you disable GSO
(ethtool -K ethX gso off )?
Does it work better then?

Also, not necessarily related to the issue at hand but the if()
portion of the above code looks somewhat problematic in that if
skb_header_cloned returns 0 pksb_expand_head will never be called we
will return ERR_PTR() of uninitialized value. Goes to check what
callers do with the return value..

Parag

> usbcore: deregistering interface driver asix
> eth2: unregister 'asix' usb-0000:00:03.2-1, ASIX AX88178 USB 2.0 Ethe=
rnet
> eth2: register 'asix' at usb-0000:00:03.2-1, ASIX AX88178 USB 2.0 Eth=
ernet,
> 00:12:17:f2:2b:c4
> usbcore: registered new interface driver asix
> eth2: link down
> ADDRCONF(NETDEV_UP): eth2: link is not ready
> ADDRCONF(NETDEV_CHANGE): eth2: link becomes ready
> eth2: link up, 1000Mbps, full-duplex, lpa 0xC1E1
> eth2: no IPv6 routers present
> TCP: Treason uncloaked! Peer 217.228.138.121:2126/8080 shrinks window
> 2829308322:2829321390. Repaired.
> php[5684]: segfault at 7fffd5524f10 ip 56c6a5 sp 7fffd5524ec0 error 6=
 in
> php[400000+2a5000]
> TCP: Treason uncloaked! Peer 88.196.248.115:63583/8080 shrinks window
> 3604724912:3604728120. Repaired.
> ------------[ cut here ]------------
> WARNING: at net/core/dev.c:1451 skb_gso_segment+0x83/0x1b4()
> Modules linked in: asix xfs nfsd lockd nfs_acl auth_rpcgss exportfs f=
use
> sunrpc ipt_REJECT xt_multiport xt_state xt_tcpudp ipt_REDIRECT
> iptable_mangle iptable_nat nf_nat iptable_filter ip_vs_ftp ip_vs
> nf_conntrack_ftp nf_conntrack_ipv4 nf_conntrack ipv6 ip_tables x_tabl=
es
> rtc_cmos pcspkr button tg3 rtc_core i2c_piix4 usbnet k8temp rtc_lib e=
100
> i2c_core mii hwmon uhci_hcd ohci_hcd ehci_hcd [last unloaded: asix]
> Pid: 0, comm: swapper Not tainted 2.6.26.5 #1
>
> Call Trace:
>  <IRQ>  [<ffffffff80231fbf>] warn_on_slowpath+0x58/0x94
>  [<ffffffffa00fc8f2>] ? :nf_nat:tcp_manip_pkt+0xcc/0xde
>  [<ffffffffa00fb267>] ? :nf_nat:manip_pkt+0x85/0xf8
>  [<ffffffff80435580>] ? xfrm_lookup+0x11/0x2e
>  [<ffffffff803dedcc>] skb_gso_segment+0x83/0x1b4
>  [<ffffffff803df083>] dev_hard_start_xmit+0x186/0x245
>  [<ffffffff803edbb7>] __qdisc_run+0xd5/0x1d6
>  [<ffffffff803df401>] dev_queue_xmit+0x1b1/0x2c8
>  [<ffffffff80400ce5>] ? ip_finish_output+0x0/0x241
>  [<ffffffff80400ee4>] ip_finish_output+0x1ff/0x241
>  [<ffffffff80400fc1>] ip_output+0x9b/0xa0
>  [<ffffffff80400120>] ip_local_out+0x20/0x24
>  [<ffffffff8040094b>] ip_queue_xmit+0x2c9/0x31f
>  [<ffffffff803d99c3>] ? skb_release_data+0xc6/0xcb
>  [<ffffffff803d972e>] ? __kfree_skb+0x74/0x78
>  [<ffffffff80410cf9>] tcp_transmit_skb+0x6a1/0x6e4
>  [<ffffffff80413677>] __tcp_push_pending_frames+0x745/0x85b
>  [<ffffffff803d99c3>] ? skb_release_data+0xc6/0xcb
>  [<ffffffff8040f44d>] tcp_rcv_established+0x11d/0xb68
>  [<ffffffff80415a75>] tcp_v4_do_rcv+0x31/0x1d6
>  [<ffffffff803e9b8c>] ? sk_filter+0x81/0x8d
>  [<ffffffff80416077>] tcp_v4_rcv+0x45d/0x6d0
>  [<ffffffff803fc64a>] ip_local_deliver_finish+0x124/0x1f9
>  [<ffffffff803fc791>] ip_local_deliver+0x72/0x7a
>  [<ffffffff803fc26d>] ip_rcv_finish+0x305/0x32a
>  [<ffffffff80415a75>] ? tcp_v4_do_rcv+0x31/0x1d6
>  [<ffffffff803fc4f0>] ip_rcv+0x25e/0x294
>  [<ffffffff803dea37>] netif_receive_skb+0x32d/0x34f
>  [<ffffffffa00591ee>] :tg3:tg3_poll+0x782/0xa35
>  [<ffffffff803fc26d>] ? ip_rcv_finish+0x305/0x32a
>  [<ffffffff803dd63e>] net_rx_action+0x7a/0x12e
>  [<ffffffff8023702a>] __do_softirq+0x66/0xd3
>  [<ffffffff8020d11c>] call_softirq+0x1c/0x28
>  [<ffffffff8020ec34>] do_softirq+0x34/0x72
>  [<ffffffff80236e0e>] irq_exit+0x3f/0x80
>  [<ffffffff8020ef1c>] do_IRQ+0x145/0x167
>  [<ffffffff8020a000>] ? default_idle+0x0/0x40
>  [<ffffffff8020a000>] ? default_idle+0x0/0x40
>  [<ffffffff8020c4a1>] ret_from_intr+0x0/0xa
>  <EOI>  [<ffffffff8020a02b>] ? default_idle+0x2b/0x40
>  [<ffffffff8020b043>] ? enter_idle+0x22/0x24
>  [<ffffffff8020b0bd>] ? cpu_idle+0x78/0xc0
>  [<ffffffff80454405>] ? start_secondary+0x15a/0x15e
>
