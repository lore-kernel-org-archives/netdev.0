From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: Fix irq_synchronize in MSI-X case
Date: Wed, 21 Jul 2010 13:38:10 -0700
Message-ID: <AANLkTimpgw4WB4bjLZOLTFs=0rGseqp+EQckS=r=YsSw@mail.gmail.com>
References: <201007201712.05671.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:58987 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab0GUUiM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 16:38:12 -0400
Received: by iwn7 with SMTP id 7so7076013iwn.19
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 13:38:11 -0700 (PDT)
In-Reply-To: <201007201712.05671.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 20, 2010 at 08:12, Jean Delvare <jdelvare@suse.de> wrote:
> Synchronize all IRQs when in MSI-X IRQ mode.
>
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> ---
> I sent this patch to the e1000-devel list on June 8th, 2010, but
> didn't receive any answer:
> http://sourceforge.net/mailarchive/forum.php?thread_name=3D2010060818=
18.59098.jdelvare%40suse.de&forum_name=3De1000-devel
>
> I don't know how critical synchronize_irq() is, so I don't know if
> this patch should go to stable branches or not.
>
> =C2=A0drivers/net/e1000e/netdev.c | =C2=A0 =C2=A08 +++++++-
> =C2=A01 file changed, 7 insertions(+), 1 deletion(-)
>
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -1939,7 +1939,13 @@ static void e1000_irq_disable(struct e10
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (adapter->msix_entries)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ew32(EIAC_8257=
4, 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0e1e_flush();
> - =C2=A0 =C2=A0 =C2=A0 synchronize_irq(adapter->pdev->irq);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (adapter->msix_entries) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 synchronize_irq(ad=
apter->msix_entries[0].vector);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 synchronize_irq(ad=
apter->msix_entries[1].vector);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 synchronize_irq(ad=
apter->msix_entries[2].vector);
> + =C2=A0 =C2=A0 =C2=A0 } else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 synchronize_irq(ad=
apter->pdev->irq);
> =C2=A0}
>
> =C2=A0/**
>
> --
> Jean Delvare
> Suse L3

Thanks, I have added the patch to my queue.

--=20
Cheers,
Jeff
