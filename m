From: Sebastian.Poehn@Belden.com
Subject: [PATCH] ethtool: FLOW_EXT may confuse drivers
Date: Fri, 13 May 2011 10:19:04 -0400
Message-ID: <OFDA6F039C.B25E3B43-ON8525788F.004EA678-8525788F.004EA67B@BeldenCDT.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.belden.com ([12.161.118.90]:60581 "EHLO mx1.belden.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755318Ab1EMOTN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 10:19:13 -0400
In-Reply-To: 
References: 
MIME-Version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FLOW_EXT bit must be masked out. Otherwise if e.g. vlan is set a dr=
iver receiving the ntuple may not detect the flow_type correctly!

Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>

diff --git a/ethtool.c b/ethtool.c
index 34fe107..0b7ec05 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3134,6 +3134,9 @@ static int flow_spec_to_ntuple(struct ethtool_rx_=
flow_spec *fsp,
=A0=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 (u64)ntohl(~fsp->m_ext.data[=
1]);
=A0=A0=A0=A0 =A0=A0=A0 }
=A0=A0=A0=A0 }
+=A0=A0=A0=20
+=A0=A0=A0 /*Mask out the extended bit, because ntuple does not know it=
!*/
+=A0=A0=A0 ntuple->flow_type &=3D ~FLOW_EXT;
=A0
=A0=A0=A0=A0 return 0;
=A0}

DISCLAIMER:

Privileged and/or Confidential information may be contained in this
message. If you are not the addressee of this message, you may not
copy, use or deliver this message to anyone. In such event, you
should destroy the message and kindly notify the sender by reply
e-mail. It is understood that opinions or conclusions that do not
relate to the official business of the company are neither given
nor endorsed by the company.

Thank You.

