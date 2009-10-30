From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/af_inet.c:154 inet_sock_destruct
Date: Fri, 30 Oct 2009 10:41:25 +0100
Message-ID: <4AEAB4C5.60907@gmail.com>
References: <38b2ab8a0909290109m3f82c161j4fb0f1266152877e@mail.gmail.com>	 <4AC1D0F5.4050709@gmail.com> <38b2ab8a0910300144i7a3c190fi9aa3d079c9cdb754@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Francis Moreau <francis.moro@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756723AbZJ3JlZ@vger.kernel.org>
In-Reply-To: <38b2ab8a0910300144i7a3c190fi9aa3d079c9cdb754@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rancis Moreau a =E9crit :
> Hello Eric,
>=20
> It seems I still have a related bug, please have a look to the follow=
ing oops.
>=20
> This happened on a 2.6.32-rc5 where your patch is included.
>=20
> [107304.558821] nfsd: last server has exited, flushing export cache
> [107304.558848] ------------[ cut here ]------------
> [107304.558858] WARNING: at net/ipv4/af_inet.c:153
> inet_sock_destruct+0x161/0x17c()
> [107304.558862] Hardware name: P5K-VM
> [107304.558865] Modules linked in: kvm_intel kvm jfs loop nfsd lockd
> nfs_acl auth_rpcgss exportfs sunrpc [last unloaded: microcode]
> [107304.558889] Pid: 8198, comm: nfsd Tainted: G   M       2.6.32-rc5=
 #25
> [107304.558892] Call Trace:
> [107304.558899]  [<ffffffff81429f19>] ? inet_sock_destruct+0x161/0x17=
c
> [107304.558907]  [<ffffffff810487e9>] warn_slowpath_common+0x7c/0xa9
> [107304.558914]  [<ffffffff8104882a>] warn_slowpath_null+0x14/0x16
> [107304.558920]  [<ffffffff81429f19>] inet_sock_destruct+0x161/0x17c
> [107304.558927]  [<ffffffff813c8741>] __sk_free+0x23/0xe7
> [107304.558933]  [<ffffffff813c8881>] sk_free+0x1f/0x21
> [107304.558939]  [<ffffffff813c894b>] sk_common_release+0xc8/0xcd
> [107304.558944]  [<ffffffff81420b59>] udp_lib_close+0xe/0x10
> [107304.558951]  [<ffffffff814299bf>] inet_release+0x55/0x5c
> [107304.558957]  [<ffffffff813c5aa9>] sock_release+0x1f/0x71
> [107304.558962]  [<ffffffff813c5b22>] sock_close+0x27/0x2b
> [107304.558968]  [<ffffffff810eb60f>] __fput+0xfb/0x1c0
> [107304.558973]  [<ffffffff810eb6f1>] fput+0x1d/0x1f
> [107304.558995]  [<ffffffffa0013e23>] svc_sock_free+0x40/0x56 [sunrpc=
]
> [107304.559018]  [<ffffffffa001f392>] svc_xprt_free+0x43/0x53 [sunrpc=
]
> [107304.559038]  [<ffffffffa001f34f>] ? svc_xprt_free+0x0/0x53 [sunrp=
c]
> [107304.559048]  [<ffffffff811d9275>] kref_put+0x43/0x4f
> [107304.559069]  [<ffffffffa001e67a>] svc_close_xprt+0x55/0x5e [sunrp=
c]
> [107304.559088]  [<ffffffffa001e6d3>] svc_close_all+0x50/0x69 [sunrpc=
]
> [107304.559107]  [<ffffffffa0012a2b>] svc_destroy+0x9e/0x142 [sunrpc]
> [107304.559126]  [<ffffffffa0012b88>] svc_exit_thread+0xb9/0xc2 [sunr=
pc]
> [107304.559138]  [<ffffffffa008981b>] ? nfsd+0x0/0x13f [nfsd]
> [107304.559149]  [<ffffffffa0089940>] nfsd+0x125/0x13f [nfsd]
> [107304.559157]  [<ffffffff810685e3>] kthread+0x82/0x8a
> [107304.559164]  [<ffffffff8100c13a>] child_rip+0xa/0x20
> [107304.559172]  [<ffffffff8100baad>] ? restore_args+0x0/0x30
> [107304.559179]  [<ffffffff81068561>] ? kthread+0x0/0x8a
> [107304.559185]  [<ffffffff8100c130>] ? child_rip+0x0/0x20
> [107304.559191] ---[ end trace c107131f4762168c ]---
> [107304.927931] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 stat=
e
> recovery directory
> [107304.932765] NFSD: starting 90-second grace period
>=20

Thanks Francis, I think I found the problem.

I am preparing a patch, test it, and submit it in couple of hours
