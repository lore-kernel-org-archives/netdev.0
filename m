From: "Phil Endecott" <spam_from_netdev@chezphil.org>
Subject: Checking for MDIO phy address 0
Date: Mon, 28 Nov 2016 18:53:50 +0000
Message-ID: <1480359230293@dmwebmail.dmwebmail.chezphil.org>
Mime-Version: 1.0
Content-Type: text/plain; format="fixed"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from japan.chezphil.org ([77.240.5.4]:1034 "EHLO japan.chezphil.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753067AbcK1TRf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 14:17:35 -0500
Received: from localhost ([127.0.0.1] helo=chezphil.org)
        by japan.chezphil.org with esmtp (Exim 4.72)
        (envelope-from <spam_from_netdev@chezphil.org>)
        id 1cBR3n-0002vo-2S
        for netdev@vger.kernel.org; Mon, 28 Nov 2016 18:53:51 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Experts,

Is it true that phy address 0 is special, and should not be used?
I have this in my device tree (edited for brevity):

        mdio@17020000 {
            compatible = "apm,xgene-mdio-rgmii";
            #address-cells = <0x00000001>;
            #size-cells = <0x00000000>;
            phy@4 {
                reg = <0x00000000>;
                linux,phandle = <0x00000021>;
                phandle = <0x00000021>;
            };
            phy@5 {
                reg = <0x00000001>;
                linux,phandle = <0x00000022>;
                phandle = <0x00000022>;
            };
        };
        ethernet@1f210000 {
            compatible = "apm,xgene1-sgenet";
            phy-connection-type = "sgmii";
            phy-handle = <0x00000021>;
        };
        ethernet@1f210030 {
            compatible = "apm,xgene1-sgenet";
            phy-connection-type = "sgmii";
            phy-handle = <0x00000022>;
        };

(This is on a Gigabyte MP30-AR1, which has an X-Gene ARM64 processor.)

I've spent a long time trying to get the two gigabit ethernet ports to 
correctly auto-negotiate down to 100 Mbit, and it's possible that the 
underlying problem is that one of the phys is using address 0.  Does 
that make sense?

Anyway, my reason for this message is to suggest a runtime diagnostic 
message somewhere if address 0 is used - this could have saved me a lot of 
work! If someone can suggest the right place to add this I can prepare a 
patch.


Thanks,  Phil.
