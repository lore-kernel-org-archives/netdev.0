From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Prevent pseudo garbage in SYN's advertized
 window
Date: Tue, 13 Feb 2007 12:39:01 -0800 (PST)
Message-ID: <20070213.123901.15263824.davem@davemloft.net>
References: <Pine.LNX.4.64.0702131432350.25858@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32933
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751051AbXBMUjC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 15:39:02 -0500
In-Reply-To: <Pine.LNX.4.64.0702131432350.25858@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 13 Feb 2007 15:08:34 +0200 (EET)

> TCP may advertize up to 16-bits window in SYN packets (no window
> scaling allowed). At the same time, TCP may have rcv_wnd
> (32-bits) that does not fit to 16-bits without window scaling
> resulting in pseudo garbage into advertized window from the
> low-order bits of rcv_wnd. This can happen at least when
> mss <=3D (1<<wscale) (see tcp_select_initial_window). This patch
> fixes the handling of SYN advertized windows (compile tested
> only).
>=20
> In worst case (which is unlikely to occur though), the receiver
> advertized window could be just couple of bytes. I'm not sure
> that such situation would be handled very well at all by the
> receiver!? Fortunately, the situation normalizes after the
> first non-SYN ACK is received because it has the correct,
> scaled window.
>=20
> Alternatively, tcp_select_initial_window could be changed to
> prevent too large rcv_wnd in the first place.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Thanks for catching this bug, I think your fix is fine.

The same bug also exists in tcp_make_synack(), I'll fix that
one up in the same way.

Thanks again.
