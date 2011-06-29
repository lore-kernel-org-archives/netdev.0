From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH RFC] r8169: minimal rtl8111e-vl support
Date: Wed, 29 Jun 2011 20:18:57 +0800
Message-ID: <515527CFA16C45B280613F6BDE5C3DF9@realtek.com.tw>
References: <20110628214410.GA4163@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:60470 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184Ab1F2MTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 08:19:04 -0400
In-Reply-To: <20110628214410.GA4163@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The driver of Realtek includes testing chips which are used internally and don't
need be supported.
I plan to start implementing the new chips next week. Maybe you could continue
after that time if you don't mind.
 
Best Regards,
Hayes


-----Original Message-----
From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
Sent: Wednesday, June 29, 2011 5:44 AM
To: Hayeswang
Cc: netdev@vger.kernel.org
Subject: [PATCH RFC] r8169: minimal rtl8111e-vl support

Mostly bits from version 8.023.00 of Realtek's own r8168 driver. It applies on
top of davem's net-next branch + a small, uninteresting attached patch.

I have given it a short testing w/o the new-format rtl8168e-3_0.0.1 firmware and
it is fairly encouraging.

The code is still incomplete :
- WoL needs some care. No difficulty here.
- rtl8168e_2_hw_phy_config imho deserves a few comments similar to those in
  rtl8168e_1_hw_phy_config. Hayes, can you take care of it ?
- I have excluded a set of completely unidentified registers / bits
  operations, for instance:
  - Config5
      BIT_0
  - Config2
      BIT_5
      BIT_7
  - TxConfig
      BIT_7
  - 0x1a
      BIT_2
      BIT_3
  - 0x1b
      0xf8 / 0x07
  - 0xb0,
      0xee480010
  - 0xd0
      BIT_6
  - 0xd3
      BIT_7
  - 0xf2
      BIT_6
  Either they are not needed or someone will have to name them adequately.
  Hayes ?
- Short packets apparently need to be checksummed by the driver (?) but
  the work-around seems strange. It is not clear to me what Realtek's
  driver is trying to achieve in hard_start_xmit. Hayes, can you elaborate ?

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---

