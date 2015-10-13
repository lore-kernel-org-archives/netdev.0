From: Janusz Wolak <januszwolak@awokados.com.pl>
Subject: [PATCH 5/6] e1000 driver remove checkpatch errors, warnings and checks.
Date: Tue, 13 Oct 2015 23:39:21 +0200
Message-ID: <1444772362-25090-5-git-send-email-januszwolak@awokados.com.pl>
References: <1444772362-25090-1-git-send-email-januszwolak@awokados.com.pl>
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Janusz Wolak <januszvdm@gmail.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from v051823.home.net.pl ([79.96.4.7]:48949 "HELO
	v051823.home.net.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932110AbbJMVqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 17:46:17 -0400
In-Reply-To: <1444772362-25090-1-git-send-email-januszwolak@awokados.com.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Janusz Wolak <januszvdm@gmail.com>

Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
---
 drivers/net/ethernet/intel/e1000/e1000_param.c | 114 ++++++++++++++++++-------
 1 file changed, 82 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_param.c b/drivers/net/ethernet/intel/e1000/e1000_param.c
index c9cde35..9ec730e 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_param.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_param.c
@@ -1,5 +1,5 @@
 /*******************************************************************************
-
+*
   Intel PRO/1000 Linux driver
   Copyright(c) 1999 - 2006 Intel Corporation.
 
@@ -45,10 +45,10 @@
 
 #define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] = OPTION_UNSET }
 #define E1000_PARAM(X, desc) \
-	static int X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
+	static int X[E1000_MAX_NIC + 1] = E1000_PARAM_INIT; \
 	static unsigned int num_##X; \
 	module_param_array_named(X, X, int, &num_##X, 0); \
-	MODULE_PARM_DESC(X, desc);
+	MODULE_PARM_DESC(X, desc)
 
 /* Transmit Descriptor Count
  *
@@ -200,6 +200,7 @@ struct e1000_option {
 		} r;
 		struct { /* list_option info */
 			int nr;
+
 			const struct e1000_opt_list { int i; char *str; } *p;
 		} l;
 	} arg;
@@ -250,7 +251,7 @@ static int e1000_validate_option(unsigned int *value,
 	}
 
 	e_dev_info("Invalid %s value specified (%i) %s\n",
-	       opt->name, *value, opt->err);
+		   opt->name, *value, opt->err);
 	*value = opt->def;
 	return -1;
 }
@@ -291,7 +292,8 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.arg  = { .r = {
 				.min = E1000_MIN_TXD,
 				.max = mac_type < e1000_82544 ? E1000_MAX_TXD : E1000_MAX_82544_TXD
-				}}
+				       }
+				}
 		};
 
 		if (num_TxDescriptors > bd) {
@@ -320,7 +322,8 @@ void e1000_check_options(struct e1000_adapter *adapter)
 				.min = E1000_MIN_RXD,
 				.max = mac_type < e1000_82544 ? E1000_MAX_RXD :
 				       E1000_MAX_82544_RXD
-			}}
+				       }
+				}
 		};
 
 		if (num_RxDescriptors > bd) {
@@ -344,6 +347,7 @@ void e1000_check_options(struct e1000_adapter *adapter)
 
 		if (num_XsumRX > bd) {
 			unsigned int rx_csum = XsumRX[bd];
+
 			e1000_validate_option(&rx_csum, &opt, adapter);
 			adapter->rx_csum = rx_csum;
 		} else {
@@ -366,15 +370,20 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.err  = "reading default settings from EEPROM",
 			.def  = E1000_FC_DEFAULT,
 			.arg  = { .l = { .nr = ARRAY_SIZE(fc_list),
-					 .p = fc_list }}
+					 .p = fc_list
+				       }
+				}
 		};
 
 		if (num_FlowControl > bd) {
 			unsigned int fc = FlowControl[bd];
+
 			e1000_validate_option(&fc, &opt, adapter);
-			adapter->hw.fc = adapter->hw.original_fc = fc;
+			adapter->hw.fc = fc;
+			adapter->hw.original_fc = fc;
 		} else {
-			adapter->hw.fc = adapter->hw.original_fc = opt.def;
+			adapter->hw.fc = opt.def;
+			adapter->hw.original_fc = opt.def;
 		}
 	}
 	{ /* Transmit Interrupt Delay */
@@ -384,13 +393,15 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.err  = "using default of " __MODULE_STRING(DEFAULT_TIDV),
 			.def  = DEFAULT_TIDV,
 			.arg  = { .r = { .min = MIN_TXDELAY,
-					 .max = MAX_TXDELAY }}
+					 .max = MAX_TXDELAY
+				       }
+				}
 		};
 
 		if (num_TxIntDelay > bd) {
 			adapter->tx_int_delay = TxIntDelay[bd];
 			e1000_validate_option(&adapter->tx_int_delay, &opt,
-			                      adapter);
+					      adapter);
 		} else {
 			adapter->tx_int_delay = opt.def;
 		}
@@ -402,7 +413,9 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.err  = "using default of " __MODULE_STRING(DEFAULT_TADV),
 			.def  = DEFAULT_TADV,
 			.arg  = { .r = { .min = MIN_TXABSDELAY,
-					 .max = MAX_TXABSDELAY }}
+					 .max = MAX_TXABSDELAY
+				       }
+				}
 		};
 
 		if (num_TxAbsIntDelay > bd) {
@@ -420,7 +433,9 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.err  = "using default of " __MODULE_STRING(DEFAULT_RDTR),
 			.def  = DEFAULT_RDTR,
 			.arg  = { .r = { .min = MIN_RXDELAY,
-					 .max = MAX_RXDELAY }}
+					 .max = MAX_RXDELAY
+				       }
+				}
 		};
 
 		if (num_RxIntDelay > bd) {
@@ -438,7 +453,9 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.err  = "using default of " __MODULE_STRING(DEFAULT_RADV),
 			.def  = DEFAULT_RADV,
 			.arg  = { .r = { .min = MIN_RXABSDELAY,
-					 .max = MAX_RXABSDELAY }}
+					 .max = MAX_RXABSDELAY
+				       }
+				}
 		};
 
 		if (num_RxAbsIntDelay > bd) {
@@ -456,7 +473,9 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.err  = "using default of " __MODULE_STRING(DEFAULT_ITR),
 			.def  = DEFAULT_ITR,
 			.arg  = { .r = { .min = MIN_ITR,
-					 .max = MAX_ITR }}
+					 .max = MAX_ITR
+				       }
+				}
 		};
 
 		if (num_InterruptThrottleRate > bd) {
@@ -508,6 +527,7 @@ void e1000_check_options(struct e1000_adapter *adapter)
 
 		if (num_SmartPowerDownEnable > bd) {
 			unsigned int spd = SmartPowerDownEnable[bd];
+
 			e1000_validate_option(&spd, &opt, adapter);
 			adapter->smart_power_down = spd;
 		} else {
@@ -537,6 +557,7 @@ void e1000_check_options(struct e1000_adapter *adapter)
 static void e1000_check_fiber_options(struct e1000_adapter *adapter)
 {
 	int bd = adapter->bd_number;
+
 	if (num_Speed > bd) {
 		e_dev_info("Speed not valid for fiber adapters, parameter "
 			   "ignored\n");
@@ -570,7 +591,8 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 			{          0, "" },
 			{   SPEED_10, "" },
 			{  SPEED_100, "" },
-			{ SPEED_1000, "" }};
+			{ SPEED_1000, "" }
+								  };
 
 		opt = (struct e1000_option) {
 			.type = list_option,
@@ -578,7 +600,9 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 			.err  = "parameter ignored",
 			.def  = 0,
 			.arg  = { .l = { .nr = ARRAY_SIZE(speed_list),
-					 .p = speed_list }}
+					 .p = speed_list
+				       }
+				}
 		};
 
 		if (num_Speed > bd) {
@@ -592,7 +616,8 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 		static const struct e1000_opt_list dplx_list[] = {
 			{           0, "" },
 			{ HALF_DUPLEX, "" },
-			{ FULL_DUPLEX, "" }};
+			{ FULL_DUPLEX, "" }
+								 };
 
 		opt = (struct e1000_option) {
 			.type = list_option,
@@ -600,7 +625,9 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 			.err  = "parameter ignored",
 			.def  = 0,
 			.arg  = { .l = { .nr = ARRAY_SIZE(dplx_list),
-					 .p = dplx_list }}
+					 .p = dplx_list
+				       }
+				}
 		};
 
 		if (num_Duplex > bd) {
@@ -648,7 +675,8 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 			 { 0x2c, AA "1000/FD, 100/FD, 100/HD" },
 			 { 0x2d, AA "1000/FD, 100/FD, 100/HD, 10/HD" },
 			 { 0x2e, AA "1000/FD, 100/FD, 100/HD, 10/FD" },
-			 { 0x2f, AA "1000/FD, 100/FD, 100/HD, 10/FD, 10/HD" }};
+			 { 0x2f, AA "1000/FD, 100/FD, 100/HD, 10/FD, 10/HD" }
+			};
 
 		opt = (struct e1000_option) {
 			.type = list_option,
@@ -656,7 +684,9 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 			.err  = "parameter ignored",
 			.def  = AUTONEG_ADV_DEFAULT,
 			.arg  = { .l = { .nr = ARRAY_SIZE(an_list),
-					 .p = an_list }}
+					 .p = an_list
+				       }
+				}
 		};
 
 		if (num_AutoNeg > bd) {
@@ -670,7 +700,9 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 
 	switch (speed + dplx) {
 	case 0:
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		adapter->hw.autoneg = 1;
+		adapter->fc_autoneg = 1;
+
 		if ((num_Speed > bd) && (speed != 0 || dplx != 0))
 			e_dev_info("Speed and duplex autonegotiation "
 				   "enabled\n");
@@ -678,14 +710,18 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 	case HALF_DUPLEX:
 		e_dev_info("Half Duplex specified without Speed\n");
 		e_dev_info("Using Autonegotiation at Half Duplex only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		adapter->hw.autoneg = 1;
+		adapter->fc_autoneg = 1;
+
 		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
 						 ADVERTISE_100_HALF;
 		break;
 	case FULL_DUPLEX:
 		e_dev_info("Full Duplex specified without Speed\n");
 		e_dev_info("Using Autonegotiation at Full Duplex only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		adapter->hw.autoneg = 1;
+		adapter->fc_autoneg = 1;
+
 		adapter->hw.autoneg_advertised = ADVERTISE_10_FULL |
 						 ADVERTISE_100_FULL |
 						 ADVERTISE_1000_FULL;
@@ -693,38 +729,50 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 	case SPEED_10:
 		e_dev_info("10 Mbps Speed specified without Duplex\n");
 		e_dev_info("Using Autonegotiation at 10 Mbps only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		adapter->hw.autoneg = 1;
+		adapter->fc_autoneg = 1;
+
 		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
 						 ADVERTISE_10_FULL;
 		break;
 	case SPEED_10 + HALF_DUPLEX:
 		e_dev_info("Forcing to 10 Mbps Half Duplex\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 0;
+		adapter->hw.autoneg = 0;
+		adapter->fc_autoneg = 0;
+
 		adapter->hw.forced_speed_duplex = e1000_10_half;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_10 + FULL_DUPLEX:
 		e_dev_info("Forcing to 10 Mbps Full Duplex\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 0;
+		adapter->hw.autoneg = 0;
+		adapter->fc_autoneg = 0;
+
 		adapter->hw.forced_speed_duplex = e1000_10_full;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_100:
 		e_dev_info("100 Mbps Speed specified without Duplex\n");
 		e_dev_info("Using Autonegotiation at 100 Mbps only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		adapter->hw.autoneg = 1;
+		adapter->fc_autoneg = 1;
+
 		adapter->hw.autoneg_advertised = ADVERTISE_100_HALF |
 						 ADVERTISE_100_FULL;
 		break;
 	case SPEED_100 + HALF_DUPLEX:
 		e_dev_info("Forcing to 100 Mbps Half Duplex\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 0;
+		adapter->hw.autoneg = 0;
+		adapter->fc_autoneg = 0;
+
 		adapter->hw.forced_speed_duplex = e1000_100_half;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_100 + FULL_DUPLEX:
 		e_dev_info("Forcing to 100 Mbps Full Duplex\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 0;
+		adapter->hw.autoneg = 0;
+		adapter->fc_autoneg = 0;
+
 		adapter->hw.forced_speed_duplex = e1000_100_full;
 		adapter->hw.autoneg_advertised = 0;
 		break;
@@ -738,7 +786,9 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 full_duplex_only:
 		e_dev_info("Using Autonegotiation at 1000 Mbps Full Duplex "
 			   "only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		adapter->hw.autoneg = 1;
+		adapter->fc_autoneg = 1;
+
 		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
 		break;
 	default:
@@ -746,7 +796,7 @@ full_duplex_only:
 	}
 
 	/* Speed, AutoNeg and MDI/MDI-X must all play nice */
-	if (e1000_validate_mdi_setting(&(adapter->hw)) < 0) {
+	if (e1000_validate_mdi_setting(&adapter->hw) < 0) {
 		e_dev_info("Speed, AutoNeg and MDI-X specs are incompatible. "
 			   "Setting MDI-X to a compatible value.\n");
 	}
-- 
1.9.1
