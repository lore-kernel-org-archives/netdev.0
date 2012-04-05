From: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH v2] phonet: Check input from user before allocating
Date: Thu, 5 Apr 2012 22:14:54 +0300
Message-ID: <201204052214.55669.remi@remlab.net>
References: <1333663665-3999-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi.denis-courmont@nokia.com, davem@davemloft.net,
	davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oyp.chewa.net ([91.121.6.101]:54391 "EHLO oyp.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754730Ab2DETO6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 15:14:58 -0400
In-Reply-To: <1333663665-3999-1-git-send-email-levinsasha928@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 6 avril 2012 01:07:45 Sasha Levin, vous avez =E9crit :
> A phonet packet is limited to USHRT_MAX bytes, this is never checked =
during
> tx which means that the user can specify any size he wishes, and the =
kernel
> will attempt to allocate that size.
>=20
> In the good case, it'll lead to the following warning, but it may als=
o
> cause the kernel to kick in the OOM and kill a random task on the ser=
ver.
>=20
> [ 8921.744094] WARNING: at mm/page_alloc.c:2255
> __alloc_pages_slowpath+0x65/0x730() [ 8921.749770] Pid: 5081, comm:
> trinity Tainted: G        W    3.4.0-rc1-next-20120402-sasha #46 [
> 8921.756672] Call Trace:
> [ 8921.758185]  [<ffffffff810b2ba7>] warn_slowpath_common+0x87/0xb0
> [ 8921.762868]  [<ffffffff810b2be5>] warn_slowpath_null+0x15/0x20
> [ 8921.765399]  [<ffffffff8117eae5>] __alloc_pages_slowpath+0x65/0x73=
0
> [ 8921.769226]  [<ffffffff81179c8a>] ? zone_watermark_ok+0x1a/0x20
> [ 8921.771686]  [<ffffffff8117d045>] ? get_page_from_freelist+0x625/0=
x660
> [ 8921.773919]  [<ffffffff8117f3a8>] __alloc_pages_nodemask+0x1f8/0x2=
40
> [ 8921.776248]  [<ffffffff811c03e0>] kmalloc_large_node+0x70/0xc0
> [ 8921.778294]  [<ffffffff811c4bd4>] __kmalloc_node_track_caller+0x34=
/0x1c0
> [ 8921.780847]  [<ffffffff821b0e3c>] ? sock_alloc_send_pskb+0xbc/0x26=
0
> [ 8921.783179]  [<ffffffff821b3c65>] __alloc_skb+0x75/0x170
> [ 8921.784971]  [<ffffffff821b0e3c>] sock_alloc_send_pskb+0xbc/0x260
> [ 8921.787111]  [<ffffffff821b002e>] ? release_sock+0x7e/0x90
> [ 8921.788973]  [<ffffffff821b0ff0>] sock_alloc_send_skb+0x10/0x20
> [ 8921.791052]  [<ffffffff824cfc20>] pep_sendmsg+0x60/0x380
> [ 8921.792931]  [<ffffffff824cb4a6>] ? pn_socket_bind+0x156/0x180
> [ 8921.794917]  [<ffffffff824cb50f>] ? pn_socket_autobind+0x3f/0x90
> [ 8921.797053]  [<ffffffff824cb63f>] pn_socket_sendmsg+0x4f/0x70
> [ 8921.798992]  [<ffffffff821ab8e7>] sock_aio_write+0x187/0x1b0
> [ 8921.801395]  [<ffffffff810e325e>] ? sub_preempt_count+0xae/0xf0
> [ 8921.803501]  [<ffffffff8111842c>] ? __lock_acquire+0x42c/0x4b0
> [ 8921.805505]  [<ffffffff821ab760>] ? __sock_recv_ts_and_drops+0x140=
/0x140
> [ 8921.807860]  [<ffffffff811e07cc>] do_sync_readv_writev+0xbc/0x110
> [ 8921.809986]  [<ffffffff811958e7>] ? might_fault+0x97/0xa0
> [ 8921.811998]  [<ffffffff817bd99e>] ? security_file_permission+0x1e/=
0x90
> [ 8921.814595]  [<ffffffff811e17e2>] do_readv_writev+0xe2/0x1e0
> [ 8921.816702]  [<ffffffff810b8dac>] ? do_setitimer+0x1ac/0x200
> [ 8921.818819]  [<ffffffff810e2ec1>] ? get_parent_ip+0x11/0x50
> [ 8921.820863]  [<ffffffff810e325e>] ? sub_preempt_count+0xae/0xf0
> [ 8921.823318]  [<ffffffff811e1926>] vfs_writev+0x46/0x60
> [ 8921.825219]  [<ffffffff811e1a3f>] sys_writev+0x4f/0xb0
> [ 8921.827127]  [<ffffffff82658039>] system_call_fastpath+0x16/0x1b
> [ 8921.829384] ---[ end trace dffe390f30db9eb7 ]---
>=20
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

> ---
>  net/phonet/pep.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/phonet/pep.c b/net/phonet/pep.c
> index 9f60008..caee99e 100644
> --- a/net/phonet/pep.c
> +++ b/net/phonet/pep.c
> @@ -1130,6 +1130,9 @@ static int pep_sendmsg(struct kiocb *iocb, stru=
ct
> sock *sk, int flags =3D msg->msg_flags;
>  	int err, done;
>=20
> +	if (len > USHRT_MAX)
> +		return -EMSGSIZE;
> +
>  	if ((msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR|MSG_NOSIGNAL|
>  				MSG_CMSG_COMPAT)) ||
>  			!(msg->msg_flags & MSG_EOR))


--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
