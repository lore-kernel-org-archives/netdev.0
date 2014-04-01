From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net] xen-netback: disable rogue vif in kthread
 context
Date: Tue, 01 Apr 2014 16:27:17 -0400 (EDT)
Message-ID: <20140401.162717.1962834632849633175.davem@davemloft.net>
References: <1396352772-7884-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	david.vrabel@citrix.com, zoltan.kiss@citrix.com, edwin@etorok.net,
	ian.campbell@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbaDAU1T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 16:27:19 -0400
In-Reply-To: <1396352772-7884-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Wei Liu <wei.liu2@citrix.com>
Date: Tue, 1 Apr 2014 12:46:12 +0100

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
> Reported-by: T=F6r=F6k Edwin <edwin@etorok.net>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Applied.
