From: Mohammed Shafi <shafi.wireless@gmail.com>
Subject: Re: [PATCH] jme: fix irq storm after suspend/resume
Date: Sat, 22 Oct 2011 18:39:22 +0530
Message-ID: <CAD2nsn2pMma4y2RyX_tyxohV3AtNnOa_t8UOR4cJdrABzehMeg@mail.gmail.com>
References: <20111022125620.GA2256@ecki.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Adrian Chadd <adrian@freebsd.org>
To: Clemens Buchacher <drizzd@aon.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43713 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740Ab1JVNJZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 09:09:25 -0400
In-Reply-To: <20111022125620.GA2256@ecki.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 22, 2011 at 6:26 PM, Clemens Buchacher <drizzd@aon.at> wrot=
e:
> If the device is down during suspend/resume, interrupts are enabled
> without a registered interrupt handler, causing a storm of
> unhandled interrupts until the IRQ is disabled because "nobody
> cared".

thank you so much for fixing this. incredible persistence from your sid=
e!

>
> Instead, check that the device is up before touching it in the
> suspend/resume code.
>
> Fixes https://bugzilla.kernel.org/show_bug.cgi?id=3D39112
>
> Helped-by: Adrian Chadd <adrian@freebsd.org>
> Helped-by: Mohammed Shafi <shafi.wireless@gmail.com>
> Signed-off-by: Clemens Buchacher <drizzd@aon.at>
> ---
>
> Unfortunately, bugzilla.kernel.org is still down. There is at least
> one other person who reported the issue, and I don't have their
> email address. So for now, I am the only one who tested this fix.
>
> The patch applies to current tip (2efd7c0) of Linus' tree. I also
> tested it based on v3.0 and it worked the same.
>
> Many thanks to Adrian and Mohammed for helping me debug this issue.
> See this thread for the history:
> =A0http://mid.gmane.org/20110827113253.GA1444@ecki
>
> =A0drivers/net/jme.c | =A0 =A06 ++++++
> =A01 files changed, 6 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/jme.c b/drivers/net/jme.c
> index 3ac262f..7a8a3b6 100644
> --- a/drivers/net/jme.c
> +++ b/drivers/net/jme.c
> @@ -3131,6 +3131,9 @@ jme_suspend(struct device *dev)
> =A0 =A0 =A0 =A0struct net_device *netdev =3D pci_get_drvdata(pdev);
> =A0 =A0 =A0 =A0struct jme_adapter *jme =3D netdev_priv(netdev);
>
> + =A0 =A0 =A0 if (!netif_running(netdev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> =A0 =A0 =A0 =A0atomic_dec(&jme->link_changing);
>
> =A0 =A0 =A0 =A0netif_device_detach(netdev);
> @@ -3171,6 +3174,9 @@ jme_resume(struct device *dev)
> =A0 =A0 =A0 =A0struct net_device *netdev =3D pci_get_drvdata(pdev);
> =A0 =A0 =A0 =A0struct jme_adapter *jme =3D netdev_priv(netdev);
>
> + =A0 =A0 =A0 if (!netif_running(netdev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> =A0 =A0 =A0 =A0jme_clear_pm(jme);
> =A0 =A0 =A0 =A0jme_phy_on(jme);
> =A0 =A0 =A0 =A0if (test_bit(JME_FLAG_SSET, &jme->flags))
> --
> 1.7.7
>
>



--=20
shafi
