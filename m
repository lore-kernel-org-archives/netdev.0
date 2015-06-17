From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH] xilinx:Remove unused variable num_frag in the function
 axienet_start_xmit
Date: Wed, 17 Jun 2015 11:58:48 -0700
Message-ID: <20150617185848.GI2906@xsjsorenbubuntu>
References: <1434556362-3748-1-git-send-email-xerofoify@gmail.com>
 <20150617160730.GE2906@xsjsorenbubuntu>
 <DD47523D-0DF9-46B5-9382-3C30BBD9E815@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <anirudh@xilinx.com>, <John.Linn@xilinx.com>,
	<michal.simek@xilinx.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0090.outbound.protection.outlook.com ([157.56.110.90]:32801
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752484AbbFQS7C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 14:59:02 -0400
Content-Disposition: inline
In-Reply-To: <DD47523D-0DF9-46B5-9382-3C30BBD9E815@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-17 at 12:21PM -0400, Nicholas Krause wrote:
>=20
>=20
> On June 17, 2015 12:07:30 PM EDT, "S=C3=B6ren Brinkmann" <soren.brink=
mann@xilinx.com> wrote:
> >On Wed, 2015-06-17 at 11:52AM -0400, Nicholas Krause wrote:
> >> This removes the unused variable num_frag and the setting of it
> >> to the number of fragments from the passed sk_buff pointer by
> >> this function's caller due to this variable never being used
> >> in this particular function and is not declared as  global so
> >> setting it for global use in this file is pointless.
> >>=20
> >> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> >> ---
> >>  drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 2 --
> >>  1 file changed, 2 deletions(-)
> >>=20
> >> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> >b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> >> index 28b7e7d..624dce4 100644
> >> --- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> >> +++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> >> @@ -651,7 +651,6 @@ static inline int
> >axienet_check_tx_bd_space(struct axienet_local *lp,
> >>  static int axienet_start_xmit(struct sk_buff *skb, struct net_dev=
ice
> >*ndev)
> >>  {
> >>  	u32 ii;
> >> -	u32 num_frag;
> >>  	u32 csum_start_off;
> >>  	u32 csum_index_off;
> >>  	skb_frag_t *frag;
> >> @@ -659,7 +658,6 @@ static int axienet_start_xmit(struct sk_buff
> >*skb, struct net_device *ndev)
> >>  	struct axienet_local *lp =3D netdev_priv(ndev);
> >>  	struct axidma_bd *cur_p;
> >> =20
> >> -	num_frag =3D skb_shinfo(skb)->nr_frags;
> >>  	cur_p =3D &lp->tx_bd_v[lp->tx_bd_tail];
> >> =20
> >>  	if (axienet_check_tx_bd_space(lp, num_frag)) {
> >
> >It's used right here, isn't it (and further down in this function to=
o)?
> >Does your tree compile with this change?
> >
> >	S=C3=B6ren
> My tree does compile with this change.=20

You have to fix your testing process:
    CHK     include/config/kernel.release
    UPD     include/config/kernel.release
    CHK     include/generated/uapi/linux/version.h
    CHK     include/generated/utsrelease.h
    UPD     include/generated/utsrelease.h
    CHK     include/generated/bounds.h
    CHK     include/generated/timeconst.h
    CHK     include/generated/asm-offsets.h
    CALL    scripts/checksyscalls.sh
  <stdin>:1253:2: warning: #warning syscall userfaultfd not implemented=
 [-Wcpp]
    CC      drivers/net/ethernet/xilinx/xilinx_axienet_main.o
  drivers/net/ethernet/xilinx/xilinx_axienet_main.c: In function 'axien=
et_start_xmit':
  drivers/net/ethernet/xilinx/xilinx_axienet_main.c:667:36: error: 'num=
_frag' undeclared (first use in this function)
    if (axienet_check_tx_bd_space(lp, num_frag)) {
                                      ^
  drivers/net/ethernet/xilinx/xilinx_axienet_main.c:667:36: note: each =
undeclared identifier is reported only once for each function it appear=
s in
  scripts/Makefile.build:258: recipe for target 'drivers/net/ethernet/x=
ilinx/xilinx_axienet_main.o' failed
  make[1]: *** [drivers/net/ethernet/xilinx/xilinx_axienet_main.o] Erro=
r 1
  Makefile:1545: recipe for target 'drivers/net/ethernet/xilinx/xilinx_=
axienet_main.o' failed
  make: *** [drivers/net/ethernet/xilinx/xilinx_axienet_main.o] Error 2

NACK for the patch.

	S=C3=B6ren
