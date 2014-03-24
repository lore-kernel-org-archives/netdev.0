From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net] xen-netback: disable rogue vif in kthread context
Date: Mon, 24 Mar 2014 12:22:04 +0000
Message-ID: <1395663724.6294.18.camel@kazak.uk.xensource.com>
References: <1395663214-14133-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	<paul.durrant@citrix.com>, <zoltan.kiss@citrix.com>,
	<edwin@etorok.net>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:4728 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923AbaCXMWf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2014 08:22:35 -0400
In-Reply-To: <1395663214-14133-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 12:13 +0000, Wei Liu wrote:
> When netback discovers frontend is sending malformed packet it will
> disables the interface which serves that frontend.
>=20
> However disabling a network interface involving taking a mutex which
> cannot be done in softirq context, so we need to defer this process t=
o
> kthread context.
>=20
> This patch does the following:
> 1. introduce a flag to indicate the interface is disabled.
> 2. check that flag in TX path, don't do any work if it's true.
> 3. check that flag in RX path, turn off that interface if it's true.
>=20
> The reason to disable it in RX path is because RX uses kthread. After
> this change the behavior of netback is still consistent -- it won't d=
o
> any TX work for a rogue frontend, and the interface will be eventuall=
y
> turned off.
>=20
> Also change a "continue" to "break" after xenvif_fatal_tx_err, as it
> doesn't make sense to continue processing packets if frontend is rogu=
e.
>=20
> This is a fix for XSA-90.
>=20
> Reported-by: T=C3=B6r=C3=B6k Edwin <edwin@etorok.net>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

> +		if (unlikely(vif->disabled) && netif_carrier_ok(vif->dev))

Perhaps consider extending the scope of the unlikely over the entire
expression? (not that I expect it will matter much)

Ian.
