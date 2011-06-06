From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Mon, 6 Jun 2011 11:32:14 -0400
Message-ID: <20110606153213.GC1000@hmsreliant.think-freely.org>
References: <4DE93422.3070000@ahsoftware.de>
 <20110606111507.GA1000@hmsreliant.think-freely.org>
 <4DECBEA3.6070408@ahsoftware.de>
 <1307362358.3098.6.camel@edumazet-laptop>
 <4DECCCC0.70905@ahsoftware.de>
 <1307366166.3098.15.camel@edumazet-laptop>
 <4DECD657.9010807@ahsoftware.de>
 <1307370363.3098.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Holler <holler@ahsoftware.de>,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1307370363.3098.37.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2011 at 04:26:03PM +0200, Eric Dumazet wrote:
> From: Alexander Holler <holler@ahsoftware.de>
>=20
> Le lundi 06 juin 2011 =E0 15:29 +0200, Alexander Holler a =E9crit :
> > > Nice, now please submit a patch with 0972ddb237 as a guideline.
> > >
> > > BTW, you could also check other struct dst_ops methods for
> > > bridge/netfilter:
> >=20
> > Sorry, but I prefer to submit patches I understand by myself and fo=
r=20
> > stuff I know something about. The patch in my first mail was just m=
eant=20
> > as a quick fix (which seemed to work here).
> >=20
> > So even if I might be able to construct a working patch using commi=
t=20
> > 0972ddb237, I don't think I should do that.
>=20
> OK, I'll do it for you then, I am surprised you dont understand my
> review / suggestion.
>=20
> One patch submitter is supposed to followup and send a new version to
> take into account reviews/comments, not wait that eventually everybod=
y
> says "OK, lets take it as is"
>=20
>=20
> [PATCH] bridge: provide a cow_metrics method for fake_ops
>=20
> Like in commit 0972ddb237 (provide cow_metrics() methods to blackhole
> dst_ops), we must provide a cow_metrics for bridges fake_dst_ops as
> well.
>=20
> This fixes a regression coming from commits 62fa8a846d7d (net: Implem=
ent
> read-only protection and COW'ing of metrics.) and 33eb9873a28 (bridge=
:
> initialize fake_rtable metrics)
>=20
> ip link set mybridge mtu 1234
> -->
> [  136.546243] Pid: 8415, comm: ip Tainted: P=20
> 2.6.39.1-00006-g40545b7 #103 ASUSTeK Computer Inc.         V1Sn=20
>         /V1Sn
> [  136.546256] EIP: 0060:[<00000000>] EFLAGS: 00010202 CPU: 0
> [  136.546268] EIP is at 0x0
> [  136.546273] EAX: f14a389c EBX: 000005d4 ECX: f80d32c0 EDX: f80d1da=
1
> [  136.546279] ESI: f14a3000 EDI: f255bf10 EBP: f15c3b54 ESP: f15c3b4=
8
> [  136.546285]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> [  136.546293] Process ip (pid: 8415, ti=3Df15c2000 task=3Df4741f80=20
> task.ti=3Df15c2000)
> [  136.546297] Stack:
> [  136.546301]  f80c658f f14a3000 ffffffed f15c3b64 c12cb9c8 f80d1b80=
=20
> ffffffa1 f15c3bbc
> [  136.546315]  c12da347 c12d9c7d 00000000 f7670b00 00000000 f80d1b80=
=20
> ffffffa6 f15c3be4
> [  136.546329]  00000004 f14a3000 f255bf20 00000008 f15c3bbc c11d6cae=
=20
> 00000000 00000000
> [  136.546343] Call Trace:
> [  136.546359]  [<f80c658f>] ? br_change_mtu+0x5f/0x80 [bridge]
> [  136.546372]  [<c12cb9c8>] dev_set_mtu+0x38/0x80
> [  136.546381]  [<c12da347>] do_setlink+0x1a7/0x860
> [  136.546390]  [<c12d9c7d>] ? rtnl_fill_ifinfo+0x9bd/0xc70
> [  136.546400]  [<c11d6cae>] ? nla_parse+0x6e/0xb0
> [  136.546409]  [<c12db931>] rtnl_newlink+0x361/0x510
> [  136.546420]  [<c1023240>] ? vmalloc_sync_all+0x100/0x100
> [  136.546429]  [<c1362762>] ? error_code+0x5a/0x60
> [  136.546438]  [<c12db5d0>] ? rtnl_configure_link+0x80/0x80
> [  136.546446]  [<c12db27a>] rtnetlink_rcv_msg+0xfa/0x210
> [  136.546454]  [<c12db180>] ? __rtnl_unlock+0x20/0x20
> [  136.546463]  [<c12ee0fe>] netlink_rcv_skb+0x8e/0xb0
> [  136.546471]  [<c12daf1c>] rtnetlink_rcv+0x1c/0x30
> [  136.546479]  [<c12edafa>] netlink_unicast+0x23a/0x280
> [  136.546487]  [<c12ede6b>] netlink_sendmsg+0x26b/0x2f0
> [  136.546497]  [<c12bb828>] sock_sendmsg+0xc8/0x100
> [  136.546508]  [<c10adf61>] ? __alloc_pages_nodemask+0xe1/0x750
> [  136.546517]  [<c11d0602>] ? _copy_from_user+0x42/0x60
> [  136.546525]  [<c12c5e4c>] ? verify_iovec+0x4c/0xc0
> [  136.546534]  [<c12bd805>] sys_sendmsg+0x1c5/0x200
> [  136.546542]  [<c10c2150>] ? __do_fault+0x310/0x410
> [  136.546549]  [<c10c2c46>] ? do_wp_page+0x1d6/0x6b0
> [  136.546557]  [<c10c47d1>] ? handle_pte_fault+0xe1/0x720
> [  136.546565]  [<c12bd1af>] ? sys_getsockname+0x7f/0x90
> [  136.546574]  [<c10c4ec1>] ? handle_mm_fault+0xb1/0x180
> [  136.546582]  [<c1023240>] ? vmalloc_sync_all+0x100/0x100
> [  136.546589]  [<c10233b3>] ? do_page_fault+0x173/0x3d0
> [  136.546596]  [<c12bd87b>] ? sys_recvmsg+0x3b/0x60
> [  136.546605]  [<c12bdd83>] sys_socketcall+0x293/0x2d0
> [  136.546614]  [<c13629d0>] sysenter_do_call+0x12/0x26
> [  136.546619] Code:  Bad EIP value.
> [  136.546627] EIP: [<00000000>] 0x0 SS:ESP 0068:f15c3b48
> [  136.546645] CR2: 0000000000000000
> [  136.546652] ---[ end trace 6909b560e78934fa ]---
>=20
> Signed-off-by: Alexander Holler <holler@ahsoftware.de>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> CC: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> net/bridge/br_netfilter.c |    6 ++++++
>  1 file changed, 6 insertions(+)
>=20
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 3fa1231..23b43d2 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -104,10 +104,16 @@ static void fake_update_pmtu(struct dst_entry *=
dst, u32 mtu)
>  {
>  }
> =20
> +static u32 *fake_cow_metrics(struct dst_entry *dst, unsigned long ol=
d)
> +{
> +	return NULL;
> +}
> +
>  static struct dst_ops fake_dst_ops =3D {
>  	.family =3D		AF_INET,
>  	.protocol =3D		cpu_to_be16(ETH_P_IP),
>  	.update_pmtu =3D		fake_update_pmtu,
> +	.cow_metrics =3D		fake_cow_metrics,
>  };
> =20
>  /*
>=20
>=20
Not to drag this out further, but since you illustrated the correct way=
 to do
this with the blackhole_ops test, and this modification now gives us tw=
o
instances of that case, would it perhaps be better to just do this in
dst_metrics_write_ptr:

return dst->ops->cow_metrics ? return dst->ops->cow_metrics(dst, p) : N=
ULL;

Then we could eliminate the two functions that do nothing be retun NULL=
 (along
with their respective call instructions), and save any future users fro=
m having
to remember to include a dummy cow_metrics method if they happen to set=
 the read
only flag on thier dst_ops?

Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
