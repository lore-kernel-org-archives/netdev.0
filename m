From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/16] sfc: Revise sensor names to be more
 understandable and consistent
Date: Thu, 12 Dec 2013 23:01:27 +0000
Message-ID: <1386889287.1516.345.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43754 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3LLXBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:01:30 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_mon.c | 49 ++++++++++++++++++++-----------------
 1 file changed, 26 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index 99c80f8c0a0e..2891b409d263 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -42,13 +42,13 @@ static const struct {
 } efx_mcdi_sensor_type[] = {
 #define SENSOR(name, label, hwmon_type, port)				\
 	[MC_CMD_SENSOR_##name] = { label, EFX_HWMON_ ## hwmon_type, port }
-	SENSOR(CONTROLLER_TEMP,		"Controller ext. temp.",    TEMP,  -1),
+	SENSOR(CONTROLLER_TEMP,		"Controller board temp.",   TEMP,  -1),
 	SENSOR(PHY_COMMON_TEMP,		"PHY temp.",		    TEMP,  -1),
-	SENSOR(CONTROLLER_COOLING,	"Controller cooling",	    COOL,  -1),
+	SENSOR(CONTROLLER_COOLING,	"Controller heat sink",	    COOL,  -1),
 	SENSOR(PHY0_TEMP,		"PHY temp.",		    TEMP,  0),
-	SENSOR(PHY0_COOLING,		"PHY cooling",		    COOL,  0),
+	SENSOR(PHY0_COOLING,		"PHY heat sink",	    COOL,  0),
 	SENSOR(PHY1_TEMP,		"PHY temp.",		    TEMP,  1),
-	SENSOR(PHY1_COOLING,		"PHY cooling",		    COOL,  1),
+	SENSOR(PHY1_COOLING,		"PHY heat sink",	    COOL,  1),
 	SENSOR(IN_1V0,			"1.0V supply",		    IN,    -1),
 	SENSOR(IN_1V2,			"1.2V supply",		    IN,    -1),
 	SENSOR(IN_1V8,			"1.8V supply",		    IN,    -1),
@@ -56,34 +56,37 @@ static const struct {
 	SENSOR(IN_3V3,			"3.3V supply",		    IN,    -1),
 	SENSOR(IN_12V0,			"12.0V supply",		    IN,    -1),
 	SENSOR(IN_1V2A,			"1.2V analogue supply",	    IN,    -1),
-	SENSOR(IN_VREF,			"ref. voltage",		    IN,    -1),
-	SENSOR(OUT_VAOE,		"AOE power supply",	    IN,    -1),
-	SENSOR(AOE_TEMP,		"AOE temp.",		    TEMP,  -1),
-	SENSOR(PSU_AOE_TEMP,		"AOE PSU temp.",	    TEMP,  -1),
-	SENSOR(PSU_TEMP,		"Controller PSU temp.",	    TEMP,  -1),
-	SENSOR(FAN_0,			NULL,			    COOL,  -1),
-	SENSOR(FAN_1,			NULL,			    COOL,  -1),
-	SENSOR(FAN_2,			NULL,			    COOL,  -1),
-	SENSOR(FAN_3,			NULL,			    COOL,  -1),
-	SENSOR(FAN_4,			NULL,			    COOL,  -1),
+	SENSOR(IN_VREF,			"Ref. voltage",		    IN,    -1),
+	SENSOR(OUT_VAOE,		"AOE FPGA supply",	    IN,    -1),
+	SENSOR(AOE_TEMP,		"AOE FPGA temp.",	    TEMP,  -1),
+	SENSOR(PSU_AOE_TEMP,		"AOE regulator temp.",	    TEMP,  -1),
+	SENSOR(PSU_TEMP,		"Controller regulator temp.",
+								    TEMP,  -1),
+	SENSOR(FAN_0,			"Fan 0",		    COOL,  -1),
+	SENSOR(FAN_1,			"Fan 1",		    COOL,  -1),
+	SENSOR(FAN_2,			"Fan 2",		    COOL,  -1),
+	SENSOR(FAN_3,			"Fan 3",		    COOL,  -1),
+	SENSOR(FAN_4,			"Fan 4",		    COOL,  -1),
 	SENSOR(IN_VAOE,			"AOE input supply",	    IN,    -1),
 	SENSOR(OUT_IAOE,		"AOE output current",	    CURR,  -1),
 	SENSOR(IN_IAOE,			"AOE input current",	    CURR,  -1),
 	SENSOR(NIC_POWER,		"Board power use",	    POWER, -1),
 	SENSOR(IN_0V9,			"0.9V supply",		    IN,    -1),
-	SENSOR(IN_I0V9,			"0.9V input current",	    CURR,  -1),
-	SENSOR(IN_I1V2,			"1.2V input current",	    CURR,  -1),
-	SENSOR(IN_0V9_ADC,		"0.9V supply (at ADC)",	    IN,    -1),
-	SENSOR(CONTROLLER_2_TEMP,	"Controller ext. temp. 2",  TEMP,  -1),
-	SENSOR(VREG_INTERNAL_TEMP,	"Voltage regulator temp.",  TEMP,  -1),
+	SENSOR(IN_I0V9,			"0.9V supply current",	    CURR,  -1),
+	SENSOR(IN_I1V2,			"1.2V supply current",	    CURR,  -1),
+	SENSOR(IN_0V9_ADC,		"0.9V supply (ext. ADC)",   IN,    -1),
+	SENSOR(CONTROLLER_2_TEMP,	"Controller board temp. 2", TEMP,  -1),
+	SENSOR(VREG_INTERNAL_TEMP,	"Regulator die temp.",	    TEMP,  -1),
 	SENSOR(VREG_0V9_TEMP,		"0.9V regulator temp.",     TEMP,  -1),
 	SENSOR(VREG_1V2_TEMP,		"1.2V regulator temp.",     TEMP,  -1),
-	SENSOR(CONTROLLER_VPTAT,       "Controller int. temp. raw", IN,    -1),
-	SENSOR(CONTROLLER_INTERNAL_TEMP, "Controller int. temp.",   TEMP,  -1),
+	SENSOR(CONTROLLER_VPTAT,
+			      "Controller PTAT voltage (int. ADC)", IN,    -1),
+	SENSOR(CONTROLLER_INTERNAL_TEMP,
+				 "Controller die temp. (int. ADC)", TEMP,  -1),
 	SENSOR(CONTROLLER_VPTAT_EXTADC,
-			      "Controller int. temp. raw (at ADC)", IN,    -1),
+			      "Controller PTAT voltage (ext. ADC)", IN,    -1),
 	SENSOR(CONTROLLER_INTERNAL_TEMP_EXTADC,
-				 "Controller int. temp. (via ADC)", TEMP,  -1),
+				 "Controller die temp. (ext. ADC)", TEMP,  -1),
 	SENSOR(AMBIENT_TEMP,		"Ambient temp.",	    TEMP,  -1),
 	SENSOR(AIRFLOW,			"Air flow raw",		    IN,    -1),
 #undef SENSOR


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
