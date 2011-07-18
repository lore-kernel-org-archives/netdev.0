From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 04/45] bna: State Machine Fault Handling Cleanup
Date: Mon, 18 Jul 2011 01:19:32 -0700
Message-ID: <1310977178-312-5-git-send-email-rmody@brocade.com>
References: <1310977178-312-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48163 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753537Ab1GRIUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:20:30 -0400
In-Reply-To: <1310977178-312-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chnage details:
 - The module name is not used in case of state machine fault, hence no longer
   passing the module name to the fault handler.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c  |   46 ++++++++++++++++++++++----------------------
 drivers/net/bna/bna_ctrl.c |   42 ++++++++++++++++++++--------------------
 drivers/net/bna/bna_txrx.c |   38 ++++++++++++++++++------------------
 drivers/net/bna/cna.h      |    2 +-
 4 files changed, 64 insertions(+), 64 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index c52ef63..a13b4c5 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -240,7 +240,7 @@ bfa_ioc_sm_uninit(struct bfa_ioc *ioc, enum ioc_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -273,7 +273,7 @@ bfa_ioc_sm_reset(struct bfa_ioc *ioc, enum ioc_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -317,7 +317,7 @@ bfa_ioc_sm_enabling(struct bfa_ioc *ioc, enum ioc_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -365,7 +365,7 @@ bfa_ioc_sm_getattr(struct bfa_ioc *ioc, enum ioc_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -404,7 +404,7 @@ bfa_ioc_sm_op(struct bfa_ioc *ioc, enum ioc_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -435,7 +435,7 @@ bfa_ioc_sm_disabling(struct bfa_ioc *ioc, enum ioc_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -466,7 +466,7 @@ bfa_ioc_sm_disabled(struct bfa_ioc *ioc, enum ioc_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -513,7 +513,7 @@ bfa_ioc_sm_fail_retry(struct bfa_ioc *ioc, enum ioc_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -547,7 +547,7 @@ bfa_ioc_sm_fail(struct bfa_ioc *ioc, enum ioc_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -580,7 +580,7 @@ bfa_iocpf_sm_reset(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(iocpf->ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -632,7 +632,7 @@ bfa_iocpf_sm_fwcheck(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -676,7 +676,7 @@ bfa_iocpf_sm_mismatch(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -715,7 +715,7 @@ bfa_iocpf_sm_semwait(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -763,7 +763,7 @@ bfa_iocpf_sm_hwinit(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -814,7 +814,7 @@ bfa_iocpf_sm_enabling(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -857,7 +857,7 @@ bfa_iocpf_sm_ready(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -899,7 +899,7 @@ bfa_iocpf_sm_disabling(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -928,7 +928,7 @@ bfa_iocpf_sm_disabling_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -958,7 +958,7 @@ bfa_iocpf_sm_disabled(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1010,7 +1010,7 @@ bfa_iocpf_sm_initfail_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1039,7 +1039,7 @@ bfa_iocpf_sm_initfail(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1094,7 +1094,7 @@ bfa_iocpf_sm_fail_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1116,7 +1116,7 @@ bfa_iocpf_sm_fail(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(iocpf->ioc, event);
+		bfa_sm_fault(event);
 	}
 }
 
diff --git a/drivers/net/bna/bna_ctrl.c b/drivers/net/bna/bna_ctrl.c
index 53b1416..7d9bc2f 100644
--- a/drivers/net/bna/bna_ctrl.c
+++ b/drivers/net/bna/bna_ctrl.c
@@ -380,7 +380,7 @@ bna_llport_sm_stopped(struct bna_llport *llport,
 		break;
 
 	default:
-		bfa_sm_fault(llport->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -409,7 +409,7 @@ bna_llport_sm_down(struct bna_llport *llport,
 		break;
 
 	default:
-		bfa_sm_fault(llport->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -455,7 +455,7 @@ bna_llport_sm_up_resp_wait(struct bna_llport *llport,
 		break;
 
 	default:
-		bfa_sm_fault(llport->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -497,7 +497,7 @@ bna_llport_sm_down_resp_wait(struct bna_llport *llport,
 		break;
 
 	default:
-		bfa_sm_fault(llport->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -526,7 +526,7 @@ bna_llport_sm_up(struct bna_llport *llport,
 		break;
 
 	default:
-		bfa_sm_fault(llport->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -563,7 +563,7 @@ bna_llport_sm_last_resp_wait(struct bna_llport *llport,
 		break;
 
 	default:
-		bfa_sm_fault(llport->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -916,7 +916,7 @@ bna_port_sm_stopped(struct bna_port *port, enum bna_port_event event)
 		break;
 
 	default:
-		bfa_sm_fault(port->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -956,7 +956,7 @@ bna_port_sm_mtu_init_wait(struct bna_port *port, enum bna_port_event event)
 		break;
 
 	default:
-		bfa_sm_fault(port->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1001,7 +1001,7 @@ bna_port_sm_pause_init_wait(struct bna_port *port,
 		break;
 
 	default:
-		bfa_sm_fault(port->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1022,7 +1022,7 @@ bna_port_sm_last_resp_wait(struct bna_port *port,
 		break;
 
 	default:
-		bfa_sm_fault(port->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1061,7 +1061,7 @@ bna_port_sm_started(struct bna_port *port,
 		break;
 
 	default:
-		bfa_sm_fault(port->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1086,7 +1086,7 @@ bna_port_sm_pause_cfg_wait(struct bna_port *port,
 		break;
 
 	default:
-		bfa_sm_fault(port->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1111,7 +1111,7 @@ bna_port_sm_rx_stop_wait(struct bna_port *port,
 		break;
 
 	default:
-		bfa_sm_fault(port->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1136,7 +1136,7 @@ bna_port_sm_mtu_cfg_wait(struct bna_port *port, enum bna_port_event event)
 		break;
 
 	default:
-		bfa_sm_fault(port->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1161,7 +1161,7 @@ bna_port_sm_chld_stop_wait(struct bna_port *port,
 		break;
 
 	default:
-		bfa_sm_fault(port->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1472,7 +1472,7 @@ bna_device_sm_stopped(struct bna_device *device,
 		break;
 
 	default:
-		bfa_sm_fault(device->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1512,7 +1512,7 @@ bna_device_sm_ioc_ready_wait(struct bna_device *device,
 		break;
 
 	default:
-		bfa_sm_fault(device->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1542,7 +1542,7 @@ bna_device_sm_ready(struct bna_device *device, enum bna_device_event event)
 		break;
 
 	default:
-		bfa_sm_fault(device->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1568,7 +1568,7 @@ bna_device_sm_port_stop_wait(struct bna_device *device,
 		break;
 
 	default:
-		bfa_sm_fault(device->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1589,7 +1589,7 @@ bna_device_sm_ioc_disable_wait(struct bna_device *device,
 		break;
 
 	default:
-		bfa_sm_fault(device->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1622,7 +1622,7 @@ bna_device_sm_failed(struct bna_device *device,
 		break;
 
 	default:
-		bfa_sm_fault(device->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
diff --git a/drivers/net/bna/bna_txrx.c b/drivers/net/bna/bna_txrx.c
index 2c06e08..4d4f4d9 100644
--- a/drivers/net/bna/bna_txrx.c
+++ b/drivers/net/bna/bna_txrx.c
@@ -569,7 +569,7 @@ bna_rxf_sm_stopped(struct bna_rxf *rxf, enum bna_rxf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(rxf->rx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -627,7 +627,7 @@ bna_rxf_sm_start_wait(struct bna_rxf *rxf, enum bna_rxf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(rxf->rx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -678,7 +678,7 @@ bna_rxf_sm_cam_fltr_mod_wait(struct bna_rxf *rxf, enum bna_rxf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(rxf->rx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -724,7 +724,7 @@ bna_rxf_sm_started(struct bna_rxf *rxf, enum bna_rxf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(rxf->rx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -761,7 +761,7 @@ bna_rxf_sm_cam_fltr_clr_wait(struct bna_rxf *rxf, enum bna_rxf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(rxf->rx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -815,7 +815,7 @@ bna_rxf_sm_stop_wait(struct bna_rxf *rxf, enum bna_rxf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(rxf->rx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -851,7 +851,7 @@ bna_rxf_sm_pause_wait(struct bna_rxf *rxf, enum bna_rxf_event event)
 	 * any other event during these states
 	 */
 	default:
-		bfa_sm_fault(rxf->rx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -887,7 +887,7 @@ bna_rxf_sm_resume_wait(struct bna_rxf *rxf, enum bna_rxf_event event)
 	 * any other event during these states
 	 */
 	default:
-		bfa_sm_fault(rxf->rx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -907,7 +907,7 @@ bna_rxf_sm_stat_clr_wait(struct bna_rxf *rxf, enum bna_rxf_event event)
 		break;
 
 	default:
-		bfa_sm_fault(rxf->rx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -1898,7 +1898,7 @@ static void bna_rx_sm_stopped(struct bna_rx *rx,
 		/* no-op */
 		break;
 	default:
-		bfa_sm_fault(rx->bna, event);
+		bfa_sm_fault(event);
 		break;
 	}
 
@@ -1946,7 +1946,7 @@ static void bna_rx_sm_rxf_start_wait(struct bna_rx *rx,
 		bfa_fsm_set_state(rx, bna_rx_sm_started);
 		break;
 	default:
-		bfa_sm_fault(rx->bna, event);
+		bfa_sm_fault(event);
 		break;
 	}
 }
@@ -1981,7 +1981,7 @@ bna_rx_sm_started(struct bna_rx *rx, enum bna_rx_event event)
 		bfa_fsm_set_state(rx, bna_rx_sm_rxf_stop_wait);
 		break;
 	default:
-		bfa_sm_fault(rx->bna, event);
+		bfa_sm_fault(event);
 		break;
 	}
 }
@@ -2011,7 +2011,7 @@ bna_rx_sm_rxf_stop_wait(struct bna_rx *rx, enum bna_rx_event event)
 		bna_rxf_fail(&rx->rxf);
 		break;
 	default:
-		bfa_sm_fault(rx->bna, event);
+		bfa_sm_fault(event);
 		break;
 	}
 
@@ -2064,7 +2064,7 @@ bna_rx_sm_rxq_stop_wait(struct bna_rx *rx, enum bna_rx_event event)
 		bfa_fsm_set_state(rx, bna_rx_sm_stopped);
 		break;
 	default:
-		bfa_sm_fault(rx->bna, event);
+		bfa_sm_fault(event);
 		break;
 	}
 }
@@ -3216,7 +3216,7 @@ bna_tx_sm_stopped(struct bna_tx *tx, enum bna_tx_event event)
 		break;
 
 	default:
-		bfa_sm_fault(tx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -3261,7 +3261,7 @@ bna_tx_sm_started(struct bna_tx *tx, enum bna_tx_event event)
 		break;
 
 	default:
-		bfa_sm_fault(tx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -3294,7 +3294,7 @@ bna_tx_sm_txq_stop_wait(struct bna_tx *tx, enum bna_tx_event event)
 		break;
 
 	default:
-		bfa_sm_fault(tx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -3335,7 +3335,7 @@ bna_tx_sm_prio_stop_wait(struct bna_tx *tx, enum bna_tx_event event)
 		break;
 
 	default:
-		bfa_sm_fault(tx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
@@ -3355,7 +3355,7 @@ bna_tx_sm_stat_clr_wait(struct bna_tx *tx, enum bna_tx_event event)
 		break;
 
 	default:
-		bfa_sm_fault(tx->bna, event);
+		bfa_sm_fault(event);
 	}
 }
 
diff --git a/drivers/net/bna/cna.h b/drivers/net/bna/cna.h
index 01b4af7..a679e03 100644
--- a/drivers/net/bna/cna.h
+++ b/drivers/net/bna/cna.h
@@ -33,7 +33,7 @@
 
 #include <linux/list.h>
 
-#define bfa_sm_fault(__mod, __event)    do {                            \
+#define bfa_sm_fault(__event)    do {                            \
 	pr_err("SM Assertion failure: %s: %d: event = %d", __FILE__, __LINE__, \
 		__event); \
 } while (0)
-- 
1.7.1

