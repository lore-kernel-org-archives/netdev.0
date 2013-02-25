From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net-next 2/2] Revert
 "ip_gre: propogate target device GSO capability to the tunnel device"
Date: Mon, 25 Feb 2013 11:38:36 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1C01B72C@SJEXCHMB06.corp.ad.broadcom.com>
References: <1361772312-1698-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Pravin B Shelar" <pshelar@nicira.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2632 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758285Ab3BYLjC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 06:39:02 -0500
In-Reply-To: <1361772312-1698-1-git-send-email-pshelar@nicira.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Pravin B Shelar [mailto:pshelar@nicira.com]
> Sent: Monday, February 25, 2013 8:05 AM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org; Dmitry Kravkov; Pravin B Shelar
> Subject: [PATCH net-next 2/2] Revert "ip_gre: propogate target device GSO capability to the tunnel device"
> 
> This reverts commit eb6b9a8cad65e820b145547844b108117cece3a0.
> 
> Above commit limits GSO capability of gre device to just TSO, but
> software GRE-GSO is capable of handling all GSO capabilities.
> 
> This patch also fixes following panic which reverted commit introduced:-
> 
> BUG: unable to handle kernel NULL pointer dereference at 00000000000000a2
> IP: [<ffffffffa0680fd1>] ipgre_tunnel_bind_dev+0x161/0x1f0 [ip_gre]
> PGD 42bc19067 PUD 42bca9067 PMD 0
> Oops: 0000 [#1] SMP
> Pid: 2636, comm: ip Tainted: GF            3.8.0+ #83 Dell Inc. PowerEdge R620/0KCKR5
> RIP: 0010:[<ffffffffa0680fd1>]  [<ffffffffa0680fd1>] ipgre_tunnel_bind_dev+0x161/0x1f0 [ip_gre]
> RSP: 0018:ffff88042bfcb708  EFLAGS: 00010246
> RAX: 00000000000005b6 RBX: ffff88042d2fa000 RCX: 0000000000000044
> RDX: 0000000000000018 RSI: 0000000000000078 RDI: 0000000000000060
> RBP: ffff88042bfcb748 R08: 0000000000000018 R09: 000000000000000c
> R10: 0000000000000020 R11: 000000000101010a R12: ffff88042d2fa800
> R13: 0000000000000000 R14: ffff88042d2fa800 R15: ffff88042cd7f650
> FS:  00007fa784f55700(0000) GS:ffff88043fd20000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000000000a2 CR3: 000000042d8b9000 CR4: 00000000000407e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process ip (pid: 2636, threadinfo ffff88042bfca000, task ffff88042d142a80)
> Stack:
>  0000000100000000 002f000000000000 0a01010100000000 000000000b010101
>  ffff88042d2fa800 ffff88042d2fa000 ffff88042bfcb858 ffff88042f418c00
>  ffff88042bfcb798 ffffffffa068199a ffff88042bfcb798 ffff88042d2fa830
> Call Trace:
>  [<ffffffffa068199a>] ipgre_newlink+0xca/0x160 [ip_gre]
>  [<ffffffff8143b692>] rtnl_newlink+0x532/0x5f0
>  [<ffffffff8143b2fc>] ? rtnl_newlink+0x19c/0x5f0
>  [<ffffffff81438978>] rtnetlink_rcv_msg+0x2c8/0x340
>  [<ffffffff814386b0>] ? rtnetlink_rcv+0x40/0x40
>  [<ffffffff814560f9>] netlink_rcv_skb+0xa9/0xd0
>  [<ffffffff81438695>] rtnetlink_rcv+0x25/0x40
>  [<ffffffff81455ddc>] netlink_unicast+0x1ac/0x230
>  [<ffffffff81456a45>] netlink_sendmsg+0x265/0x380
>  [<ffffffff814138c0>] sock_sendmsg+0xb0/0xe0
>  [<ffffffff8141141e>] ? move_addr_to_kernel+0x4e/0x90
>  [<ffffffff81420445>] ? verify_iovec+0x85/0xf0
>  [<ffffffff81414ffd>] __sys_sendmsg+0x3fd/0x420
>  [<ffffffff8114b701>] ? handle_mm_fault+0x251/0x3b0
>  [<ffffffff8114f39f>] ? vma_link+0xcf/0xe0
>  [<ffffffff81415239>] sys_sendmsg+0x49/0x90
>  [<ffffffff814ffd19>] system_call_fastpath+0x16/0x1b
> 
> CC: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  net/ipv4/ip_gre.c |   10 ++--------
>  1 files changed, 2 insertions(+), 8 deletions(-)
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 9b4996d..1517b6f 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -1105,14 +1105,8 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
>  	tunnel->hlen = addend;
>  	/* TCP offload with GRE SEQ is not supported. */
>  	if (!(tunnel->parms.o_flags & GRE_SEQ)) {
> -		/* device supports enc gso offload*/
> -		if (tdev->hw_enc_features & NETIF_F_GRE_GSO) {
> -			dev->features		|= NETIF_F_TSO;
> -			dev->hw_features	|= NETIF_F_TSO;
> -		} else {
> -			dev->features		|= NETIF_F_GSO_SOFTWARE;
> -			dev->hw_features	|= NETIF_F_GSO_SOFTWARE;
> -		}
> +		dev->features		|= NETIF_F_GSO_SOFTWARE;
> +		dev->hw_features	|= NETIF_F_GSO_SOFTWARE;
>  	}
> 
>  	return mtu;

Acked-by: Dmitry Kravkov <dmitry@broadcom.com>
