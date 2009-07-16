From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/2 v4] fs_enet/mii-fec.c: fix MII speed calculation
Date: Thu, 16 Jul 2009 16:44:21 -0600
Message-ID: <fa686aa40907161544je92317dy7abea6819746847@mail.gmail.com>
References: <1247671133-12148-1-git-send-email-wd@denx.de>
	<1247780546-4426-1-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, Kumar Gala <galak@kernel.crashing.org>,
	netdev@vger.kernel.org
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f184.google.com ([209.85.210.184]:35350 "EHLO
	mail-yx0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933463AbZGPWon convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 18:44:43 -0400
Received: by yxe14 with SMTP id 14so778794yxe.33
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 15:44:41 -0700 (PDT)
In-Reply-To: <1247780546-4426-1-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2009 at 3:42 PM, Wolfgang Denk<wd@denx.de> wrote:
> The MII speed calculation was based on the CPU clock (ppc_proc_freq),
> but for MPC512x we must use the bus clock instead.
>
> This patch makes it use the correct clock and makes sure we don't
> clobber reserved bits in the MII_SPEED register.
>
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Kumar Gala <galak@kernel.crashing.org>
> Cc: <netdev@vger.kernel.org>

Looks good to me.  Thanks for the work!

I assume this is tested.  I have not tested this on my board, and I've
got one question below, but otherwise I think I can say....
Acked-by: Grant Likely <grant.likely@secretlab.ca>

> - =A0 =A0 =A0 fec->mii_speed =3D ((ppc_proc_freq + 4999999) / 5000000=
) << 1;
> + =A0 =A0 =A0 if (get_bus_freq) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock =3D get_bus_freq(ofdev->node);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!clock) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ofdev->dev, "c=
ould not determine IPS/IPB clock\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unmap_regs;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock =3D ppc_proc_freq;
> +
> + =A0 =A0 =A0 /* scale for a MII clock <=3D 2.5 MHz */
> + =A0 =A0 =A0 speed =3D (clock + 2499999) / 2500000;

The calculation has changed here for non mpc5121 users.  Shouldn't the
"clock =3D ppc_proc_freq;" line above be "clock =3D ppc_proc_freq / 2;"=
?
Or was this also a bug in the original driver?

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
