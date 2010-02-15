From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] Staging: Octeon:  Free transmit SKBs in a timely
 manner.
Date: Mon, 15 Feb 2010 21:27:53 +0100
Message-ID: <1266265673.2859.5.camel@edumazet-laptop>
References: <4B79AAA6.60005@caviumnetworks.com>
	 <1266264799-3510-4-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:37732 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756485Ab0BOU2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 15:28:00 -0500
Received: by bwz5 with SMTP id 5so1391630bwz.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 12:27:58 -0800 (PST)
In-Reply-To: <1266264799-3510-4-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 15 f=C3=A9vrier 2010 =C3=A0 12:13 -0800, David Daney a =C3=A9c=
rit :
> If we wait for the once-per-second cleanup to free transmit SKBs,
> sockets with small transmit buffer sizes might spend most of their
> time blocked waiting for the cleanup.
>=20
> Normally we do a cleanup for each transmitted packet.  We add a
> watchdog type timer so that we also schedule a timeout for 150uS afte=
r
> a packet is transmitted.  The watchdog is reset for each transmitted
> packet, so for high packet rates, it never expires.  At these high
> rates, the cleanups are done for each packet so the extra watchdog
> initiated cleanups are not needed.

s/needed/fired/

Hmm, but re-arming a timer for each transmited packet must have a cost =
?

>=20
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>

Is there any particular reason periodic is spelled preiodic ?

> ---
>  }
> =20
> -static void cvm_oct_tx_clean_worker(struct work_struct *work)
> +static void cvm_oct_preiodic_worker(struct work_struct *work)
>  {



> -			INIT_DELAYED_WORK(&priv->tx_clean_work,
> -					  cvm_oct_tx_clean_worker);
> -
> +			INIT_DELAYED_WORK(&priv->port_periodic_work,
> +					  cvm_oct_preiodic_worker);



