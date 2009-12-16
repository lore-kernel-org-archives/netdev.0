From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH] bnx2: reset_task is crashing the kernel. Fixing it.
Date: Wed, 16 Dec 2009 09:23:58 -0800
Message-ID: <97949e3e0912160923p3353fe97vdc42a20597dec7f4@mail.gmail.com>
References: <1260965365-14255-1-git-send-email-leitao@linux.vnet.ibm.com>
	<1260965365-14255-2-git-send-email-leitao@linux.vnet.ibm.com>
	<1260965365-14255-3-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:7563 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762575AbZLPRYZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 12:24:25 -0500
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id nBGHOKA7007031
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 17:24:21 GMT
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by kpbe17.cbf.corp.google.com with ESMTP id nBGHNi9C001180
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 09:24:19 -0800
Received: by pwi6 with SMTP id 6so818540pwi.7
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 09:24:18 -0800 (PST)
In-Reply-To: <1260965365-14255-3-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 4:09 AM,  <leitao@linux.vnet.ibm.com> wrote:
> Acutally if a BNX2 interface gets time outs, the reset_task is
> called to restart the interface. But, the NIC is turned off with
> some packages to transmitt, and this causes the function

s/packages/packets/
s/transmitt/transmit/

> napi_disable() to loop forever, crashing the kernel.
>
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> ---
> =A0drivers/net/bnx2.c | =A0 =A04 ++--
> =A01 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index f81f082..40c883b 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -652,8 +652,6 @@ bnx2_napi_enable(struct bnx2 *bp)
> =A0static void
> =A0bnx2_netif_stop(struct bnx2 *bp)
> =A0{
> - =A0 =A0 =A0 bnx2_cnic_stop(bp);
> - =A0 =A0 =A0 bnx2_disable_int_sync(bp);
> =A0 =A0 =A0 =A0if (netif_running(bp->dev)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int i;
>
> @@ -667,6 +665,8 @@ bnx2_netif_stop(struct bnx2 *bp)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0txq->trans_start =3D j=
iffies;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 bnx2_cnic_stop(bp);
> + =A0 =A0 =A0 bnx2_disable_int_sync(bp);
> =A0}
>
> =A0static void
> --
> 1.6.0.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
