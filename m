From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 4/6] ucc_geth: Cleanup repetitive ucc_geth_memclean() calls
Date: Thu, 18 Dec 2008 21:23:31 +0300
Message-ID: <20081218182331.GD30682@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Cc: David Miller <davem@davemloft.net>, Li Yang <leoli@freescale.com>,
	Timur Tabi <timur@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:26594 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752295AbYLRSXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 13:23:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to call ucc_geth_memclean() so many times, just check for
errors in ucc_geth_open(), and call ucc_geth_stop() in case of errors.

The ucc_geth_stop() may be called anytime and will do the right thing.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |   31 +------------------------------
 1 files changed, 1 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 1ba2855..70208c6 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2420,7 +2420,6 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	if (ucc_fast_init(uf_info, &ugeth->uccf)) {
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: Failed to init uccf.", __func__);
-		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
 
@@ -2476,7 +2475,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Bad number of Rx threads value.",
 				       	__func__);
-		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 		break;
 	}
@@ -2501,7 +2499,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Bad number of Tx threads value.",
 				       	__func__);
-		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 		break;
 	}
@@ -2555,7 +2552,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: IPGIFG initialization parameter too large.",
 				  __func__);
-		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
 
@@ -2573,7 +2569,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Half Duplex initialization parameter too large.",
 			  __func__);
-		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
 
@@ -2628,7 +2623,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				ugeth_err
 				    ("%s: Can not allocate memory for Tx bd rings.",
 				     __func__);
-			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
 		/* Zero unused end of bd ring, according to spec */
@@ -2664,7 +2658,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				ugeth_err
 				    ("%s: Can not allocate memory for Rx bd rings.",
 				     __func__);
-			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
 	}
@@ -2680,7 +2673,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Could not allocate tx_skbuff",
 					  __func__);
-			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
 
@@ -2712,7 +2704,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Could not allocate rx_skbuff",
 					  __func__);
-			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
 
@@ -2746,7 +2737,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_tx_glbl_pram.",
 			     __func__);
-		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
 	ugeth->p_tx_glbl_pram =
@@ -2769,7 +2759,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_thread_data_tx.",
 			     __func__);
-		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
 
@@ -2799,7 +2788,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_send_q_mem_reg.",
 			     __func__);
-		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
 
@@ -2843,7 +2831,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				ugeth_err
 				 ("%s: Can not allocate DPRAM memory for p_scheduler.",
 				     __func__);
-			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
 
@@ -2894,7 +2881,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				    ("%s: Can not allocate DPRAM memory for"
 					" p_tx_fw_statistics_pram.",
 				       	__func__);
-			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
 		ugeth->p_tx_fw_statistics_pram =
@@ -2934,7 +2920,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_rx_glbl_pram.",
 			     __func__);
-		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
 	ugeth->p_rx_glbl_pram =
@@ -2956,7 +2941,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_thread_data_rx.",
 			     __func__);
-		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
 
@@ -2980,7 +2964,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				ugeth_err
 					("%s: Can not allocate DPRAM memory for"
 					" p_rx_fw_statistics_pram.", __func__);
-			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
 		ugeth->p_rx_fw_statistics_pram =
@@ -3003,7 +2986,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for"
 				" p_rx_irq_coalescing_tbl.", __func__);
-		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
 
@@ -3072,7 +3054,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_rx_bd_qs_tbl.",
 			     __func__);
-		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
 
@@ -3149,7 +3130,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Null Extended Filtering Chain Pointer.",
 					  __func__);
-			ucc_geth_memclean(ugeth);
 			return -EINVAL;
 		}
 
@@ -3163,7 +3143,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				ugeth_err
 					("%s: Can not allocate DPRAM memory for"
 					" p_exf_glbl_param.", __func__);
-			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
 
@@ -3211,7 +3190,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth_err
 			    ("%s: Can not allocate memory for"
 				" p_UccInitEnetParamShadows.", __func__);
-		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
 	/* Zero out *p_init_enet_param_shadow */
@@ -3246,7 +3224,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Invalid largest External Lookup Key Size.",
 				  __func__);
-		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 	}
 	ugeth->p_init_enet_param_shadow->largestexternallookupkeysize =
@@ -3273,7 +3250,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
 					__func__);
-		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
 
@@ -3289,7 +3265,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
 				  __func__);
-		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
 
@@ -3299,7 +3274,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Can not fill Rx bds with buffers.",
 					  __func__);
-			ucc_geth_memclean(ugeth);
 			return ret_val;
 		}
 	}
@@ -3311,7 +3285,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_init_enet_pram.",
 			     __func__);
-		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
 	p_init_enet_pram =
@@ -3763,7 +3736,6 @@ static int ucc_geth_open(struct net_device *dev)
 	if (err) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Cannot enable net device, aborting.", dev->name);
-		ucc_geth_stop(ugeth);
 		goto out_err;
 	}
 
@@ -3773,7 +3745,6 @@ static int ucc_geth_open(struct net_device *dev)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Cannot get IRQ for net device, aborting.",
 				  dev->name);
-		ucc_geth_stop(ugeth);
 		goto out_err;
 	}
 
@@ -3783,7 +3754,7 @@ static int ucc_geth_open(struct net_device *dev)
 
 out_err:
 	napi_disable(&ugeth->napi);
-
+	ucc_geth_stop(ugeth);
 	return err;
 }
 
-- 
1.5.6.5

