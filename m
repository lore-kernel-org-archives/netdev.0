From: =?ISO-8859-1?Q?S=E9guier_R=E9gis?= <rseguier@e-teleport.net>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
 MTU change
Date: Mon, 16 Jun 2008 23:25:54 +0200
Message-ID: <4856DA62.7080803@e-teleport.net>
References: <20080531184615.350bac00@infradead.org> <20080603134019.df2f51d4.akpm@linux-foundation.org> <20080603215155.GA9712@electric-eye.fr.zoreil.com> <20080604215909.GA17446@electric-eye.fr.zoreil.com> <20080614212341.GA12976@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Arjan van de Ven <arjan@infradead.org>, alan@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.e-teleport.net ([213.190.83.68]:44180 "EHLO
	mail.imsnet.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754081AbYFPVZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 17:25:55 -0400
In-Reply-To: <20080614212341.GA12976@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rancois Romieu a =E9crit :
> Francois Romieu <romieu@fr.zoreil.com> :
> [...context available from http://lkml.org/lkml/2008/5/31/251 ...]
>
> R=E9gis, I need your help.
>
> Can you give the patchkit below a try and check if the change of mtu
> works correctly ?
>
> http://userweb.kernel.org/~romieu/via-velocity/2.6.26-rc6/
>
> or:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git v=
elocity
>
>  =20
The mtu change doesn't work :

Jun 16 23:22:34 apollo kernel: ------------[ cut here ]------------
Jun 16 23:22:34 apollo kernel: WARNING: at arch/x86/kernel/pci-dma.c:48=
2=20
dma_free_coherent+0x3a/0x9c()
Jun 16 23:22:34 apollo kernel: Pid: 1527, comm: ip Tainted: G        W=20
2.6.26-rc6EPIA_SN_VB7001 #3
Jun 16 23:22:34 apollo kernel:  [<c0115fe5>] warn_on_slowpath+0x3b/0x5f
Jun 16 23:22:34 apollo kernel:  [<c0133940>]=20
get_page_from_freelist+0x24a/0x36f
Jun 16 23:22:34 apollo kernel:  [<c012d86b>] handle_IRQ_event+0x1a/0x3f
Jun 16 23:22:34 apollo kernel:  [<c0241193>] velocity_free_rd_ring+0xa5=
/0xb6
Jun 16 23:22:34 apollo kernel:  [<c0144752>] kfree+0x6a/0x72
Jun 16 23:22:34 apollo kernel:  [<c0241193>] velocity_free_rd_ring+0xa5=
/0xb6
Jun 16 23:22:34 apollo kernel:  [<c0105816>] dma_free_coherent+0x3a/0x9=
c
Jun 16 23:22:34 apollo kernel:  [<c02411eb>]=20
velocity_free_dma_rings+0x47/0x4d
Jun 16 23:22:34 apollo kernel:  [<c024225b>] velocity_change_mtu+0xf6/0=
x157
Jun 16 23:22:34 apollo kernel:  [<c02856c4>] dev_set_mtu+0x2a/0x4f
Jun 16 23:22:34 apollo kernel:  [<c0286642>] dev_ioctl+0x4ab/0x530
Jun 16 23:22:34 apollo kernel:  [<c012e4cb>] handle_fasteoi_irq+0x74/0x=
77
Jun 16 23:22:34 apollo kernel:  [<c010479b>] do_IRQ+0x50/0x60
Jun 16 23:22:34 apollo kernel:  [<c027d785>] sock_ioctl+0x0/0x177
Jun 16 23:22:34 apollo kernel:  [<c01032eb>] common_interrupt+0x23/0x28
Jun 16 23:22:34 apollo kernel:  [<c027d785>] sock_ioctl+0x0/0x177
Jun 16 23:22:34 apollo kernel:  [<c0150b4a>] vfs_ioctl+0x16/0x48
Jun 16 23:22:34 apollo kernel:  [<c0150d5a>] do_vfs_ioctl+0x1de/0x1f1
Jun 16 23:22:34 apollo kernel:  [<c0150dae>] sys_ioctl+0x41/0x5b
Jun 16 23:22:34 apollo kernel:  [<c010291d>] sysenter_past_esp+0x6a/0x9=
1
Jun 16 23:22:34 apollo kernel:  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Jun 16 23:22:34 apollo kernel: ---[ end trace 17457a054a24b83c ]---


--=20
R=E9gis
