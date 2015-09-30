From: Tim Harvey <tharvey@gateworks.com>
Subject: DSA driver - how to glue to a PCI based NIC's mdio?
Date: Wed, 30 Sep 2015 13:44:52 -0700
Message-ID: <CAJ+vNU2rf0r9V3DfF1-=hpEhdqxkDHz-LmHWOJqscLdsw2EDEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:33354 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932516AbbI3Uox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 16:44:53 -0400
Received: by oixx17 with SMTP id x17so29555854oix.0
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 13:44:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

I'm working on adding DSA support for a PCIe expansion card (designed
by us) that has common PCIe NIC connected via its mii-bus to a Marvell
MV88E6171. Because the NIC is a PCIe device, it has no device-tree
representation of its NIC or its mdio bus, but does register its mdio
bus with Linux.

Does anyone know how I would be able to specify the Ethernet device
and MDIO bus for this add-in card if it has no device-tree handle?

I can write a phy driver that gets probed by matching the MV88E6171
PHY ID when the NIC's mdio bus get's registered yet even then I'm not
clear how to get hold of the netdev pointer given the mdio bus so as
to build a dsa_chip_data struct to register as a platform device. I'm
also not clear in this case how to verify in this case if the
MV88E6171 is from 'my' add-in card vs another card.

Perhaps the right approach is to program the NIC's EEPROM on our board
with a PCI_ID/DEVICE_ID of ours, add support for those ID's to the
NIC's driver, and within the NIC's driver create and register dsa
platform device when our ID is encountered?

Thanks for any advise,

Tim

Tim Harvey - Principal Software Engineer
Gateworks Corporation - http://www.gateworks.com/
3026 S. Higuera St. San Luis Obispo CA 93401
805-781-2000
