From: David Binderman <dcb314@hotmail.com>
Subject: linux-4.2-rc2/drivers/net/ethernet/brocade/bna/bfa_ioc.c:2843: out
 of bounds string access ?
Date: Mon, 13 Jul 2015 09:17:23 +0000
Message-ID: <DUB128-W30631084097BF584A985959C9C0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Rasesh Mody <rasesh.mody@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub004-omc3s25.hotmail.com ([157.55.2.34]:62296 "EHLO
	DUB004-OMC3S25.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750970AbbGMJRZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 05:17:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello there,

[linux-4.2-rc2/drivers/net/ethernet/brocade/bna/bfa_ioc.c:2843]: (error=
) Buffer is accessed out of bounds.

Source code is

=A0=A0=A0 memcpy(manufacturer, BFA_MFG_NAME, BFA_ADAPTER_MFG_NAME_LEN);

and

#define BFA_MFG_NAME "QLogic"

and

$ fgrep BFA_ADAPTER_MFG_NAME_LEN `find linux-4.2-rc2/drivers/net/ethern=
et/brocade/ -name \*.h -print`
linux-4.2-rc2/drivers/net/ethernet/brocade/bna/bfa_defs.h:=A0=A0=A0 BFA=
_ADAPTER_MFG_NAME_LEN=A0=A0=A0 =3D 8,=A0=A0 /*!< manufacturer name leng=
th */
$

so the code attempts to read eight bytes from a seven byte string. Sugg=
est code rework.

Regards

David Binderman

 		 	   		  