From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: PHY hardware reset
Date: Sun, 6 Mar 2016 01:09:40 +0300
Message-ID: <56DB5924.3020206@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:35685 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbcCEWJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 17:09:44 -0500
Received: by mail-lb0-f169.google.com with SMTP id bc4so95561263lbc.2
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2016 14:09:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

    I have a need to de-assert the active-low PHY hardware reset signal 
(mapped to a GPIO) before the MDIO bus scansince it's left asserted by the 
bootloader (U-Boot). I have a device tree probed MAX driver (ravb) and I'm 
somewhat at a loss about where and how to do this. The existing example 
(Freescale FEC) has DT props controlling the PHY reset GPIO in the MAC device 
node but it doesn't seem correct at all since this signal has nothing to do 
with the MAC, only with PHY! I therefore would like this "phy-reset-gpios" 
property to be defined under the PHY node but this way I'll have to add the 
handling of this prop to the phylib (it would be too late if I did that in a a 
PHY driver method since that). I'm also seeing the mii_bus::reset() method and 
it seems a good place but I'm not sure if my PHY's reset signal can be treated 
as the reset signal for the whole bus; if it would, the DT prop should be 
placed under the MAC node anyway...
    Florian (and everybody), what's your thoughts on this matter?

MBR, Sergei
