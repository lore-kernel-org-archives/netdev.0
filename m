From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 V2] kaweth: Fix locking to be SMP-safe
Date: Wed, 1 Apr 2009 00:13:04 +0200
Message-ID: <200904010013.05494.oliver@neukum.org>
References: <49d264dd.YwbXLw18YaD1tQqD%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:46728 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763512AbZCaWI4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 18:08:56 -0400
In-Reply-To: <49d264dd.YwbXLw18YaD1tQqD%Larry.Finger@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag 31 M=E4rz 2009 20:45:49 schrieb Larry Finger:

> @@ -796,7 +799,7 @@ static int kaweth_start_xmit(struct sk_b

> @@ -848,7 +851,7 @@ skip:
>  		net->trans_start =3D jiffies;
>  	}
>
> -	spin_unlock(&kaweth->device_lock);
> +	spin_unlock_irq(&kaweth->device_lock);

Here you enable interrupts. Are you sure ndo_start_xmit is never
called with interrupts disabled?

	Regards
		Oliver

