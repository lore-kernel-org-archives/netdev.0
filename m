From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Mon, 17 Mar 2008 08:23:04 -0400
Message-ID: <20080317122304.GA22001@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754027AbYCQMX1@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Notes:

1) This includes a drivers/atm patch from Al (I don't usually take
drivers/atm patches, but it came straight to me)

2) the drivers/sn change came from the maintainer, so it seemed fine to
push it this way, along with the drivers/net/ioc3-eth changes

3) the forcedeth change is a critical fix


Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 drivers/atm/fore200e.c         |  110 +++++++++++++++++++-------------------
 drivers/atm/fore200e.h         |  106 ++++++++++++++++++------------------
 drivers/net/3c501.c            |   16 +++---
 drivers/net/atl1/atl1_main.c   |    3 -
 drivers/net/cxgb3/sge.c        |   12 +++-
 drivers/net/epic100.c          |   47 +++++++++-------
 drivers/net/forcedeth.c        |  118 ++++++++++++++++++++++++++++++++++------
 drivers/net/ibm_newemac/core.c |    7 +++
 drivers/net/ibm_newemac/tah.c  |    4 ++
 drivers/net/igb/igb_main.c     |   21 ++++++--
 drivers/net/ioc3-eth.c         |    3 +-
 drivers/net/ipg.c              |   10 ++--
 drivers/net/ne2k-pci.c         |    8 ++--
 drivers/net/r6040.c            |   10 ++--
 drivers/net/tulip/de2104x.c    |   10 +++-
 drivers/net/ucc_geth.c         |    6 ++-
 drivers/net/usb/rndis_host.c   |   12 +++--
 drivers/net/wan/farsync.c      |   17 ++++--
 drivers/sn/ioc3.c              |   22 ++++----
 19 files changed, 341 insertions(+), 201 deletions(-)

Al Viro (6):
      r6040 endianness fixes
      wan/farsync: copy_from_user() to iomem is wrong
      fore2000 - fix misannotations
      more misannotations: ne2k-pci
      ipg fix
      epic100 endianness annotations and fixes

Alan Cox (1):
      3c501: Further coding style fixes

Ayaz Abdulla (1):
      forcedeth: limit tx to 16

Divy Le Ray (1):
      cxgb3: Fix transmit queue stop mechanism

Grant Grundler (1):
      2.6.25-rc4 de_stop_rxtx polling wrong

Harvey Harrison (1):
      ioc3.c: replace remaining __FUNCTION__ occurrences

Jean-Christophe Dubois (1):
      rndis_host: fix transfer size negotiation

Joakim Tjernlund (1):
      ucc_geth: use correct thread number for 10/100Mbps link

Julia Lawall (2):
      drivers/net/ipg.c: remove unused variable
      drivers/net/atl1/atl1_main.c: remove unused variable

Mitch Williams (1):
      igb: Correctly get protocol information

Pravin M. Bathija (1):
      NEWEMAC: fix support for pause packets

Ralf Baechle (1):
      [IOC3] Fix section missmatch

Stefan Roese (1):
      NEWEMAC: Add compatible "ibm,tah" to tah matching table

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 9427a61..432181e 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -1988,19 +1988,19 @@ fore200e_fetch_stats(struct fore200e* fore200e, struct sonet_stats __user *arg)
     if (fore200e_getstats(fore200e) < 0)
 	return -EIO;
 
-    tmp.section_bip = cpu_to_be32(fore200e->stats->oc3.section_bip8_errors);
-    tmp.line_bip    = cpu_to_be32(fore200e->stats->oc3.line_bip24_errors);
-    tmp.path_bip    = cpu_to_be32(fore200e->stats->oc3.path_bip8_errors);
-    tmp.line_febe   = cpu_to_be32(fore200e->stats->oc3.line_febe_errors);
-    tmp.path_febe   = cpu_to_be32(fore200e->stats->oc3.path_febe_errors);
-    tmp.corr_hcs    = cpu_to_be32(fore200e->stats->oc3.corr_hcs_errors);
-    tmp.uncorr_hcs  = cpu_to_be32(fore200e->stats->oc3.ucorr_hcs_errors);
-    tmp.tx_cells    = cpu_to_be32(fore200e->stats->aal0.cells_transmitted)  +
-	              cpu_to_be32(fore200e->stats->aal34.cells_transmitted) +
-	              cpu_to_be32(fore200e->stats->aal5.cells_transmitted);
-    tmp.rx_cells    = cpu_to_be32(fore200e->stats->aal0.cells_received)     +
-	              cpu_to_be32(fore200e->stats->aal34.cells_received)    +
-	              cpu_to_be32(fore200e->stats->aal5.cells_received);
+    tmp.section_bip = be32_to_cpu(fore200e->stats->oc3.section_bip8_errors);
+    tmp.line_bip    = be32_to_cpu(fore200e->stats->oc3.line_bip24_errors);
+    tmp.path_bip    = be32_to_cpu(fore200e->stats->oc3.path_bip8_errors);
+    tmp.line_febe   = be32_to_cpu(fore200e->stats->oc3.line_febe_errors);
+    tmp.path_febe   = be32_to_cpu(fore200e->stats->oc3.path_febe_errors);
+    tmp.corr_hcs    = be32_to_cpu(fore200e->stats->oc3.corr_hcs_errors);
+    tmp.uncorr_hcs  = be32_to_cpu(fore200e->stats->oc3.ucorr_hcs_errors);
+    tmp.tx_cells    = be32_to_cpu(fore200e->stats->aal0.cells_transmitted)  +
+	              be32_to_cpu(fore200e->stats->aal34.cells_transmitted) +
+	              be32_to_cpu(fore200e->stats->aal5.cells_transmitted);
+    tmp.rx_cells    = be32_to_cpu(fore200e->stats->aal0.cells_received)     +
+	              be32_to_cpu(fore200e->stats->aal34.cells_received)    +
+	              be32_to_cpu(fore200e->stats->aal5.cells_received);
 
     if (arg)
 	return copy_to_user(arg, &tmp, sizeof(struct sonet_stats)) ? -EFAULT : 0;	
@@ -2587,7 +2587,7 @@ fore200e_start_fw(struct fore200e* fore200e)
 static int __devinit
 fore200e_load_fw(struct fore200e* fore200e)
 {
-    u32* fw_data = (u32*) fore200e->bus->fw_data;
+    __le32* fw_data = (__le32*) fore200e->bus->fw_data;
     u32  fw_size = (u32) *fore200e->bus->fw_size / sizeof(u32);
 
     struct fw_header* fw_header = (struct fw_header*) fw_data;
@@ -2965,8 +2965,8 @@ fore200e_proc_read(struct atm_dev *dev, loff_t* pos, char* page)
 		       "  4b5b:\n"
 		       "     crc_header_errors:\t\t%10u\n"
 		       "     framing_errors:\t\t%10u\n",
-		       cpu_to_be32(fore200e->stats->phy.crc_header_errors),
-		       cpu_to_be32(fore200e->stats->phy.framing_errors));
+		       be32_to_cpu(fore200e->stats->phy.crc_header_errors),
+		       be32_to_cpu(fore200e->stats->phy.framing_errors));
     
     if (!left--)
 	return sprintf(page, "\n"
@@ -2978,13 +2978,13 @@ fore200e_proc_read(struct atm_dev *dev, loff_t* pos, char* page)
 		       "     path_febe_errors:\t\t%10u\n"
 		       "     corr_hcs_errors:\t\t%10u\n"
 		       "     ucorr_hcs_errors:\t\t%10u\n",
-		       cpu_to_be32(fore200e->stats->oc3.section_bip8_errors),
-		       cpu_to_be32(fore200e->stats->oc3.path_bip8_errors),
-		       cpu_to_be32(fore200e->stats->oc3.line_bip24_errors),
-		       cpu_to_be32(fore200e->stats->oc3.line_febe_errors),
-		       cpu_to_be32(fore200e->stats->oc3.path_febe_errors),
-		       cpu_to_be32(fore200e->stats->oc3.corr_hcs_errors),
-		       cpu_to_be32(fore200e->stats->oc3.ucorr_hcs_errors));
+		       be32_to_cpu(fore200e->stats->oc3.section_bip8_errors),
+		       be32_to_cpu(fore200e->stats->oc3.path_bip8_errors),
+		       be32_to_cpu(fore200e->stats->oc3.line_bip24_errors),
+		       be32_to_cpu(fore200e->stats->oc3.line_febe_errors),
+		       be32_to_cpu(fore200e->stats->oc3.path_febe_errors),
+		       be32_to_cpu(fore200e->stats->oc3.corr_hcs_errors),
+		       be32_to_cpu(fore200e->stats->oc3.ucorr_hcs_errors));
 
     if (!left--)
 	return sprintf(page,"\n"
@@ -2995,12 +2995,12 @@ fore200e_proc_read(struct atm_dev *dev, loff_t* pos, char* page)
 		       "     vpi no conn:\t\t%10u\n"
 		       "     vci out of range:\t\t%10u\n"
 		       "     vci no conn:\t\t%10u\n",
-		       cpu_to_be32(fore200e->stats->atm.cells_transmitted),
-		       cpu_to_be32(fore200e->stats->atm.cells_received),
-		       cpu_to_be32(fore200e->stats->atm.vpi_bad_range),
-		       cpu_to_be32(fore200e->stats->atm.vpi_no_conn),
-		       cpu_to_be32(fore200e->stats->atm.vci_bad_range),
-		       cpu_to_be32(fore200e->stats->atm.vci_no_conn));
+		       be32_to_cpu(fore200e->stats->atm.cells_transmitted),
+		       be32_to_cpu(fore200e->stats->atm.cells_received),
+		       be32_to_cpu(fore200e->stats->atm.vpi_bad_range),
+		       be32_to_cpu(fore200e->stats->atm.vpi_no_conn),
+		       be32_to_cpu(fore200e->stats->atm.vci_bad_range),
+		       be32_to_cpu(fore200e->stats->atm.vci_no_conn));
     
     if (!left--)
 	return sprintf(page,"\n"
@@ -3008,9 +3008,9 @@ fore200e_proc_read(struct atm_dev *dev, loff_t* pos, char* page)
 		       "     TX:\t\t\t%10u\n"
 		       "     RX:\t\t\t%10u\n"
 		       "     dropped:\t\t\t%10u\n",
-		       cpu_to_be32(fore200e->stats->aal0.cells_transmitted),
-		       cpu_to_be32(fore200e->stats->aal0.cells_received),
-		       cpu_to_be32(fore200e->stats->aal0.cells_dropped));
+		       be32_to_cpu(fore200e->stats->aal0.cells_transmitted),
+		       be32_to_cpu(fore200e->stats->aal0.cells_received),
+		       be32_to_cpu(fore200e->stats->aal0.cells_dropped));
     
     if (!left--)
 	return sprintf(page,"\n"
@@ -3026,15 +3026,15 @@ fore200e_proc_read(struct atm_dev *dev, loff_t* pos, char* page)
 		       "       RX:\t\t\t%10u\n"
 		       "       dropped:\t\t\t%10u\n"
 		       "       protocol errors:\t\t%10u\n",
-		       cpu_to_be32(fore200e->stats->aal34.cells_transmitted),
-		       cpu_to_be32(fore200e->stats->aal34.cells_received),
-		       cpu_to_be32(fore200e->stats->aal34.cells_dropped),
-		       cpu_to_be32(fore200e->stats->aal34.cells_crc_errors),
-		       cpu_to_be32(fore200e->stats->aal34.cells_protocol_errors),
-		       cpu_to_be32(fore200e->stats->aal34.cspdus_transmitted),
-		       cpu_to_be32(fore200e->stats->aal34.cspdus_received),
-		       cpu_to_be32(fore200e->stats->aal34.cspdus_dropped),
-		       cpu_to_be32(fore200e->stats->aal34.cspdus_protocol_errors));
+		       be32_to_cpu(fore200e->stats->aal34.cells_transmitted),
+		       be32_to_cpu(fore200e->stats->aal34.cells_received),
+		       be32_to_cpu(fore200e->stats->aal34.cells_dropped),
+		       be32_to_cpu(fore200e->stats->aal34.cells_crc_errors),
+		       be32_to_cpu(fore200e->stats->aal34.cells_protocol_errors),
+		       be32_to_cpu(fore200e->stats->aal34.cspdus_transmitted),
+		       be32_to_cpu(fore200e->stats->aal34.cspdus_received),
+		       be32_to_cpu(fore200e->stats->aal34.cspdus_dropped),
+		       be32_to_cpu(fore200e->stats->aal34.cspdus_protocol_errors));
     
     if (!left--)
 	return sprintf(page,"\n"
@@ -3050,15 +3050,15 @@ fore200e_proc_read(struct atm_dev *dev, loff_t* pos, char* page)
 		       "       dropped:\t\t\t%10u\n"
 		       "       CRC errors:\t\t%10u\n"
 		       "       protocol errors:\t\t%10u\n",
-		       cpu_to_be32(fore200e->stats->aal5.cells_transmitted),
-		       cpu_to_be32(fore200e->stats->aal5.cells_received),
-		       cpu_to_be32(fore200e->stats->aal5.cells_dropped),
-		       cpu_to_be32(fore200e->stats->aal5.congestion_experienced),
-		       cpu_to_be32(fore200e->stats->aal5.cspdus_transmitted),
-		       cpu_to_be32(fore200e->stats->aal5.cspdus_received),
-		       cpu_to_be32(fore200e->stats->aal5.cspdus_dropped),
-		       cpu_to_be32(fore200e->stats->aal5.cspdus_crc_errors),
-		       cpu_to_be32(fore200e->stats->aal5.cspdus_protocol_errors));
+		       be32_to_cpu(fore200e->stats->aal5.cells_transmitted),
+		       be32_to_cpu(fore200e->stats->aal5.cells_received),
+		       be32_to_cpu(fore200e->stats->aal5.cells_dropped),
+		       be32_to_cpu(fore200e->stats->aal5.congestion_experienced),
+		       be32_to_cpu(fore200e->stats->aal5.cspdus_transmitted),
+		       be32_to_cpu(fore200e->stats->aal5.cspdus_received),
+		       be32_to_cpu(fore200e->stats->aal5.cspdus_dropped),
+		       be32_to_cpu(fore200e->stats->aal5.cspdus_crc_errors),
+		       be32_to_cpu(fore200e->stats->aal5.cspdus_protocol_errors));
     
     if (!left--)
 	return sprintf(page,"\n"
@@ -3069,11 +3069,11 @@ fore200e_proc_read(struct atm_dev *dev, loff_t* pos, char* page)
 		       "     large b2:\t\t\t%10u\n"
 		       "     RX PDUs:\t\t\t%10u\n"
 		       "     TX PDUs:\t\t\t%10lu\n",
-		       cpu_to_be32(fore200e->stats->aux.small_b1_failed),
-		       cpu_to_be32(fore200e->stats->aux.large_b1_failed),
-		       cpu_to_be32(fore200e->stats->aux.small_b2_failed),
-		       cpu_to_be32(fore200e->stats->aux.large_b2_failed),
-		       cpu_to_be32(fore200e->stats->aux.rpd_alloc_failed),
+		       be32_to_cpu(fore200e->stats->aux.small_b1_failed),
+		       be32_to_cpu(fore200e->stats->aux.large_b1_failed),
+		       be32_to_cpu(fore200e->stats->aux.small_b2_failed),
+		       be32_to_cpu(fore200e->stats->aux.large_b2_failed),
+		       be32_to_cpu(fore200e->stats->aux.rpd_alloc_failed),
 		       fore200e->tx_sat);
     
     if (!left--)
diff --git a/drivers/atm/fore200e.h b/drivers/atm/fore200e.h
index b85a546..183841c 100644
--- a/drivers/atm/fore200e.h
+++ b/drivers/atm/fore200e.h
@@ -349,90 +349,90 @@ typedef struct oc3_block {
 /* physical encoding statistics */
 
 typedef struct stats_phy {
-    u32 crc_header_errors;    /* cells received with bad header CRC */
-    u32 framing_errors;       /* cells received with bad framing    */
-    u32 pad[ 2 ];             /* i960 padding                       */
+    __be32 crc_header_errors;    /* cells received with bad header CRC */
+    __be32 framing_errors;       /* cells received with bad framing    */
+    __be32 pad[ 2 ];             /* i960 padding                       */
 } stats_phy_t;
 
 
 /* OC-3 statistics */
 
 typedef struct stats_oc3 {
-    u32 section_bip8_errors;    /* section 8 bit interleaved parity    */
-    u32 path_bip8_errors;       /* path 8 bit interleaved parity       */
-    u32 line_bip24_errors;      /* line 24 bit interleaved parity      */
-    u32 line_febe_errors;       /* line far end block errors           */
-    u32 path_febe_errors;       /* path far end block errors           */
-    u32 corr_hcs_errors;        /* correctable header check sequence   */
-    u32 ucorr_hcs_errors;       /* uncorrectable header check sequence */
-    u32 pad[ 1 ];               /* i960 padding                        */
+    __be32 section_bip8_errors;    /* section 8 bit interleaved parity    */
+    __be32 path_bip8_errors;       /* path 8 bit interleaved parity       */
+    __be32 line_bip24_errors;      /* line 24 bit interleaved parity      */
+    __be32 line_febe_errors;       /* line far end block errors           */
+    __be32 path_febe_errors;       /* path far end block errors           */
+    __be32 corr_hcs_errors;        /* correctable header check sequence   */
+    __be32 ucorr_hcs_errors;       /* uncorrectable header check sequence */
+    __be32 pad[ 1 ];               /* i960 padding                        */
 } stats_oc3_t;
 
 
 /* ATM statistics */
 
 typedef struct stats_atm {
-    u32	cells_transmitted;    /* cells transmitted                 */
-    u32	cells_received;       /* cells received                    */
-    u32	vpi_bad_range;        /* cell drops: VPI out of range      */
-    u32	vpi_no_conn;          /* cell drops: no connection for VPI */
-    u32	vci_bad_range;        /* cell drops: VCI out of range      */
-    u32	vci_no_conn;          /* cell drops: no connection for VCI */
-    u32	pad[ 2 ];             /* i960 padding                      */
+    __be32	cells_transmitted;    /* cells transmitted                 */
+    __be32	cells_received;       /* cells received                    */
+    __be32	vpi_bad_range;        /* cell drops: VPI out of range      */
+    __be32	vpi_no_conn;          /* cell drops: no connection for VPI */
+    __be32	vci_bad_range;        /* cell drops: VCI out of range      */
+    __be32	vci_no_conn;          /* cell drops: no connection for VCI */
+    __be32	pad[ 2 ];             /* i960 padding                      */
 } stats_atm_t;
 
 /* AAL0 statistics */
 
 typedef struct stats_aal0 {
-    u32	cells_transmitted;    /* cells transmitted */
-    u32	cells_received;       /* cells received    */
-    u32	cells_dropped;        /* cells dropped     */
-    u32	pad[ 1 ];             /* i960 padding      */
+    __be32	cells_transmitted;    /* cells transmitted */
+    __be32	cells_received;       /* cells received    */
+    __be32	cells_dropped;        /* cells dropped     */
+    __be32	pad[ 1 ];             /* i960 padding      */
 } stats_aal0_t;
 
 
 /* AAL3/4 statistics */
 
 typedef struct stats_aal34 {
-    u32	cells_transmitted;         /* cells transmitted from segmented PDUs */
-    u32	cells_received;            /* cells reassembled into PDUs           */
-    u32	cells_crc_errors;          /* payload CRC error count               */
-    u32	cells_protocol_errors;     /* SAR or CS layer protocol errors       */
-    u32	cells_dropped;             /* cells dropped: partial reassembly     */
-    u32	cspdus_transmitted;        /* CS PDUs transmitted                   */
-    u32	cspdus_received;           /* CS PDUs received                      */
-    u32	cspdus_protocol_errors;    /* CS layer protocol errors              */
-    u32	cspdus_dropped;            /* reassembled PDUs drop'd (in cells)    */
-    u32	pad[ 3 ];                  /* i960 padding                          */
+    __be32	cells_transmitted;         /* cells transmitted from segmented PDUs */
+    __be32	cells_received;            /* cells reassembled into PDUs           */
+    __be32	cells_crc_errors;          /* payload CRC error count               */
+    __be32	cells_protocol_errors;     /* SAR or CS layer protocol errors       */
+    __be32	cells_dropped;             /* cells dropped: partial reassembly     */
+    __be32	cspdus_transmitted;        /* CS PDUs transmitted                   */
+    __be32	cspdus_received;           /* CS PDUs received                      */
+    __be32	cspdus_protocol_errors;    /* CS layer protocol errors              */
+    __be32	cspdus_dropped;            /* reassembled PDUs drop'd (in cells)    */
+    __be32	pad[ 3 ];                  /* i960 padding                          */
 } stats_aal34_t;
 
 
 /* AAL5 statistics */
 
 typedef struct stats_aal5 {
-    u32	cells_transmitted;         /* cells transmitted from segmented SDUs */
-    u32	cells_received;		   /* cells reassembled into SDUs           */
-    u32	cells_dropped;		   /* reassembled PDUs dropped (in cells)   */
-    u32	congestion_experienced;    /* CRC error and length wrong            */
-    u32	cspdus_transmitted;        /* CS PDUs transmitted                   */
-    u32	cspdus_received;           /* CS PDUs received                      */
-    u32	cspdus_crc_errors;         /* CS PDUs CRC errors                    */
-    u32	cspdus_protocol_errors;    /* CS layer protocol errors              */
-    u32	cspdus_dropped;            /* reassembled PDUs dropped              */
-    u32	pad[ 3 ];                  /* i960 padding                          */
+    __be32	cells_transmitted;         /* cells transmitted from segmented SDUs */
+    __be32	cells_received;		   /* cells reassembled into SDUs           */
+    __be32	cells_dropped;		   /* reassembled PDUs dropped (in cells)   */
+    __be32	congestion_experienced;    /* CRC error and length wrong            */
+    __be32	cspdus_transmitted;        /* CS PDUs transmitted                   */
+    __be32	cspdus_received;           /* CS PDUs received                      */
+    __be32	cspdus_crc_errors;         /* CS PDUs CRC errors                    */
+    __be32	cspdus_protocol_errors;    /* CS layer protocol errors              */
+    __be32	cspdus_dropped;            /* reassembled PDUs dropped              */
+    __be32	pad[ 3 ];                  /* i960 padding                          */
 } stats_aal5_t;
 
 
 /* auxiliary statistics */
 
 typedef struct stats_aux {
-    u32	small_b1_failed;     /* receive BD allocation failures  */
-    u32	large_b1_failed;     /* receive BD allocation failures  */
-    u32	small_b2_failed;     /* receive BD allocation failures  */
-    u32	large_b2_failed;     /* receive BD allocation failures  */
-    u32	rpd_alloc_failed;    /* receive PDU allocation failures */
-    u32	receive_carrier;     /* no carrier = 0, carrier = 1     */
-    u32	pad[ 2 ];            /* i960 padding                    */
+    __be32	small_b1_failed;     /* receive BD allocation failures  */
+    __be32	large_b1_failed;     /* receive BD allocation failures  */
+    __be32	small_b2_failed;     /* receive BD allocation failures  */
+    __be32	large_b2_failed;     /* receive BD allocation failures  */
+    __be32	rpd_alloc_failed;    /* receive PDU allocation failures */
+    __be32	receive_carrier;     /* no carrier = 0, carrier = 1     */
+    __be32	pad[ 2 ];            /* i960 padding                    */
 } stats_aux_t;
 
 
@@ -643,10 +643,10 @@ typedef struct host_bsq {
 /* header of the firmware image */
 
 typedef struct fw_header {
-    u32 magic;           /* magic number                               */
-    u32 version;         /* firmware version id                        */
-    u32 load_offset;     /* fw load offset in board memory             */
-    u32 start_offset;    /* fw execution start address in board memory */
+    __le32 magic;           /* magic number                               */
+    __le32 version;         /* firmware version id                        */
+    __le32 load_offset;     /* fw load offset in board memory             */
+    __le32 start_offset;    /* fw execution start address in board memory */
 } fw_header_t;
 
 #define FW_HEADER_MAGIC  0x65726f66    /* 'fore' */
diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 7d25368..5ba4bab 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -485,9 +485,7 @@ static int el_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			printk(KERN_DEBUG "%s: burped during tx load.\n",
 				dev->name);
 		spin_lock_irqsave(&lp->lock, flags);
-	}
-	while (1);
-
+	} while (1);
 }
 
 /**
@@ -612,7 +610,8 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 			dev->stats.tx_packets++;
 			if (el_debug > 6)
 				printk(KERN_DEBUG " Tx succeeded %s\n",
-					(txsr & TX_RDY) ? "." : "but tx is busy!");
+					(txsr & TX_RDY) ? "." :
+							"but tx is busy!");
 			/*
 			 *	This is safe the interrupt is atomic WRT itself.
 			 */
@@ -693,7 +692,8 @@ static void el_receive(struct net_device *dev)
 
 	if (pkt_len < 60 || pkt_len > 1536) {
 		if (el_debug)
-			printk(KERN_DEBUG "%s: bogus packet, length=%d\n", dev->name, pkt_len);
+			printk(KERN_DEBUG "%s: bogus packet, length=%d\n",
+						dev->name, pkt_len);
 		dev->stats.rx_over_errors++;
 		return;
 	}
@@ -711,7 +711,8 @@ static void el_receive(struct net_device *dev)
 
 	outw(0x00, GP_LOW);
 	if (skb == NULL) {
-		printk(KERN_INFO "%s: Memory squeeze, dropping packet.\n", dev->name);
+		printk(KERN_INFO "%s: Memory squeeze, dropping packet.\n",
+								dev->name);
 		dev->stats.rx_dropped++;
 		return;
 	} else {
@@ -748,7 +749,8 @@ static void  el_reset(struct net_device *dev)
 	if (el_debug > 2)
 		printk(KERN_INFO "3c501 reset...");
 	outb(AX_RESET, AX_CMD);		/* Reset the chip */
-	outb(AX_LOOP, AX_CMD);		/* Aux control, irq and loopback enabled */
+	/* Aux control, irq and loopback enabled */
+	outb(AX_LOOP, AX_CMD);
 	{
 		int i;
 		for (i = 0; i < 6; i++)	/* Set the station address. */
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 9200ee5..129b8b3 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -1765,15 +1765,12 @@ static irqreturn_t atl1_intr(int irq, void *data)
 {
 	struct atl1_adapter *adapter = netdev_priv(data);
 	u32 status;
-	u8 update_rx;
 	int max_ints = 10;
 
 	status = adapter->cmb.cmb->int_stats;
 	if (!status)
 		return IRQ_NONE;
 
-	update_rx = 0;
-
 	do {
 		/* clear CMB interrupt status at once */
 		adapter->cmb.cmb->int_stats = 0;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 979f3fc..db58687 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1107,9 +1107,15 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	q->in_use += ndesc;
-	if (unlikely(credits - ndesc < q->stop_thres))
-		if (USE_GTS || !should_restart_tx(q))
-			t3_stop_queue(dev, qs, q);
+	if (unlikely(credits - ndesc < q->stop_thres)) {
+		t3_stop_queue(dev, qs, q);
+
+		if (should_restart_tx(q) &&
+		    test_and_clear_bit(TXQ_ETH, &qs->txq_stopped)) {
+			q->restarts++;
+			netif_wake_queue(dev);
+		}
+	}
 
 	gen = q->gen;
 	q->unacked += ndesc;
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 0b365b8..76118dd 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -131,8 +131,8 @@ IIIa. Ring buffers
 
 IVb. References
 
-http://www.smsc.com/main/datasheets/83c171.pdf
-http://www.smsc.com/main/datasheets/83c175.pdf
+http://www.smsc.com/main/tools/discontinued/83c171.pdf
+http://www.smsc.com/main/tools/discontinued/83c175.pdf
 http://scyld.com/expert/NWay.html
 http://www.national.com/pf/DP/DP83840A.html
 
@@ -227,7 +227,12 @@ static const u16 media2miictl[16] = {
 	0, 0x0C00, 0x0C00, 0x2000,  0x0100, 0x2100, 0, 0,
 	0, 0, 0, 0,  0, 0, 0, 0 };
 
-/* The EPIC100 Rx and Tx buffer descriptors. */
+/*
+ * The EPIC100 Rx and Tx buffer descriptors.  Note that these
+ * really ARE host-endian; it's not a misannotation.  We tell
+ * the card to byteswap them internally on big-endian hosts -
+ * look for #ifdef CONFIG_BIG_ENDIAN in epic_open().
+ */
 
 struct epic_tx_desc {
 	u32 txstatus;
@@ -418,7 +423,7 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 
 	/* Note: the '175 does not have a serial EEPROM. */
 	for (i = 0; i < 3; i++)
-		((u16 *)dev->dev_addr)[i] = le16_to_cpu(inw(ioaddr + LAN0 + i*4));
+		((__le16 *)dev->dev_addr)[i] = cpu_to_le16(inw(ioaddr + LAN0 + i*4));
 
 	if (debug > 2) {
 		dev_printk(KERN_DEBUG, &pdev->dev, "EEPROM contents:\n");
@@ -682,7 +687,8 @@ static int epic_open(struct net_device *dev)
 	if (ep->chip_flags & MII_PWRDWN)
 		outl((inl(ioaddr + NVCTL) & ~0x003C) | 0x4800, ioaddr + NVCTL);
 
-#if defined(__powerpc__) || defined(__sparc__)		/* Big endian */
+	/* Tell the chip to byteswap descriptors on big-endian hosts */
+#ifdef CONFIG_BIG_ENDIAN
 	outl(0x4432 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
 	inl(ioaddr + GENCTL);
 	outl(0x0432 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
@@ -695,7 +701,7 @@ static int epic_open(struct net_device *dev)
 	udelay(20); /* Looks like EPII needs that if you want reliable RX init. FIXME: pci posting bug? */
 
 	for (i = 0; i < 3; i++)
-		outl(cpu_to_le16(((u16*)dev->dev_addr)[i]), ioaddr + LAN0 + i*4);
+		outl(le16_to_cpu(((__le16*)dev->dev_addr)[i]), ioaddr + LAN0 + i*4);
 
 	ep->tx_threshold = TX_FIFO_THRESH;
 	outl(ep->tx_threshold, ioaddr + TxThresh);
@@ -798,7 +804,7 @@ static void epic_restart(struct net_device *dev)
 	for (i = 16; i > 0; i--)
 		outl(0x0008, ioaddr + TEST1);
 
-#if defined(__powerpc__) || defined(__sparc__)		/* Big endian */
+#ifdef CONFIG_BIG_ENDIAN
 	outl(0x0432 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
 #else
 	outl(0x0412 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
@@ -808,7 +814,7 @@ static void epic_restart(struct net_device *dev)
 		outl((inl(ioaddr + NVCTL) & ~0x003C) | 0x4800, ioaddr + NVCTL);
 
 	for (i = 0; i < 3; i++)
-		outl(cpu_to_le16(((u16*)dev->dev_addr)[i]), ioaddr + LAN0 + i*4);
+		outl(le16_to_cpu(((__le16*)dev->dev_addr)[i]), ioaddr + LAN0 + i*4);
 
 	ep->tx_threshold = TX_FIFO_THRESH;
 	outl(ep->tx_threshold, ioaddr + TxThresh);
@@ -919,7 +925,7 @@ static void epic_init_ring(struct net_device *dev)
 	/* Initialize all Rx descriptors. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		ep->rx_ring[i].rxstatus = 0;
-		ep->rx_ring[i].buflength = cpu_to_le32(ep->rx_buf_sz);
+		ep->rx_ring[i].buflength = ep->rx_buf_sz;
 		ep->rx_ring[i].next = ep->rx_ring_dma +
 				      (i+1)*sizeof(struct epic_rx_desc);
 		ep->rx_skbuff[i] = NULL;
@@ -936,7 +942,7 @@ static void epic_init_ring(struct net_device *dev)
 		skb_reserve(skb, 2);	/* 16 byte align the IP header. */
 		ep->rx_ring[i].bufaddr = pci_map_single(ep->pci_dev,
 			skb->data, ep->rx_buf_sz, PCI_DMA_FROMDEVICE);
-		ep->rx_ring[i].rxstatus = cpu_to_le32(DescOwn);
+		ep->rx_ring[i].rxstatus = DescOwn;
 	}
 	ep->dirty_rx = (unsigned int)(i - RX_RING_SIZE);
 
@@ -974,20 +980,20 @@ static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	ep->tx_ring[entry].bufaddr = pci_map_single(ep->pci_dev, skb->data,
 		 			            skb->len, PCI_DMA_TODEVICE);
 	if (free_count < TX_QUEUE_LEN/2) {/* Typical path */
-		ctrl_word = cpu_to_le32(0x100000); /* No interrupt */
+		ctrl_word = 0x100000; /* No interrupt */
 	} else if (free_count == TX_QUEUE_LEN/2) {
-		ctrl_word = cpu_to_le32(0x140000); /* Tx-done intr. */
+		ctrl_word = 0x140000; /* Tx-done intr. */
 	} else if (free_count < TX_QUEUE_LEN - 1) {
-		ctrl_word = cpu_to_le32(0x100000); /* No Tx-done intr. */
+		ctrl_word = 0x100000; /* No Tx-done intr. */
 	} else {
 		/* Leave room for an additional entry. */
-		ctrl_word = cpu_to_le32(0x140000); /* Tx-done intr. */
+		ctrl_word = 0x140000; /* Tx-done intr. */
 		ep->tx_full = 1;
 	}
-	ep->tx_ring[entry].buflength = ctrl_word | cpu_to_le32(skb->len);
+	ep->tx_ring[entry].buflength = ctrl_word | skb->len;
 	ep->tx_ring[entry].txstatus =
 		((skb->len >= ETH_ZLEN ? skb->len : ETH_ZLEN) << 16)
-		| cpu_to_le32(DescOwn);
+			    | DescOwn;
 
 	ep->cur_tx++;
 	if (ep->tx_full)
@@ -1041,7 +1047,7 @@ static void epic_tx(struct net_device *dev, struct epic_private *ep)
 	for (dirty_tx = ep->dirty_tx; cur_tx - dirty_tx > 0; dirty_tx++) {
 		struct sk_buff *skb;
 		int entry = dirty_tx % TX_RING_SIZE;
-		int txstatus = le32_to_cpu(ep->tx_ring[entry].txstatus);
+		int txstatus = ep->tx_ring[entry].txstatus;
 
 		if (txstatus & DescOwn)
 			break;	/* It still hasn't been Txed */
@@ -1163,8 +1169,8 @@ static int epic_rx(struct net_device *dev, int budget)
 		rx_work_limit = budget;
 
 	/* If we own the next entry, it's a new packet. Send it up. */
-	while ((ep->rx_ring[entry].rxstatus & cpu_to_le32(DescOwn)) == 0) {
-		int status = le32_to_cpu(ep->rx_ring[entry].rxstatus);
+	while ((ep->rx_ring[entry].rxstatus & DescOwn) == 0) {
+		int status = ep->rx_ring[entry].rxstatus;
 
 		if (debug > 4)
 			printk(KERN_DEBUG "  epic_rx() status was %8.8x.\n", status);
@@ -1238,7 +1244,8 @@ static int epic_rx(struct net_device *dev, int budget)
 				skb->data, ep->rx_buf_sz, PCI_DMA_FROMDEVICE);
 			work_done++;
 		}
-		ep->rx_ring[entry].rxstatus = cpu_to_le32(DescOwn);
+		/* AV: shouldn't we add a barrier here? */
+		ep->rx_ring[entry].rxstatus = DescOwn;
 	}
 	return work_done;
 }
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 801b4d9..6f7e3fd 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -184,6 +184,7 @@
 #define DEV_HAS_PAUSEFRAME_TX_V1   0x08000  /* device supports tx pause frames version 1 */
 #define DEV_HAS_PAUSEFRAME_TX_V2   0x10000  /* device supports tx pause frames version 2 */
 #define DEV_HAS_PAUSEFRAME_TX_V3   0x20000  /* device supports tx pause frames version 3 */
+#define DEV_NEED_TX_LIMIT          0x40000  /* device needs to limit tx */
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -635,6 +636,8 @@ union ring_type {
 #define NV_RESTART_TX         0x1
 #define NV_RESTART_RX         0x2
 
+#define NV_TX_LIMIT_COUNT     16
+
 /* statistics */
 struct nv_ethtool_str {
 	char name[ETH_GSTRING_LEN];
@@ -743,6 +746,8 @@ struct nv_skb_map {
 	struct sk_buff *skb;
 	dma_addr_t dma;
 	unsigned int dma_len;
+	struct ring_desc_ex *first_tx_desc;
+	struct nv_skb_map *next_tx_ctx;
 };
 
 /*
@@ -827,6 +832,10 @@ struct fe_priv {
 	union ring_type tx_ring;
 	u32 tx_flags;
 	int tx_ring_size;
+	int tx_limit;
+	u32 tx_pkts_in_progress;
+	struct nv_skb_map *tx_change_owner;
+	struct nv_skb_map *tx_end_flip;
 	int tx_stop;
 
 	/* vlan fields */
@@ -1707,6 +1716,9 @@ static void nv_init_tx(struct net_device *dev)
 		np->last_tx.ex = &np->tx_ring.ex[np->tx_ring_size-1];
 	np->get_tx_ctx = np->put_tx_ctx = np->first_tx_ctx = np->tx_skb;
 	np->last_tx_ctx = &np->tx_skb[np->tx_ring_size-1];
+	np->tx_pkts_in_progress = 0;
+	np->tx_change_owner = NULL;
+	np->tx_end_flip = NULL;
 
 	for (i = 0; i < np->tx_ring_size; i++) {
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
@@ -1720,6 +1732,9 @@ static void nv_init_tx(struct net_device *dev)
 		}
 		np->tx_skb[i].skb = NULL;
 		np->tx_skb[i].dma = 0;
+		np->tx_skb[i].dma_len = 0;
+		np->tx_skb[i].first_tx_desc = NULL;
+		np->tx_skb[i].next_tx_ctx = NULL;
 	}
 }
 
@@ -1771,7 +1786,14 @@ static void nv_drain_tx(struct net_device *dev)
 		}
 		if (nv_release_txskb(dev, &np->tx_skb[i]))
 			dev->stats.tx_dropped++;
+		np->tx_skb[i].dma = 0;
+		np->tx_skb[i].dma_len = 0;
+		np->tx_skb[i].first_tx_desc = NULL;
+		np->tx_skb[i].next_tx_ctx = NULL;
 	}
+	np->tx_pkts_in_progress = 0;
+	np->tx_change_owner = NULL;
+	np->tx_end_flip = NULL;
 }
 
 static void nv_drain_rx(struct net_device *dev)
@@ -1948,6 +1970,7 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 	struct ring_desc_ex* start_tx;
 	struct ring_desc_ex* prev_tx;
 	struct nv_skb_map* prev_tx_ctx;
+	struct nv_skb_map* start_tx_ctx;
 
 	/* add fragments to entries count */
 	for (i = 0; i < fragments; i++) {
@@ -1965,6 +1988,7 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	start_tx = put_tx = np->put_tx.ex;
+	start_tx_ctx = np->put_tx_ctx;
 
 	/* setup the header buffer */
 	do {
@@ -2037,6 +2061,26 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irq(&np->lock);
 
+	if (np->tx_limit) {
+		/* Limit the number of outstanding tx. Setup all fragments, but
+		 * do not set the VALID bit on the first descriptor. Save a pointer
+		 * to that descriptor and also for next skb_map element.
+		 */
+
+		if (np->tx_pkts_in_progress == NV_TX_LIMIT_COUNT) {
+			if (!np->tx_change_owner)
+				np->tx_change_owner = start_tx_ctx;
+
+			/* remove VALID bit */
+			tx_flags &= ~NV_TX2_VALID;
+			start_tx_ctx->first_tx_desc = start_tx;
+			start_tx_ctx->next_tx_ctx = np->put_tx_ctx;
+			np->tx_end_flip = np->put_tx_ctx;
+		} else {
+			np->tx_pkts_in_progress++;
+		}
+	}
+
 	/* set tx flags */
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
 	np->put_tx.ex = put_tx;
@@ -2060,6 +2104,25 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static inline void nv_tx_flip_ownership(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+
+	np->tx_pkts_in_progress--;
+	if (np->tx_change_owner) {
+		__le32 flaglen = le32_to_cpu(np->tx_change_owner->first_tx_desc->flaglen);
+		flaglen |= NV_TX2_VALID;
+		np->tx_change_owner->first_tx_desc->flaglen = cpu_to_le32(flaglen);
+		np->tx_pkts_in_progress++;
+
+		np->tx_change_owner = np->tx_change_owner->next_tx_ctx;
+		if (np->tx_change_owner == np->tx_end_flip)
+			np->tx_change_owner = NULL;
+
+		writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
+	}
+}
+
 /*
  * nv_tx_done: check for completed packets, release the skbs.
  *
@@ -2147,6 +2210,10 @@ static void nv_tx_done_optimized(struct net_device *dev, int limit)
 				dev->stats.tx_packets++;
 			dev_kfree_skb_any(np->get_tx_ctx->skb);
 			np->get_tx_ctx->skb = NULL;
+
+			if (np->tx_limit) {
+				nv_tx_flip_ownership(dev);
+			}
 		}
 		if (unlikely(np->get_tx.ex++ == np->last_tx.ex))
 			np->get_tx.ex = np->first_tx.ex;
@@ -5333,6 +5400,21 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		np->need_linktimer = 0;
 	}
 
+	/* Limit the number of tx's outstanding for hw bug */
+	if (id->driver_data & DEV_NEED_TX_LIMIT) {
+		np->tx_limit = 1;
+		if ((id->device == PCI_DEVICE_ID_NVIDIA_NVENET_32 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_33 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_34 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_35 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_36 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_37 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_38 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_39) &&
+		    pci_dev->revision >= 0xA2)
+			np->tx_limit = 0;
+	}
+
 	/* clear phy state and temporarily halt phy interrupts */
 	writel(0, base + NvRegMIIMask);
 	phystate = readl(base + NvRegAdapterControl);
@@ -5563,19 +5645,19 @@ static struct pci_device_id pci_tbl[] = {
 	},
 	{	/* CK804 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_8),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1|DEV_NEED_TX_LIMIT,
 	},
 	{	/* CK804 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_9),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP04 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_10),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP04 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_11),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP51 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_12),
@@ -5587,11 +5669,11 @@ static struct pci_device_id pci_tbl[] = {
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_14),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_15),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_16),
@@ -5611,19 +5693,19 @@ static struct pci_device_id pci_tbl[] = {
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_20),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_21),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_22),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_23),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_24),
@@ -5659,35 +5741,35 @@ static struct pci_device_id pci_tbl[] = {
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_32),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_33),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_34),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_35),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_36),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_37),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_38),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_39),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{0,},
 };
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index e6c69f7..0789802 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -143,6 +143,10 @@ static inline void emac_report_timeout_error(struct emac_instance *dev,
 #define STOP_TIMEOUT_1000	13
 #define STOP_TIMEOUT_1000_JUMBO	73
 
+static unsigned char default_mcast_addr[] = {
+	0x01, 0x80, 0xC2, 0x00, 0x00, 0x01
+};
+
 /* Please, keep in sync with struct ibm_emac_stats/ibm_emac_error_stats */
 static const char emac_stats_keys[EMAC_ETHTOOL_STATS_COUNT][ETH_GSTRING_LEN] = {
 	"rx_packets", "rx_bytes", "tx_packets", "tx_bytes", "rx_packets_csum",
@@ -618,6 +622,9 @@ static int emac_configure(struct emac_instance *dev)
 	if (emac_phy_gpcs(dev->phy.mode))
 		emac_mii_reset_phy(&dev->phy);
 
+	/* Required for Pause packet support in EMAC */
+	dev_mc_add(ndev, default_mcast_addr, sizeof(default_mcast_addr), 1);
+
 	return 0;
 }
 
diff --git a/drivers/net/ibm_newemac/tah.c b/drivers/net/ibm_newemac/tah.c
index 96417ad..b023d10 100644
--- a/drivers/net/ibm_newemac/tah.c
+++ b/drivers/net/ibm_newemac/tah.c
@@ -155,6 +155,10 @@ static int __devexit tah_remove(struct of_device *ofdev)
 static struct of_device_id tah_match[] =
 {
 	{
+		.compatible	= "ibm,tah",
+	},
+	/* For backward compat with old DT */
+	{
 		.type		= "tah",
 	},
 	{},
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 6a1f230..928ce82 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -31,7 +31,6 @@
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/netdevice.h>
-#include <linux/tcp.h>
 #include <linux/ipv6.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
@@ -2484,10 +2483,24 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 		tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			if (skb->protocol == htons(ETH_P_IP))
+			switch (skb->protocol) {
+			case __constant_htons(ETH_P_IP):
 				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
-			if (skb->sk && (skb->sk->sk_protocol == IPPROTO_TCP))
-				tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
+				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
+				break;
+			case __constant_htons(ETH_P_IPV6):
+				/* XXX what about other V6 headers?? */
+				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
+					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
+				break;
+			default:
+				if (unlikely(net_ratelimit()))
+					dev_warn(&adapter->pdev->dev,
+					    "partial checksum but proto=%x!\n",
+					    skb->protocol);
+				break;
+			}
 		}
 
 		context_desc->type_tucmd_mlhl = cpu_to_le32(tu_cmd);
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 373f72c..1f25263 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1221,7 +1221,8 @@ static void __devinit ioc3_serial_probe(struct pci_dev *pdev, struct ioc3 *ioc3)
 }
 #endif
 
-static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int __devinit ioc3_probe(struct pci_dev *pdev,
+	const struct pci_device_id *ent)
 {
 	unsigned int sw_physid1, sw_physid2;
 	struct net_device *dev = NULL;
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 5e5d9b5..9b358f6 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -472,7 +472,6 @@ static int ipg_config_autoneg(struct net_device *dev)
 	unsigned int txflowcontrol;
 	unsigned int rxflowcontrol;
 	unsigned int fullduplex;
-	unsigned int gig;
 	u32 mac_ctrl_val;
 	u32 asicctrl;
 	u8 phyctrl;
@@ -489,7 +488,6 @@ static int ipg_config_autoneg(struct net_device *dev)
 	fullduplex = 0;
 	txflowcontrol = 0;
 	rxflowcontrol = 0;
-	gig = 0;
 
 	/* To accomodate a problem in 10Mbps operation,
 	 * set a global flag if PHY running in 10Mbps mode.
@@ -511,7 +509,6 @@ static int ipg_config_autoneg(struct net_device *dev)
 		break;
 	case IPG_PC_LINK_SPEED_1000MBPS:
 		printk("1000Mbps.\n");
-		gig = 1;
 		break;
 	default:
 		printk("undefined!\n");
@@ -1900,8 +1897,13 @@ static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Specify the TFC field within the TFD. */
 	txfd->tfc |= cpu_to_le64(IPG_TFC_WORDALIGNDISABLED |
-		(IPG_TFC_FRAMEID & cpu_to_le64(sp->tx_current)) |
+		(IPG_TFC_FRAMEID & sp->tx_current) |
 		(IPG_TFC_FRAGCOUNT & (1 << 24)));
+	/*
+	 * 16--17 (WordAlign) <- 3 (disable),
+	 * 0--15 (FrameId) <- sp->tx_current,
+	 * 24--27 (FragCount) <- 1
+	 */
 
 	/* Request TxComplete interrupts at an interval defined
 	 * by the constant IPG_FRAMESBETWEENTXCOMPLETES.
diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
index b569c90..de0de74 100644
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -535,9 +535,9 @@ static void ne2k_pci_block_input(struct net_device *dev, int count,
 		if (count & 3) {
 			buf += count & ~3;
 			if (count & 2) {
-				u16 *b = (u16 *)buf;
+				__le16 *b = (__le16 *)buf;
 
-				*b++ = le16_to_cpu(inw(NE_BASE + NE_DATAPORT));
+				*b++ = cpu_to_le16(inw(NE_BASE + NE_DATAPORT));
 				buf = (char *)b;
 			}
 			if (count & 1)
@@ -600,9 +600,9 @@ static void ne2k_pci_block_output(struct net_device *dev, int count,
 		if (count & 3) {
 			buf += count & ~3;
 			if (count & 2) {
-				u16 *b = (u16 *)buf;
+				__le16 *b = (__le16 *)buf;
 
-				outw(cpu_to_le16(*b++), NE_BASE + NE_DATAPORT);
+				outw(le16_to_cpu(*b++), NE_BASE + NE_DATAPORT);
 				buf = (char *)b;
 			}
 		}
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 19184e4..169edc1 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -239,7 +239,8 @@ static void r6040_free_txbufs(struct net_device *dev)
 
 	for (i = 0; i < TX_DCNT; i++) {
 		if (lp->tx_insert_ptr->skb_ptr) {
-			pci_unmap_single(lp->pdev, lp->tx_insert_ptr->buf,
+			pci_unmap_single(lp->pdev,
+				le32_to_cpu(lp->tx_insert_ptr->buf),
 				MAX_BUF_SIZE, PCI_DMA_TODEVICE);
 			dev_kfree_skb(lp->tx_insert_ptr->skb_ptr);
 			lp->rx_insert_ptr->skb_ptr = NULL;
@@ -255,7 +256,8 @@ static void r6040_free_rxbufs(struct net_device *dev)
 
 	for (i = 0; i < RX_DCNT; i++) {
 		if (lp->rx_insert_ptr->skb_ptr) {
-			pci_unmap_single(lp->pdev, lp->rx_insert_ptr->buf,
+			pci_unmap_single(lp->pdev,
+				le32_to_cpu(lp->rx_insert_ptr->buf),
 				MAX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(lp->rx_insert_ptr->skb_ptr);
 			lp->rx_insert_ptr->skb_ptr = NULL;
@@ -542,7 +544,7 @@ static int r6040_rx(struct net_device *dev, int limit)
 			skb_ptr->dev = priv->dev;
 			/* Do not count the CRC */
 			skb_put(skb_ptr, descptr->len - 4);
-			pci_unmap_single(priv->pdev, descptr->buf,
+			pci_unmap_single(priv->pdev, le32_to_cpu(descptr->buf),
 				MAX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 			skb_ptr->protocol = eth_type_trans(skb_ptr, priv->dev);
 			/* Send to upper layer */
@@ -585,7 +587,7 @@ static void r6040_tx(struct net_device *dev)
 		if (descptr->status & 0x8000)
 			break; /* Not complete */
 		skb_ptr = descptr->skb_ptr;
-		pci_unmap_single(priv->pdev, descptr->buf,
+		pci_unmap_single(priv->pdev, le32_to_cpu(descptr->buf),
 			skb_ptr->len, PCI_DMA_TODEVICE);
 		/* Free buffer */
 		dev_kfree_skb_irq(skb_ptr);
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 567c627..1b5edd6 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -842,7 +842,7 @@ static inline int de_is_running (struct de_private *de)
 static void de_stop_rxtx (struct de_private *de)
 {
 	u32 macmode;
-	unsigned int work = 1000;
+	unsigned int i = 1300/100;
 
 	macmode = dr32(MacMode);
 	if (macmode & RxTx) {
@@ -850,10 +850,14 @@ static void de_stop_rxtx (struct de_private *de)
 		dr32(MacMode);
 	}
 
-	while (--work > 0) {
+	/* wait until in-flight frame completes.
+	 * Max time @ 10BT: 1500*8b/10Mbps == 1200us (+ 100us margin)
+	 * Typically expect this loop to end in < 50 us on 100BT.
+	 */
+	while (--i) {
 		if (!de_is_running(de))
 			return;
-		cpu_relax();
+		udelay(100);
 	}
 
 	printk(KERN_WARNING "%s: timeout expired stopping DMA\n", de->dev->name);
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index fba0811..8cc3166 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -154,8 +154,8 @@ static struct ucc_geth_info ugeth_primary_info = {
 	.rxQoSMode = UCC_GETH_QOS_MODE_DEFAULT,
 	.aufc = UPSMR_AUTOMATIC_FLOW_CONTROL_MODE_NONE,
 	.padAndCrc = MACCFG2_PAD_AND_CRC_MODE_PAD_AND_CRC,
-	.numThreadsTx = UCC_GETH_NUM_OF_THREADS_4,
-	.numThreadsRx = UCC_GETH_NUM_OF_THREADS_4,
+	.numThreadsTx = UCC_GETH_NUM_OF_THREADS_1,
+	.numThreadsRx = UCC_GETH_NUM_OF_THREADS_1,
 	.riscTx = QE_RISC_ALLOCATION_RISC1_AND_RISC2,
 	.riscRx = QE_RISC_ALLOCATION_RISC1_AND_RISC2,
 };
@@ -3975,6 +3975,8 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		ug_info->uf_info.utfs = UCC_GETH_UTFS_GIGA_INIT;
 		ug_info->uf_info.utfet = UCC_GETH_UTFET_GIGA_INIT;
 		ug_info->uf_info.utftt = UCC_GETH_UTFTT_GIGA_INIT;
+		ug_info->numThreadsTx = UCC_GETH_NUM_OF_THREADS_4;
+		ug_info->numThreadsRx = UCC_GETH_NUM_OF_THREADS_4;
 	}
 
 	/* Set the bus id */
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index a613247..727547a 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -16,10 +16,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-
-// #define	DEBUG			// error path messages, extra info
-// #define	VERBOSE			// more; success messages
-
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
@@ -318,6 +314,14 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	net->hard_header_len += sizeof (struct rndis_data_hdr);
 	dev->hard_mtu = net->mtu + net->hard_header_len;
 
+	dev->maxpacket = usb_maxpacket(dev->udev, dev->out, 1);
+	if (dev->maxpacket == 0) {
+		if (netif_msg_probe(dev))
+			dev_dbg(&intf->dev, "dev->maxpacket can't be 0\n");
+		retval = -EINVAL;
+		goto fail_and_release;
+	}
+
 	dev->rx_urb_size = dev->hard_mtu + (dev->maxpacket + 1);
 	dev->rx_urb_size &= ~(dev->maxpacket - 1);
 	u.init->max_transfer_size = cpu_to_le32(dev->rx_urb_size);
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index cf27bf4..547368e 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2024,6 +2024,7 @@ fst_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct fstioc_write wrthdr;
 	struct fstioc_info info;
 	unsigned long flags;
+	void *buf;
 
 	dbg(DBG_IOCTL, "ioctl: %x, %p\n", cmd, ifr->ifr_data);
 
@@ -2065,16 +2066,22 @@ fst_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return -ENXIO;
 		}
 
-		/* Now copy the data to the card.
-		 * This will probably break on some architectures.
-		 * I'll fix it when I have something to test on.
-		 */
-		if (copy_from_user(card->mem + wrthdr.offset,
+		/* Now copy the data to the card. */
+
+		buf = kmalloc(wrthdr.size, GFP_KERNEL);
+		if (!buf)
+			return -ENOMEM;
+
+		if (copy_from_user(buf,
 				   ifr->ifr_data + sizeof (struct fstioc_write),
 				   wrthdr.size)) {
+			kfree(buf);
 			return -EFAULT;
 		}
 
+		memcpy_toio(card->mem + wrthdr.offset, buf, wrthdr.size);
+		kfree(buf);
+
 		/* Writes to the memory of a card in the reset state constitute
 		 * a download
 		 */
diff --git a/drivers/sn/ioc3.c b/drivers/sn/ioc3.c
index 29fcd6d..a0aa33d 100644
--- a/drivers/sn/ioc3.c
+++ b/drivers/sn/ioc3.c
@@ -561,7 +561,7 @@ void ioc3_unregister_submodule(struct ioc3_submodule *is)
 					printk(KERN_WARNING
 					       "%s: IOC3 submodule %s remove failed "
 					       "for pci_dev %s.\n",
-					       __FUNCTION__, module_name(is->owner),
+					       __func__, module_name(is->owner),
 					       pci_name(idd->pdev));
 			idd->active[is->id] = 0;
 			if(is->irq_mask)
@@ -611,7 +611,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 	if ((ret = pci_enable_device(pdev))) {
 		printk(KERN_WARNING
 		       "%s: Failed to enable IOC3 device for pci_dev %s.\n",
-		       __FUNCTION__, pci_name(pdev));
+		       __func__, pci_name(pdev));
 		goto out;
 	}
 	pci_set_master(pdev);
@@ -623,7 +623,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
                 if (ret < 0) {
                         printk(KERN_WARNING "%s: Unable to obtain 64 bit DMA "
                                "for consistent allocations\n",
-				__FUNCTION__);
+				__func__);
                 }
 	}
 #endif
@@ -633,7 +633,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 	if (!idd) {
 		printk(KERN_WARNING
 		       "%s: Failed to allocate IOC3 data for pci_dev %s.\n",
-		       __FUNCTION__, pci_name(pdev));
+		       __func__, pci_name(pdev));
 		ret = -ENODEV;
 		goto out_idd;
 	}
@@ -649,7 +649,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 		printk(KERN_WARNING
 		       "%s: Unable to find IOC3 resource "
 		       "for pci_dev %s.\n",
-		       __FUNCTION__, pci_name(pdev));
+		       __func__, pci_name(pdev));
 		ret = -ENODEV;
 		goto out_pci;
 	}
@@ -657,7 +657,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 		printk(KERN_WARNING
 		       "%s: Unable to request IOC3 region "
 		       "for pci_dev %s.\n",
-		       __FUNCTION__, pci_name(pdev));
+		       __func__, pci_name(pdev));
 		ret = -ENODEV;
 		goto out_pci;
 	}
@@ -666,7 +666,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 		printk(KERN_WARNING
 		       "%s: Unable to remap IOC3 region "
 		       "for pci_dev %s.\n",
-		       __FUNCTION__, pci_name(pdev));
+		       __func__, pci_name(pdev));
 		ret = -ENODEV;
 		goto out_misc_region;
 	}
@@ -709,7 +709,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 		} else {
 			printk(KERN_WARNING
 			       "%s : request_irq fails for IRQ 0x%x\n ",
-			       __FUNCTION__, pdev->irq);
+			       __func__, pdev->irq);
 		}
 		if (!request_irq(pdev->irq+2, ioc3_intr_io, IRQF_SHARED,
 				 "ioc3-io", (void *)idd)) {
@@ -717,7 +717,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 		} else {
 			printk(KERN_WARNING
 			       "%s : request_irq fails for IRQ 0x%x\n ",
-			       __FUNCTION__, pdev->irq+2);
+			       __func__, pdev->irq+2);
 		}
 	} else {
 		if (!request_irq(pdev->irq, ioc3_intr_io, IRQF_SHARED,
@@ -726,7 +726,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 		} else {
 			printk(KERN_WARNING
 			       "%s : request_irq fails for IRQ 0x%x\n ",
-			       __FUNCTION__, pdev->irq);
+			       __func__, pdev->irq);
 		}
 	}
 
@@ -769,7 +769,7 @@ static void ioc3_remove(struct pci_dev *pdev)
 					printk(KERN_WARNING
 					       "%s: IOC3 submodule 0x%s remove failed "
 					       "for pci_dev %s.\n",
-					        __FUNCTION__,
+						__func__,
 						module_name(ioc3_submodules[id]->owner),
 					        pci_name(pdev));
 			idd->active[id] = 0;
