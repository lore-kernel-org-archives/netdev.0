From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-2.6] atl1c: Fix hardware type check for enabling OTP CLK
Date: Sat, 20 Nov 2010 04:55:36 +0000
Message-ID: <1290228936.3818.135.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jie Yang <Jie.Yang@atheros.com>, linux-team@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53128 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932257Ab0KTEzn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Nov 2010 23:55:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 496c185c9495629ef1c65387cb2594578393cfe0 "atl1c: Add support
for Atheros AR8152 and AR8152" added the condition:

             if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c_b)

for enabling OTP CLK, and the condition:

             if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c)

for disabling OTP CLK.  Since the two previously defined hardware
types are athr_l1c and athr_l2c, the latter condition appears to be
the correct one.  Change the former to match.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This is compile-tested only.  It looks like the current code may fail to
read non-volatile settings on the L2C hardware since the EEPROM will not
be clocked.  Please check this.

Ben.

 drivers/net/atl1c/atl1c_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atl1c/atl1c_hw.c b/drivers/net/atl1c/atl1c_hw.c
index 919080b..1bf6720 100644
--- a/drivers/net/atl1c/atl1c_hw.c
+++ b/drivers/net/atl1c/atl1c_hw.c
@@ -82,7 +82,7 @@ static int atl1c_get_permanent_address(struct atl1c_hw *hw)
 	addr[0] = addr[1] = 0;
 	AT_READ_REG(hw, REG_OTP_CTRL, &otp_ctrl_data);
 	if (atl1c_check_eeprom_exist(hw)) {
-		if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c_b) {
+		if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c) {
 			/* Enable OTP CLK */
 			if (!(otp_ctrl_data & OTP_CTRL_CLK_EN)) {
 				otp_ctrl_data |= OTP_CTRL_CLK_EN;
-- 
1.7.2.3


