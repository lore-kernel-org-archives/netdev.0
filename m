From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v2 net 2/3] lan78xx: Allow EEPROM write for less than
 MAX_EEPROM_SIZE
Date: Mon, 11 Sep 2017 20:13:54 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B1E6CE@CHN-SV-EXMX02.mchp-main.com>
References: <CE371C1263339941885964188A0225FA335C94@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <Nisar.Sayed@microchip.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.microchip.iphmx.com ([68.232.153.233]:30667 "EHLO
        esa3.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751076AbdIKUOr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 16:14:47 -0400
In-Reply-To: <CE371C1263339941885964188A0225FA335C94@CHN-SV-EXMX03.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nisar,

>@@ -1290,8 +1290,8 @@ static int lan78xx_ethtool_set_eeprom(struct net_device *netdev,
>
>        /* Allow entire eeprom update only */
>        if ((ee->magic == LAN78XX_EEPROM_MAGIC) &&
>-           (ee->offset == 0) &&
>-           (ee->len == 512) &&
>+           (ee->offset >= 0 && ee->offset < MAX_EEPROM_SIZE) &&
>+           (ee->len > 0 && (ee->offset + ee->len) <= MAX_EEPROM_SIZE) &&
>            (data[0] == EEPROM_INDICATOR))
This patch is for writing  any len at any offset.
However, "(data[0] == EEPROM_INDICATOR)" prevents it.

>                ret = lan78xx_write_raw_eeprom(dev, ee->offset, ee->len, data);
>        else if ((ee->magic == LAN78XX_OTP_MAGIC) &&

- Woojung
