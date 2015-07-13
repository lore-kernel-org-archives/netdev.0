From: David Binderman <dcb314@hotmail.com>
Subject: linux-4.2-rc2/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1993:
 possible bad error checking ?
Date: Mon, 13 Jul 2015 09:48:59 +0000
Message-ID: <DUB128-W847EC851814161BB5A100A9C9C0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub004-omc3s19.hotmail.com ([157.55.2.28]:51424 "EHLO
	DUB004-OMC3S19.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751019AbbGMJtB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 05:49:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello there,

[linux-4.2-rc2/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1993]:=
 (style) Checking if unsigned variable 'entry' is less than zero.

Source code is

=A0=A0=A0=A0=A0=A0=A0 entry =3D priv->hw->mode->jumbo_frm(priv, skb, cs=
um_insertion);
=A0=A0=A0=A0=A0=A0=A0 if (unlikely(entry < 0))
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto dma_map_err;

but

=A0=A0=A0 unsigned int entry;

So the error checking from the function call looks broken to me.

If the return value from the function call to jumbo_frm is a plain sign=
ed integer, suggest
sanity check that *before* assigning into an unsigned integer.

Regards

David Binderman

 		 	   		  