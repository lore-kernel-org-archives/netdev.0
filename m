From: Jonathan Nieder <jrnieder@gmail.com>
Subject: [3.2.y] phy:icplus:fix Auto Power Saving in ip101a_config_init.
Date: Wed, 9 May 2012 12:18:47 -0500
Message-ID: <20120509171847.GC4884@burratino>
References: <1333360929-31506-1-git-send-email-srinivas.kandagatla@st.com>
 <20120403.184937.744089580257691570.davem@davemloft.net>
 <20120509072537.GA437@burratino>
 <20120509.115729.1982766903625560504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, srinivas.kandagatla@st.com,
	netdev@vger.kernel.org, peppe.cavallaro@st.com,
	Ben Hutchings <ben@decadent.org.uk>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:42087 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755333Ab2EIRS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 13:18:59 -0400
Content-Disposition: inline
In-Reply-To: <20120509.115729.1982766903625560504.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Date: Mon, 2 Apr 2012 00:02:09 +0000

[ Upstream commit b3300146aa8efc5d3937fd33f3cfdc580a3843bc ]

This patch fixes Auto Power Saving configuration in ip101a_config_init
which was broken as there is no phy register write followed after
setting IP101A_APS_ON flag.

This patch also fixes the return value of ip101a_config_init.

Without this patch ip101a_config_init returns 2 which is not an error
accroding to IS_ERR and the mac driver will continue accessing 2 as
valid pointer to phy_dev resulting in memory fault.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Jonathan Nieder <jrnieder@gmail.com>
---
David Miller wrote:
> From: Jonathan Nieder <jrnieder@gmail.com>

>> I'm guessing 3.2.y needs this, too, since it also includes
>> v3.2-rc1~129^2~247 ("net/phy: add IC+ IP101A and support APS").
>>
>> Here's a quick backport made by adjusting the context line to
>> use IP101A_APS_ON instead of IP101A_G_APS_ON.
>>
>> Please include it in some later stable update if appropriate.
>
> Please submit this directly to the stable list.

Thanks for looking it over.  Doing so.

 drivers/net/phy/icplus.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index c81f136ae670..b14230016d9b 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -150,7 +150,8 @@ static int ip101a_config_init(struct phy_device *phydev)
 	/* Enable Auto Power Saving mode */
 	c = phy_read(phydev, IP10XX_SPEC_CTRL_STATUS);
 	c |= IP101A_APS_ON;
-	return c;
+
+	return phy_write(phydev, IP10XX_SPEC_CTRL_STATUS, c);
 }
 
 static int ip175c_read_status(struct phy_device *phydev)
-- 
1.7.10.1
