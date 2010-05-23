From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [patch] e1000e: change logical negate to bitwise
Date: Sat, 22 May 2010 18:01:27 -0700
Message-ID: <AANLkTil3USy0GrLLgShygH8PpOZPmVHwH5oSvNarAOhk@mail.gmail.com>
References: <20100522194550.GG22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60669 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755522Ab0EWBB2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 21:01:28 -0400
In-Reply-To: <20100522194550.GG22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 22, 2010 at 12:45, Dan Carpenter <error27@gmail.com> wrote:
> The bitwise negate is intended here. =C2=A0With the logical negate th=
e
> condition is always false.
>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
>
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.=
c
> index 24507f3..57a7e41 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -2554,7 +2554,7 @@ static void e1000_init_manageability_pt(struct =
e1000_adapter *adapter)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0mdef =3D er32(MDEF(i));
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Ignore filters with anything other than IPMI ports */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (mdef & !(E1000_MDEF_PORT_623 | E1000_MDEF_PORT_664))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (mdef & ~(E1000_MDEF_PORT_623 | E1000_MDEF_PORT_664))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Enable this decision filter in MANC2H */
> --

Thanks Dan, I have added the patch to my queue.

--=20
Cheers,
Jeff
