From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: Compile-time warnings on mlx4/net-next
Date: Thu, 15 Jan 2015 15:20:47 +0200
Message-ID: <54B7BEAF.6000406@mellanox.com>
References: <54B7BB17.8090308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0063.outbound.protection.outlook.com ([157.56.112.63]:4577
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754471AbbAONlT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 08:41:19 -0500
In-Reply-To: <54B7BB17.8090308@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/15/2015 3:05 PM, Marcelo Ricardo Leitner wrote:
> Hi Or,
>
> Building net-next.git from today, 4e7a84b1a5bc8094522fd11f628b00c4b4e=
78b4d,
> I'm seeing these warnings on mlx4:
>
> drivers/net/ethernet/mellanox/mlx4/fw.c: In function =91mlx4_config_d=
ev_retrieval=92:
> drivers/net/ethernet/mellanox/mlx4/fw.c:2136:12: warning: =91config_d=
ev.rx_checksum_val=92 may be used uninitialized in this function [-Wmay=
be-uninitialized]
>    csum_mask =3D (config_dev.rx_checksum_val >> CONFIG_DEV_RX_CSUM_MO=
DE_PORT2_BIT_OFFSET) &
>              ^
BTW  in net-next.git this is line 2155 .. it's 2136 on net.git
> In file included from include/linux/swab.h:4:0,
>                   from include/uapi/linux/byteorder/little_endian.h:1=
2,
>                   from include/linux/byteorder/little_endian.h:4,
>                   from ./arch/x86/include/uapi/asm/byteorder.h:4,
>                   from include/asm-generic/bitops/le.h:5,
>                   from ./arch/x86/include/asm/bitops.h:504,
>                   from include/linux/bitops.h:36,
>                   from include/linux/kernel.h:10,
>                   from include/linux/skbuff.h:17,
>                   from include/linux/if_ether.h:23,
>                   from include/linux/etherdevice.h:25,
>                   from drivers/net/ethernet/mellanox/mlx4/fw.c:35:
> include/uapi/linux/swab.h:106:23: warning: =91config_dev.vxlan_udp_dp=
ort=92 may be used uninitialized in this function [-Wmaybe-uninitialize=
d]
>    (__builtin_constant_p((__u16)(x)) ? \
>                         ^
> drivers/net/ethernet/mellanox/mlx4/fw.c:2114:25: note: =91config_dev.=
vxlan_udp_dport=92 was declared here
>    struct mlx4_config_dev config_dev;
>                           ^
>
> Do you see them too?

using $ make W=3D1 -j 20 SUBDIRS=3D./drivers/net/ethernet/mellanox/mlx4=
 with=20
gcc 4.8.2 I don't see that, but I'll look there,
thanks for the report.

Or.
