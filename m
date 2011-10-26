From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Small glitch in neptune ethernet driver
Date: Wed, 26 Oct 2011 19:39:27 +0200
Message-ID: <4EA845CF.6070401@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:44139 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933636Ab1JZRja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 13:39:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

consider this piece of code in net/ethernet/sun/niu.c:

static int __devinit phy_record(struct niu_parent *parent,
				struct phy_probe_info *p,
				int dev_id_1, int dev_id_2, u8 phy_port,
				int type)
{
...
	if (type == PHY_TYPE_PMA_PMD || type == PHY_TYPE_PCS) {
		if (((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8704) &&
		    ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_MRVL88X2011) &&
		    ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8706))
			return 0;
	}
...
}

Here are the defines from sun/niu.h:

#define NIU_PHY_ID_MASK         0xfffff0f0
#define NIU_PHY_ID_BCM8704      0x00206030
#define NIU_PHY_ID_BCM8706      0x00206035

There's a zero at the end of the ID_MASK,
so the NIU_PHY_ID_BCM8706 will never match (ends on 5).

Report from cppcheck:
[sun/niu.c:8594]: (style) Mismatching comparison, the result is always true

The code will probably still work as the id for BCM8706
should match on NIU_PHY_ID_BCM8704, too.

Keep it or leave it?

Cheers,
Thomas
