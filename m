From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] UAPI: (Scripted) Disintegrate include/linux/can
Date: Wed, 10 Oct 2012 22:39:36 +0200
Message-ID: <1349901576-30774-2-git-send-email-mkl@pengutronix.de>
References: <1349901576-30774-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, socketcan@hartkopp.net,
	netdev@vger.kernel.org, dhowells@redhat.com,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1349901576-30774-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Michael Kerrisk <mtk.manpages@gmail.com>
Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Acked-by: Dave Jones <davej@redhat.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 include/linux/can/Kbuild         |    5 --
 include/linux/can/bcm.h          |   66 ----------------
 include/linux/can/error.h        |   91 ---------------------
 include/linux/can/gw.h           |  162 --------------------------------------
 include/linux/can/netlink.h      |  122 ----------------------------
 include/linux/can/raw.h          |   30 -------
 include/uapi/linux/can/Kbuild    |    5 ++
 include/uapi/linux/can/bcm.h     |   66 ++++++++++++++++
 include/uapi/linux/can/error.h   |   91 +++++++++++++++++++++
 include/uapi/linux/can/gw.h      |  162 ++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/can/netlink.h |  122 ++++++++++++++++++++++++++++
 include/uapi/linux/can/raw.h     |   30 +++++++
 12 files changed, 476 insertions(+), 476 deletions(-)
 delete mode 100644 include/linux/can/bcm.h
 delete mode 100644 include/linux/can/error.h
 delete mode 100644 include/linux/can/gw.h
 delete mode 100644 include/linux/can/netlink.h
 delete mode 100644 include/linux/can/raw.h
 create mode 100644 include/uapi/linux/can/bcm.h
 create mode 100644 include/uapi/linux/can/error.h
 create mode 100644 include/uapi/linux/can/gw.h
 create mode 100644 include/uapi/linux/can/netlink.h
 create mode 100644 include/uapi/linux/can/raw.h

diff --git a/include/linux/can/Kbuild b/include/linux/can/Kbuild
index c62b7f1..e69de29 100644
--- a/include/linux/can/Kbuild
+++ b/include/linux/can/Kbuild
@@ -1,5 +0,0 @@
-header-y += raw.h
-header-y += bcm.h
-header-y += gw.h
-header-y += error.h
-header-y += netlink.h
diff --git a/include/linux/can/bcm.h b/include/linux/can/bcm.h
deleted file mode 100644
index 3ebe387..0000000
--- a/include/linux/can/bcm.h
+++ /dev/null
@@ -1,66 +0,0 @@
-/*
- * linux/can/bcm.h
- *
- * Definitions for CAN Broadcast Manager (BCM)
- *
- * Author: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- */
-
-#ifndef CAN_BCM_H
-#define CAN_BCM_H
-
-#include <linux/types.h>
-#include <linux/can.h>
-
-/**
- * struct bcm_msg_head - head of messages to/from the broadcast manager
- * @opcode:    opcode, see enum below.
- * @flags:     special flags, see below.
- * @count:     number of frames to send before changing interval.
- * @ival1:     interval for the first @count frames.
- * @ival2:     interval for the following frames.
- * @can_id:    CAN ID of frames to be sent or received.
- * @nframes:   number of frames appended to the message head.
- * @frames:    array of CAN frames.
- */
-struct bcm_msg_head {
-	__u32 opcode;
-	__u32 flags;
-	__u32 count;
-	struct timeval ival1, ival2;
-	canid_t can_id;
-	__u32 nframes;
-	struct can_frame frames[0];
-};
-
-enum {
-	TX_SETUP = 1,	/* create (cyclic) transmission task */
-	TX_DELETE,	/* remove (cyclic) transmission task */
-	TX_READ,	/* read properties of (cyclic) transmission task */
-	TX_SEND,	/* send one CAN frame */
-	RX_SETUP,	/* create RX content filter subscription */
-	RX_DELETE,	/* remove RX content filter subscription */
-	RX_READ,	/* read properties of RX content filter subscription */
-	TX_STATUS,	/* reply to TX_READ request */
-	TX_EXPIRED,	/* notification on performed transmissions (count=0) */
-	RX_STATUS,	/* reply to RX_READ request */
-	RX_TIMEOUT,	/* cyclic message is absent */
-	RX_CHANGED	/* updated CAN frame (detected content change) */
-};
-
-#define SETTIMER            0x0001
-#define STARTTIMER          0x0002
-#define TX_COUNTEVT         0x0004
-#define TX_ANNOUNCE         0x0008
-#define TX_CP_CAN_ID        0x0010
-#define RX_FILTER_ID        0x0020
-#define RX_CHECK_DLC        0x0040
-#define RX_NO_AUTOTIMER     0x0080
-#define RX_ANNOUNCE_RESUME  0x0100
-#define TX_RESET_MULTI_IDX  0x0200
-#define RX_RTR_FRAME        0x0400
-
-#endif /* CAN_BCM_H */
diff --git a/include/linux/can/error.h b/include/linux/can/error.h
deleted file mode 100644
index 7b7148b..0000000
--- a/include/linux/can/error.h
+++ /dev/null
@@ -1,91 +0,0 @@
-/*
- * linux/can/error.h
- *
- * Definitions of the CAN error messages to be filtered and passed to the user.
- *
- * Author: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- */
-
-#ifndef CAN_ERROR_H
-#define CAN_ERROR_H
-
-#define CAN_ERR_DLC 8 /* dlc for error message frames */
-
-/* error class (mask) in can_id */
-#define CAN_ERR_TX_TIMEOUT   0x00000001U /* TX timeout (by netdevice driver) */
-#define CAN_ERR_LOSTARB      0x00000002U /* lost arbitration    / data[0]    */
-#define CAN_ERR_CRTL         0x00000004U /* controller problems / data[1]    */
-#define CAN_ERR_PROT         0x00000008U /* protocol violations / data[2..3] */
-#define CAN_ERR_TRX          0x00000010U /* transceiver status  / data[4]    */
-#define CAN_ERR_ACK          0x00000020U /* received no ACK on transmission */
-#define CAN_ERR_BUSOFF       0x00000040U /* bus off */
-#define CAN_ERR_BUSERROR     0x00000080U /* bus error (may flood!) */
-#define CAN_ERR_RESTARTED    0x00000100U /* controller restarted */
-
-/* arbitration lost in bit ... / data[0] */
-#define CAN_ERR_LOSTARB_UNSPEC   0x00 /* unspecified */
-				      /* else bit number in bitstream */
-
-/* error status of CAN-controller / data[1] */
-#define CAN_ERR_CRTL_UNSPEC      0x00 /* unspecified */
-#define CAN_ERR_CRTL_RX_OVERFLOW 0x01 /* RX buffer overflow */
-#define CAN_ERR_CRTL_TX_OVERFLOW 0x02 /* TX buffer overflow */
-#define CAN_ERR_CRTL_RX_WARNING  0x04 /* reached warning level for RX errors */
-#define CAN_ERR_CRTL_TX_WARNING  0x08 /* reached warning level for TX errors */
-#define CAN_ERR_CRTL_RX_PASSIVE  0x10 /* reached error passive status RX */
-#define CAN_ERR_CRTL_TX_PASSIVE  0x20 /* reached error passive status TX */
-				      /* (at least one error counter exceeds */
-				      /* the protocol-defined level of 127)  */
-
-/* error in CAN protocol (type) / data[2] */
-#define CAN_ERR_PROT_UNSPEC      0x00 /* unspecified */
-#define CAN_ERR_PROT_BIT         0x01 /* single bit error */
-#define CAN_ERR_PROT_FORM        0x02 /* frame format error */
-#define CAN_ERR_PROT_STUFF       0x04 /* bit stuffing error */
-#define CAN_ERR_PROT_BIT0        0x08 /* unable to send dominant bit */
-#define CAN_ERR_PROT_BIT1        0x10 /* unable to send recessive bit */
-#define CAN_ERR_PROT_OVERLOAD    0x20 /* bus overload */
-#define CAN_ERR_PROT_ACTIVE      0x40 /* active error announcement */
-#define CAN_ERR_PROT_TX          0x80 /* error occurred on transmission */
-
-/* error in CAN protocol (location) / data[3] */
-#define CAN_ERR_PROT_LOC_UNSPEC  0x00 /* unspecified */
-#define CAN_ERR_PROT_LOC_SOF     0x03 /* start of frame */
-#define CAN_ERR_PROT_LOC_ID28_21 0x02 /* ID bits 28 - 21 (SFF: 10 - 3) */
-#define CAN_ERR_PROT_LOC_ID20_18 0x06 /* ID bits 20 - 18 (SFF: 2 - 0 )*/
-#define CAN_ERR_PROT_LOC_SRTR    0x04 /* substitute RTR (SFF: RTR) */
-#define CAN_ERR_PROT_LOC_IDE     0x05 /* identifier extension */
-#define CAN_ERR_PROT_LOC_ID17_13 0x07 /* ID bits 17-13 */
-#define CAN_ERR_PROT_LOC_ID12_05 0x0F /* ID bits 12-5 */
-#define CAN_ERR_PROT_LOC_ID04_00 0x0E /* ID bits 4-0 */
-#define CAN_ERR_PROT_LOC_RTR     0x0C /* RTR */
-#define CAN_ERR_PROT_LOC_RES1    0x0D /* reserved bit 1 */
-#define CAN_ERR_PROT_LOC_RES0    0x09 /* reserved bit 0 */
-#define CAN_ERR_PROT_LOC_DLC     0x0B /* data length code */
-#define CAN_ERR_PROT_LOC_DATA    0x0A /* data section */
-#define CAN_ERR_PROT_LOC_CRC_SEQ 0x08 /* CRC sequence */
-#define CAN_ERR_PROT_LOC_CRC_DEL 0x18 /* CRC delimiter */
-#define CAN_ERR_PROT_LOC_ACK     0x19 /* ACK slot */
-#define CAN_ERR_PROT_LOC_ACK_DEL 0x1B /* ACK delimiter */
-#define CAN_ERR_PROT_LOC_EOF     0x1A /* end of frame */
-#define CAN_ERR_PROT_LOC_INTERM  0x12 /* intermission */
-
-/* error status of CAN-transceiver / data[4] */
-/*                                             CANH CANL */
-#define CAN_ERR_TRX_UNSPEC             0x00 /* 0000 0000 */
-#define CAN_ERR_TRX_CANH_NO_WIRE       0x04 /* 0000 0100 */
-#define CAN_ERR_TRX_CANH_SHORT_TO_BAT  0x05 /* 0000 0101 */
-#define CAN_ERR_TRX_CANH_SHORT_TO_VCC  0x06 /* 0000 0110 */
-#define CAN_ERR_TRX_CANH_SHORT_TO_GND  0x07 /* 0000 0111 */
-#define CAN_ERR_TRX_CANL_NO_WIRE       0x40 /* 0100 0000 */
-#define CAN_ERR_TRX_CANL_SHORT_TO_BAT  0x50 /* 0101 0000 */
-#define CAN_ERR_TRX_CANL_SHORT_TO_VCC  0x60 /* 0110 0000 */
-#define CAN_ERR_TRX_CANL_SHORT_TO_GND  0x70 /* 0111 0000 */
-#define CAN_ERR_TRX_CANL_SHORT_TO_CANH 0x80 /* 1000 0000 */
-
-/* controller specific additional information / data[5..7] */
-
-#endif /* CAN_ERROR_H */
diff --git a/include/linux/can/gw.h b/include/linux/can/gw.h
deleted file mode 100644
index 8e1db18..0000000
--- a/include/linux/can/gw.h
+++ /dev/null
@@ -1,162 +0,0 @@
-/*
- * linux/can/gw.h
- *
- * Definitions for CAN frame Gateway/Router/Bridge
- *
- * Author: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
- * Copyright (c) 2011 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- */
-
-#ifndef CAN_GW_H
-#define CAN_GW_H
-
-#include <linux/types.h>
-#include <linux/can.h>
-
-struct rtcanmsg {
-	__u8  can_family;
-	__u8  gwtype;
-	__u16 flags;
-};
-
-/* CAN gateway types */
-enum {
-	CGW_TYPE_UNSPEC,
-	CGW_TYPE_CAN_CAN,	/* CAN->CAN routing */
-	__CGW_TYPE_MAX
-};
-
-#define CGW_TYPE_MAX (__CGW_TYPE_MAX - 1)
-
-/* CAN rtnetlink attribute definitions */
-enum {
-	CGW_UNSPEC,
-	CGW_MOD_AND,	/* CAN frame modification binary AND */
-	CGW_MOD_OR,	/* CAN frame modification binary OR */
-	CGW_MOD_XOR,	/* CAN frame modification binary XOR */
-	CGW_MOD_SET,	/* CAN frame modification set alternate values */
-	CGW_CS_XOR,	/* set data[] XOR checksum into data[index] */
-	CGW_CS_CRC8,	/* set data[] CRC8 checksum into data[index] */
-	CGW_HANDLED,	/* number of handled CAN frames */
-	CGW_DROPPED,	/* number of dropped CAN frames */
-	CGW_SRC_IF,	/* ifindex of source network interface */
-	CGW_DST_IF,	/* ifindex of destination network interface */
-	CGW_FILTER,	/* specify struct can_filter on source CAN device */
-	__CGW_MAX
-};
-
-#define CGW_MAX (__CGW_MAX - 1)
-
-#define CGW_FLAGS_CAN_ECHO 0x01
-#define CGW_FLAGS_CAN_SRC_TSTAMP 0x02
-
-#define CGW_MOD_FUNCS 4 /* AND OR XOR SET */
-
-/* CAN frame elements that are affected by curr. 3 CAN frame modifications */
-#define CGW_MOD_ID	0x01
-#define CGW_MOD_DLC	0x02
-#define CGW_MOD_DATA	0x04
-
-#define CGW_FRAME_MODS 3 /* ID DLC DATA */
-
-#define MAX_MODFUNCTIONS (CGW_MOD_FUNCS * CGW_FRAME_MODS)
-
-struct cgw_frame_mod {
-	struct can_frame cf;
-	__u8 modtype;
-} __attribute__((packed));
-
-#define CGW_MODATTR_LEN sizeof(struct cgw_frame_mod)
-
-struct cgw_csum_xor {
-	__s8 from_idx;
-	__s8 to_idx;
-	__s8 result_idx;
-	__u8 init_xor_val;
-} __attribute__((packed));
-
-struct cgw_csum_crc8 {
-	__s8 from_idx;
-	__s8 to_idx;
-	__s8 result_idx;
-	__u8 init_crc_val;
-	__u8 final_xor_val;
-	__u8 crctab[256];
-	__u8 profile;
-	__u8 profile_data[20];
-} __attribute__((packed));
-
-/* length of checksum operation parameters. idx = index in CAN frame data[] */
-#define CGW_CS_XOR_LEN  sizeof(struct cgw_csum_xor)
-#define CGW_CS_CRC8_LEN  sizeof(struct cgw_csum_crc8)
-
-/* CRC8 profiles (compute CRC for additional data elements - see below) */
-enum {
-	CGW_CRC8PRF_UNSPEC,
-	CGW_CRC8PRF_1U8,	/* compute one additional u8 value */
-	CGW_CRC8PRF_16U8,	/* u8 value table indexed by data[1] & 0xF */
-	CGW_CRC8PRF_SFFID_XOR,	/* (can_id & 0xFF) ^ (can_id >> 8 & 0xFF) */
-	__CGW_CRC8PRF_MAX
-};
-
-#define CGW_CRC8PRF_MAX (__CGW_CRC8PRF_MAX - 1)
-
-/*
- * CAN rtnetlink attribute contents in detail
- *
- * CGW_XXX_IF (length 4 bytes):
- * Sets an interface index for source/destination network interfaces.
- * For the CAN->CAN gwtype the indices of _two_ CAN interfaces are mandatory.
- *
- * CGW_FILTER (length 8 bytes):
- * Sets a CAN receive filter for the gateway job specified by the
- * struct can_filter described in include/linux/can.h
- *
- * CGW_MOD_XXX (length 17 bytes):
- * Specifies a modification that's done to a received CAN frame before it is
- * send out to the destination interface.
- *
- * <struct can_frame> data used as operator
- * <u8> affected CAN frame elements
- *
- * CGW_CS_XOR (length 4 bytes):
- * Set a simple XOR checksum starting with an initial value into
- * data[result-idx] using data[start-idx] .. data[end-idx]
- *
- * The XOR checksum is calculated like this:
- *
- * xor = init_xor_val
- *
- * for (i = from_idx .. to_idx)
- *      xor ^= can_frame.data[i]
- *
- * can_frame.data[ result_idx ] = xor
- *
- * CGW_CS_CRC8 (length 282 bytes):
- * Set a CRC8 value into data[result-idx] using a given 256 byte CRC8 table,
- * a given initial value and a defined input data[start-idx] .. data[end-idx].
- * Finally the result value is XOR'ed with the final_xor_val.
- *
- * The CRC8 checksum is calculated like this:
- *
- * crc = init_crc_val
- *
- * for (i = from_idx .. to_idx)
- *      crc = crctab[ crc ^ can_frame.data[i] ]
- *
- * can_frame.data[ result_idx ] = crc ^ final_xor_val
- *
- * The calculated CRC may contain additional source data elements that can be
- * defined in the handling of 'checksum profiles' e.g. shown in AUTOSAR specs
- * like http://www.autosar.org/download/R4.0/AUTOSAR_SWS_E2ELibrary.pdf
- * E.g. the profile_data[] may contain additional u8 values (called DATA_IDs)
- * that are used depending on counter values inside the CAN frame data[].
- * So far only three profiles have been implemented for illustration.
- *
- * Remark: In general the attribute data is a linear buffer.
- *         Beware of sending unpacked or aligned structs!
- */
-
-#endif
diff --git a/include/linux/can/netlink.h b/include/linux/can/netlink.h
deleted file mode 100644
index 14966dd..0000000
--- a/include/linux/can/netlink.h
+++ /dev/null
@@ -1,122 +0,0 @@
-/*
- * linux/can/netlink.h
- *
- * Definitions for the CAN netlink interface
- *
- * Copyright (c) 2009 Wolfgang Grandegger <wg@grandegger.com>
- *
- */
-
-#ifndef CAN_NETLINK_H
-#define CAN_NETLINK_H
-
-#include <linux/types.h>
-
-/*
- * CAN bit-timing parameters
- *
- * For further information, please read chapter "8 BIT TIMING
- * REQUIREMENTS" of the "Bosch CAN Specification version 2.0"
- * at http://www.semiconductors.bosch.de/pdf/can2spec.pdf.
- */
-struct can_bittiming {
-	__u32 bitrate;		/* Bit-rate in bits/second */
-	__u32 sample_point;	/* Sample point in one-tenth of a percent */
-	__u32 tq;		/* Time quanta (TQ) in nanoseconds */
-	__u32 prop_seg;		/* Propagation segment in TQs */
-	__u32 phase_seg1;	/* Phase buffer segment 1 in TQs */
-	__u32 phase_seg2;	/* Phase buffer segment 2 in TQs */
-	__u32 sjw;		/* Synchronisation jump width in TQs */
-	__u32 brp;		/* Bit-rate prescaler */
-};
-
-/*
- * CAN harware-dependent bit-timing constant
- *
- * Used for calculating and checking bit-timing parameters
- */
-struct can_bittiming_const {
-	char name[16];		/* Name of the CAN controller hardware */
-	__u32 tseg1_min;	/* Time segement 1 = prop_seg + phase_seg1 */
-	__u32 tseg1_max;
-	__u32 tseg2_min;	/* Time segement 2 = phase_seg2 */
-	__u32 tseg2_max;
-	__u32 sjw_max;		/* Synchronisation jump width */
-	__u32 brp_min;		/* Bit-rate prescaler */
-	__u32 brp_max;
-	__u32 brp_inc;
-};
-
-/*
- * CAN clock parameters
- */
-struct can_clock {
-	__u32 freq;		/* CAN system clock frequency in Hz */
-};
-
-/*
- * CAN operational and error states
- */
-enum can_state {
-	CAN_STATE_ERROR_ACTIVE = 0,	/* RX/TX error count < 96 */
-	CAN_STATE_ERROR_WARNING,	/* RX/TX error count < 128 */
-	CAN_STATE_ERROR_PASSIVE,	/* RX/TX error count < 256 */
-	CAN_STATE_BUS_OFF,		/* RX/TX error count >= 256 */
-	CAN_STATE_STOPPED,		/* Device is stopped */
-	CAN_STATE_SLEEPING,		/* Device is sleeping */
-	CAN_STATE_MAX
-};
-
-/*
- * CAN bus error counters
- */
-struct can_berr_counter {
-	__u16 txerr;
-	__u16 rxerr;
-};
-
-/*
- * CAN controller mode
- */
-struct can_ctrlmode {
-	__u32 mask;
-	__u32 flags;
-};
-
-#define CAN_CTRLMODE_LOOPBACK		0x01	/* Loopback mode */
-#define CAN_CTRLMODE_LISTENONLY		0x02 	/* Listen-only mode */
-#define CAN_CTRLMODE_3_SAMPLES		0x04	/* Triple sampling mode */
-#define CAN_CTRLMODE_ONE_SHOT		0x08	/* One-Shot mode */
-#define CAN_CTRLMODE_BERR_REPORTING	0x10	/* Bus-error reporting */
-
-/*
- * CAN device statistics
- */
-struct can_device_stats {
-	__u32 bus_error;	/* Bus errors */
-	__u32 error_warning;	/* Changes to error warning state */
-	__u32 error_passive;	/* Changes to error passive state */
-	__u32 bus_off;		/* Changes to bus off state */
-	__u32 arbitration_lost; /* Arbitration lost errors */
-	__u32 restarts;		/* CAN controller re-starts */
-};
-
-/*
- * CAN netlink interface
- */
-enum {
-	IFLA_CAN_UNSPEC,
-	IFLA_CAN_BITTIMING,
-	IFLA_CAN_BITTIMING_CONST,
-	IFLA_CAN_CLOCK,
-	IFLA_CAN_STATE,
-	IFLA_CAN_CTRLMODE,
-	IFLA_CAN_RESTART_MS,
-	IFLA_CAN_RESTART,
-	IFLA_CAN_BERR_COUNTER,
-	__IFLA_CAN_MAX
-};
-
-#define IFLA_CAN_MAX	(__IFLA_CAN_MAX - 1)
-
-#endif /* CAN_NETLINK_H */
diff --git a/include/linux/can/raw.h b/include/linux/can/raw.h
deleted file mode 100644
index a814062..0000000
--- a/include/linux/can/raw.h
+++ /dev/null
@@ -1,30 +0,0 @@
-/*
- * linux/can/raw.h
- *
- * Definitions for raw CAN sockets
- *
- * Authors: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
- *          Urs Thuermann   <urs.thuermann@volkswagen.de>
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- */
-
-#ifndef CAN_RAW_H
-#define CAN_RAW_H
-
-#include <linux/can.h>
-
-#define SOL_CAN_RAW (SOL_CAN_BASE + CAN_RAW)
-
-/* for socket options affecting the socket (not the global system) */
-
-enum {
-	CAN_RAW_FILTER = 1,	/* set 0 .. n can_filter(s)          */
-	CAN_RAW_ERR_FILTER,	/* set filter for error frames       */
-	CAN_RAW_LOOPBACK,	/* local loopback (default:on)       */
-	CAN_RAW_RECV_OWN_MSGS,	/* receive my own msgs (default:off) */
-	CAN_RAW_FD_FRAMES,	/* allow CAN FD frames (default:off) */
-};
-
-#endif
diff --git a/include/uapi/linux/can/Kbuild b/include/uapi/linux/can/Kbuild
index aafaa5a..21c91bf 100644
--- a/include/uapi/linux/can/Kbuild
+++ b/include/uapi/linux/can/Kbuild
@@ -1 +1,6 @@
 # UAPI Header export list
+header-y += bcm.h
+header-y += error.h
+header-y += gw.h
+header-y += netlink.h
+header-y += raw.h
diff --git a/include/uapi/linux/can/bcm.h b/include/uapi/linux/can/bcm.h
new file mode 100644
index 0000000..3ebe387
--- /dev/null
+++ b/include/uapi/linux/can/bcm.h
@@ -0,0 +1,66 @@
+/*
+ * linux/can/bcm.h
+ *
+ * Definitions for CAN Broadcast Manager (BCM)
+ *
+ * Author: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
+ * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
+ * All rights reserved.
+ *
+ */
+
+#ifndef CAN_BCM_H
+#define CAN_BCM_H
+
+#include <linux/types.h>
+#include <linux/can.h>
+
+/**
+ * struct bcm_msg_head - head of messages to/from the broadcast manager
+ * @opcode:    opcode, see enum below.
+ * @flags:     special flags, see below.
+ * @count:     number of frames to send before changing interval.
+ * @ival1:     interval for the first @count frames.
+ * @ival2:     interval for the following frames.
+ * @can_id:    CAN ID of frames to be sent or received.
+ * @nframes:   number of frames appended to the message head.
+ * @frames:    array of CAN frames.
+ */
+struct bcm_msg_head {
+	__u32 opcode;
+	__u32 flags;
+	__u32 count;
+	struct timeval ival1, ival2;
+	canid_t can_id;
+	__u32 nframes;
+	struct can_frame frames[0];
+};
+
+enum {
+	TX_SETUP = 1,	/* create (cyclic) transmission task */
+	TX_DELETE,	/* remove (cyclic) transmission task */
+	TX_READ,	/* read properties of (cyclic) transmission task */
+	TX_SEND,	/* send one CAN frame */
+	RX_SETUP,	/* create RX content filter subscription */
+	RX_DELETE,	/* remove RX content filter subscription */
+	RX_READ,	/* read properties of RX content filter subscription */
+	TX_STATUS,	/* reply to TX_READ request */
+	TX_EXPIRED,	/* notification on performed transmissions (count=0) */
+	RX_STATUS,	/* reply to RX_READ request */
+	RX_TIMEOUT,	/* cyclic message is absent */
+	RX_CHANGED	/* updated CAN frame (detected content change) */
+};
+
+#define SETTIMER            0x0001
+#define STARTTIMER          0x0002
+#define TX_COUNTEVT         0x0004
+#define TX_ANNOUNCE         0x0008
+#define TX_CP_CAN_ID        0x0010
+#define RX_FILTER_ID        0x0020
+#define RX_CHECK_DLC        0x0040
+#define RX_NO_AUTOTIMER     0x0080
+#define RX_ANNOUNCE_RESUME  0x0100
+#define TX_RESET_MULTI_IDX  0x0200
+#define RX_RTR_FRAME        0x0400
+
+#endif /* CAN_BCM_H */
diff --git a/include/uapi/linux/can/error.h b/include/uapi/linux/can/error.h
new file mode 100644
index 0000000..7b7148b
--- /dev/null
+++ b/include/uapi/linux/can/error.h
@@ -0,0 +1,91 @@
+/*
+ * linux/can/error.h
+ *
+ * Definitions of the CAN error messages to be filtered and passed to the user.
+ *
+ * Author: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
+ * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
+ * All rights reserved.
+ *
+ */
+
+#ifndef CAN_ERROR_H
+#define CAN_ERROR_H
+
+#define CAN_ERR_DLC 8 /* dlc for error message frames */
+
+/* error class (mask) in can_id */
+#define CAN_ERR_TX_TIMEOUT   0x00000001U /* TX timeout (by netdevice driver) */
+#define CAN_ERR_LOSTARB      0x00000002U /* lost arbitration    / data[0]    */
+#define CAN_ERR_CRTL         0x00000004U /* controller problems / data[1]    */
+#define CAN_ERR_PROT         0x00000008U /* protocol violations / data[2..3] */
+#define CAN_ERR_TRX          0x00000010U /* transceiver status  / data[4]    */
+#define CAN_ERR_ACK          0x00000020U /* received no ACK on transmission */
+#define CAN_ERR_BUSOFF       0x00000040U /* bus off */
+#define CAN_ERR_BUSERROR     0x00000080U /* bus error (may flood!) */
+#define CAN_ERR_RESTARTED    0x00000100U /* controller restarted */
+
+/* arbitration lost in bit ... / data[0] */
+#define CAN_ERR_LOSTARB_UNSPEC   0x00 /* unspecified */
+				      /* else bit number in bitstream */
+
+/* error status of CAN-controller / data[1] */
+#define CAN_ERR_CRTL_UNSPEC      0x00 /* unspecified */
+#define CAN_ERR_CRTL_RX_OVERFLOW 0x01 /* RX buffer overflow */
+#define CAN_ERR_CRTL_TX_OVERFLOW 0x02 /* TX buffer overflow */
+#define CAN_ERR_CRTL_RX_WARNING  0x04 /* reached warning level for RX errors */
+#define CAN_ERR_CRTL_TX_WARNING  0x08 /* reached warning level for TX errors */
+#define CAN_ERR_CRTL_RX_PASSIVE  0x10 /* reached error passive status RX */
+#define CAN_ERR_CRTL_TX_PASSIVE  0x20 /* reached error passive status TX */
+				      /* (at least one error counter exceeds */
+				      /* the protocol-defined level of 127)  */
+
+/* error in CAN protocol (type) / data[2] */
+#define CAN_ERR_PROT_UNSPEC      0x00 /* unspecified */
+#define CAN_ERR_PROT_BIT         0x01 /* single bit error */
+#define CAN_ERR_PROT_FORM        0x02 /* frame format error */
+#define CAN_ERR_PROT_STUFF       0x04 /* bit stuffing error */
+#define CAN_ERR_PROT_BIT0        0x08 /* unable to send dominant bit */
+#define CAN_ERR_PROT_BIT1        0x10 /* unable to send recessive bit */
+#define CAN_ERR_PROT_OVERLOAD    0x20 /* bus overload */
+#define CAN_ERR_PROT_ACTIVE      0x40 /* active error announcement */
+#define CAN_ERR_PROT_TX          0x80 /* error occurred on transmission */
+
+/* error in CAN protocol (location) / data[3] */
+#define CAN_ERR_PROT_LOC_UNSPEC  0x00 /* unspecified */
+#define CAN_ERR_PROT_LOC_SOF     0x03 /* start of frame */
+#define CAN_ERR_PROT_LOC_ID28_21 0x02 /* ID bits 28 - 21 (SFF: 10 - 3) */
+#define CAN_ERR_PROT_LOC_ID20_18 0x06 /* ID bits 20 - 18 (SFF: 2 - 0 )*/
+#define CAN_ERR_PROT_LOC_SRTR    0x04 /* substitute RTR (SFF: RTR) */
+#define CAN_ERR_PROT_LOC_IDE     0x05 /* identifier extension */
+#define CAN_ERR_PROT_LOC_ID17_13 0x07 /* ID bits 17-13 */
+#define CAN_ERR_PROT_LOC_ID12_05 0x0F /* ID bits 12-5 */
+#define CAN_ERR_PROT_LOC_ID04_00 0x0E /* ID bits 4-0 */
+#define CAN_ERR_PROT_LOC_RTR     0x0C /* RTR */
+#define CAN_ERR_PROT_LOC_RES1    0x0D /* reserved bit 1 */
+#define CAN_ERR_PROT_LOC_RES0    0x09 /* reserved bit 0 */
+#define CAN_ERR_PROT_LOC_DLC     0x0B /* data length code */
+#define CAN_ERR_PROT_LOC_DATA    0x0A /* data section */
+#define CAN_ERR_PROT_LOC_CRC_SEQ 0x08 /* CRC sequence */
+#define CAN_ERR_PROT_LOC_CRC_DEL 0x18 /* CRC delimiter */
+#define CAN_ERR_PROT_LOC_ACK     0x19 /* ACK slot */
+#define CAN_ERR_PROT_LOC_ACK_DEL 0x1B /* ACK delimiter */
+#define CAN_ERR_PROT_LOC_EOF     0x1A /* end of frame */
+#define CAN_ERR_PROT_LOC_INTERM  0x12 /* intermission */
+
+/* error status of CAN-transceiver / data[4] */
+/*                                             CANH CANL */
+#define CAN_ERR_TRX_UNSPEC             0x00 /* 0000 0000 */
+#define CAN_ERR_TRX_CANH_NO_WIRE       0x04 /* 0000 0100 */
+#define CAN_ERR_TRX_CANH_SHORT_TO_BAT  0x05 /* 0000 0101 */
+#define CAN_ERR_TRX_CANH_SHORT_TO_VCC  0x06 /* 0000 0110 */
+#define CAN_ERR_TRX_CANH_SHORT_TO_GND  0x07 /* 0000 0111 */
+#define CAN_ERR_TRX_CANL_NO_WIRE       0x40 /* 0100 0000 */
+#define CAN_ERR_TRX_CANL_SHORT_TO_BAT  0x50 /* 0101 0000 */
+#define CAN_ERR_TRX_CANL_SHORT_TO_VCC  0x60 /* 0110 0000 */
+#define CAN_ERR_TRX_CANL_SHORT_TO_GND  0x70 /* 0111 0000 */
+#define CAN_ERR_TRX_CANL_SHORT_TO_CANH 0x80 /* 1000 0000 */
+
+/* controller specific additional information / data[5..7] */
+
+#endif /* CAN_ERROR_H */
diff --git a/include/uapi/linux/can/gw.h b/include/uapi/linux/can/gw.h
new file mode 100644
index 0000000..8e1db18
--- /dev/null
+++ b/include/uapi/linux/can/gw.h
@@ -0,0 +1,162 @@
+/*
+ * linux/can/gw.h
+ *
+ * Definitions for CAN frame Gateway/Router/Bridge
+ *
+ * Author: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
+ * Copyright (c) 2011 Volkswagen Group Electronic Research
+ * All rights reserved.
+ *
+ */
+
+#ifndef CAN_GW_H
+#define CAN_GW_H
+
+#include <linux/types.h>
+#include <linux/can.h>
+
+struct rtcanmsg {
+	__u8  can_family;
+	__u8  gwtype;
+	__u16 flags;
+};
+
+/* CAN gateway types */
+enum {
+	CGW_TYPE_UNSPEC,
+	CGW_TYPE_CAN_CAN,	/* CAN->CAN routing */
+	__CGW_TYPE_MAX
+};
+
+#define CGW_TYPE_MAX (__CGW_TYPE_MAX - 1)
+
+/* CAN rtnetlink attribute definitions */
+enum {
+	CGW_UNSPEC,
+	CGW_MOD_AND,	/* CAN frame modification binary AND */
+	CGW_MOD_OR,	/* CAN frame modification binary OR */
+	CGW_MOD_XOR,	/* CAN frame modification binary XOR */
+	CGW_MOD_SET,	/* CAN frame modification set alternate values */
+	CGW_CS_XOR,	/* set data[] XOR checksum into data[index] */
+	CGW_CS_CRC8,	/* set data[] CRC8 checksum into data[index] */
+	CGW_HANDLED,	/* number of handled CAN frames */
+	CGW_DROPPED,	/* number of dropped CAN frames */
+	CGW_SRC_IF,	/* ifindex of source network interface */
+	CGW_DST_IF,	/* ifindex of destination network interface */
+	CGW_FILTER,	/* specify struct can_filter on source CAN device */
+	__CGW_MAX
+};
+
+#define CGW_MAX (__CGW_MAX - 1)
+
+#define CGW_FLAGS_CAN_ECHO 0x01
+#define CGW_FLAGS_CAN_SRC_TSTAMP 0x02
+
+#define CGW_MOD_FUNCS 4 /* AND OR XOR SET */
+
+/* CAN frame elements that are affected by curr. 3 CAN frame modifications */
+#define CGW_MOD_ID	0x01
+#define CGW_MOD_DLC	0x02
+#define CGW_MOD_DATA	0x04
+
+#define CGW_FRAME_MODS 3 /* ID DLC DATA */
+
+#define MAX_MODFUNCTIONS (CGW_MOD_FUNCS * CGW_FRAME_MODS)
+
+struct cgw_frame_mod {
+	struct can_frame cf;
+	__u8 modtype;
+} __attribute__((packed));
+
+#define CGW_MODATTR_LEN sizeof(struct cgw_frame_mod)
+
+struct cgw_csum_xor {
+	__s8 from_idx;
+	__s8 to_idx;
+	__s8 result_idx;
+	__u8 init_xor_val;
+} __attribute__((packed));
+
+struct cgw_csum_crc8 {
+	__s8 from_idx;
+	__s8 to_idx;
+	__s8 result_idx;
+	__u8 init_crc_val;
+	__u8 final_xor_val;
+	__u8 crctab[256];
+	__u8 profile;
+	__u8 profile_data[20];
+} __attribute__((packed));
+
+/* length of checksum operation parameters. idx = index in CAN frame data[] */
+#define CGW_CS_XOR_LEN  sizeof(struct cgw_csum_xor)
+#define CGW_CS_CRC8_LEN  sizeof(struct cgw_csum_crc8)
+
+/* CRC8 profiles (compute CRC for additional data elements - see below) */
+enum {
+	CGW_CRC8PRF_UNSPEC,
+	CGW_CRC8PRF_1U8,	/* compute one additional u8 value */
+	CGW_CRC8PRF_16U8,	/* u8 value table indexed by data[1] & 0xF */
+	CGW_CRC8PRF_SFFID_XOR,	/* (can_id & 0xFF) ^ (can_id >> 8 & 0xFF) */
+	__CGW_CRC8PRF_MAX
+};
+
+#define CGW_CRC8PRF_MAX (__CGW_CRC8PRF_MAX - 1)
+
+/*
+ * CAN rtnetlink attribute contents in detail
+ *
+ * CGW_XXX_IF (length 4 bytes):
+ * Sets an interface index for source/destination network interfaces.
+ * For the CAN->CAN gwtype the indices of _two_ CAN interfaces are mandatory.
+ *
+ * CGW_FILTER (length 8 bytes):
+ * Sets a CAN receive filter for the gateway job specified by the
+ * struct can_filter described in include/linux/can.h
+ *
+ * CGW_MOD_XXX (length 17 bytes):
+ * Specifies a modification that's done to a received CAN frame before it is
+ * send out to the destination interface.
+ *
+ * <struct can_frame> data used as operator
+ * <u8> affected CAN frame elements
+ *
+ * CGW_CS_XOR (length 4 bytes):
+ * Set a simple XOR checksum starting with an initial value into
+ * data[result-idx] using data[start-idx] .. data[end-idx]
+ *
+ * The XOR checksum is calculated like this:
+ *
+ * xor = init_xor_val
+ *
+ * for (i = from_idx .. to_idx)
+ *      xor ^= can_frame.data[i]
+ *
+ * can_frame.data[ result_idx ] = xor
+ *
+ * CGW_CS_CRC8 (length 282 bytes):
+ * Set a CRC8 value into data[result-idx] using a given 256 byte CRC8 table,
+ * a given initial value and a defined input data[start-idx] .. data[end-idx].
+ * Finally the result value is XOR'ed with the final_xor_val.
+ *
+ * The CRC8 checksum is calculated like this:
+ *
+ * crc = init_crc_val
+ *
+ * for (i = from_idx .. to_idx)
+ *      crc = crctab[ crc ^ can_frame.data[i] ]
+ *
+ * can_frame.data[ result_idx ] = crc ^ final_xor_val
+ *
+ * The calculated CRC may contain additional source data elements that can be
+ * defined in the handling of 'checksum profiles' e.g. shown in AUTOSAR specs
+ * like http://www.autosar.org/download/R4.0/AUTOSAR_SWS_E2ELibrary.pdf
+ * E.g. the profile_data[] may contain additional u8 values (called DATA_IDs)
+ * that are used depending on counter values inside the CAN frame data[].
+ * So far only three profiles have been implemented for illustration.
+ *
+ * Remark: In general the attribute data is a linear buffer.
+ *         Beware of sending unpacked or aligned structs!
+ */
+
+#endif
diff --git a/include/uapi/linux/can/netlink.h b/include/uapi/linux/can/netlink.h
new file mode 100644
index 0000000..14966dd
--- /dev/null
+++ b/include/uapi/linux/can/netlink.h
@@ -0,0 +1,122 @@
+/*
+ * linux/can/netlink.h
+ *
+ * Definitions for the CAN netlink interface
+ *
+ * Copyright (c) 2009 Wolfgang Grandegger <wg@grandegger.com>
+ *
+ */
+
+#ifndef CAN_NETLINK_H
+#define CAN_NETLINK_H
+
+#include <linux/types.h>
+
+/*
+ * CAN bit-timing parameters
+ *
+ * For further information, please read chapter "8 BIT TIMING
+ * REQUIREMENTS" of the "Bosch CAN Specification version 2.0"
+ * at http://www.semiconductors.bosch.de/pdf/can2spec.pdf.
+ */
+struct can_bittiming {
+	__u32 bitrate;		/* Bit-rate in bits/second */
+	__u32 sample_point;	/* Sample point in one-tenth of a percent */
+	__u32 tq;		/* Time quanta (TQ) in nanoseconds */
+	__u32 prop_seg;		/* Propagation segment in TQs */
+	__u32 phase_seg1;	/* Phase buffer segment 1 in TQs */
+	__u32 phase_seg2;	/* Phase buffer segment 2 in TQs */
+	__u32 sjw;		/* Synchronisation jump width in TQs */
+	__u32 brp;		/* Bit-rate prescaler */
+};
+
+/*
+ * CAN harware-dependent bit-timing constant
+ *
+ * Used for calculating and checking bit-timing parameters
+ */
+struct can_bittiming_const {
+	char name[16];		/* Name of the CAN controller hardware */
+	__u32 tseg1_min;	/* Time segement 1 = prop_seg + phase_seg1 */
+	__u32 tseg1_max;
+	__u32 tseg2_min;	/* Time segement 2 = phase_seg2 */
+	__u32 tseg2_max;
+	__u32 sjw_max;		/* Synchronisation jump width */
+	__u32 brp_min;		/* Bit-rate prescaler */
+	__u32 brp_max;
+	__u32 brp_inc;
+};
+
+/*
+ * CAN clock parameters
+ */
+struct can_clock {
+	__u32 freq;		/* CAN system clock frequency in Hz */
+};
+
+/*
+ * CAN operational and error states
+ */
+enum can_state {
+	CAN_STATE_ERROR_ACTIVE = 0,	/* RX/TX error count < 96 */
+	CAN_STATE_ERROR_WARNING,	/* RX/TX error count < 128 */
+	CAN_STATE_ERROR_PASSIVE,	/* RX/TX error count < 256 */
+	CAN_STATE_BUS_OFF,		/* RX/TX error count >= 256 */
+	CAN_STATE_STOPPED,		/* Device is stopped */
+	CAN_STATE_SLEEPING,		/* Device is sleeping */
+	CAN_STATE_MAX
+};
+
+/*
+ * CAN bus error counters
+ */
+struct can_berr_counter {
+	__u16 txerr;
+	__u16 rxerr;
+};
+
+/*
+ * CAN controller mode
+ */
+struct can_ctrlmode {
+	__u32 mask;
+	__u32 flags;
+};
+
+#define CAN_CTRLMODE_LOOPBACK		0x01	/* Loopback mode */
+#define CAN_CTRLMODE_LISTENONLY		0x02 	/* Listen-only mode */
+#define CAN_CTRLMODE_3_SAMPLES		0x04	/* Triple sampling mode */
+#define CAN_CTRLMODE_ONE_SHOT		0x08	/* One-Shot mode */
+#define CAN_CTRLMODE_BERR_REPORTING	0x10	/* Bus-error reporting */
+
+/*
+ * CAN device statistics
+ */
+struct can_device_stats {
+	__u32 bus_error;	/* Bus errors */
+	__u32 error_warning;	/* Changes to error warning state */
+	__u32 error_passive;	/* Changes to error passive state */
+	__u32 bus_off;		/* Changes to bus off state */
+	__u32 arbitration_lost; /* Arbitration lost errors */
+	__u32 restarts;		/* CAN controller re-starts */
+};
+
+/*
+ * CAN netlink interface
+ */
+enum {
+	IFLA_CAN_UNSPEC,
+	IFLA_CAN_BITTIMING,
+	IFLA_CAN_BITTIMING_CONST,
+	IFLA_CAN_CLOCK,
+	IFLA_CAN_STATE,
+	IFLA_CAN_CTRLMODE,
+	IFLA_CAN_RESTART_MS,
+	IFLA_CAN_RESTART,
+	IFLA_CAN_BERR_COUNTER,
+	__IFLA_CAN_MAX
+};
+
+#define IFLA_CAN_MAX	(__IFLA_CAN_MAX - 1)
+
+#endif /* CAN_NETLINK_H */
diff --git a/include/uapi/linux/can/raw.h b/include/uapi/linux/can/raw.h
new file mode 100644
index 0000000..a814062
--- /dev/null
+++ b/include/uapi/linux/can/raw.h
@@ -0,0 +1,30 @@
+/*
+ * linux/can/raw.h
+ *
+ * Definitions for raw CAN sockets
+ *
+ * Authors: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
+ *          Urs Thuermann   <urs.thuermann@volkswagen.de>
+ * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
+ * All rights reserved.
+ *
+ */
+
+#ifndef CAN_RAW_H
+#define CAN_RAW_H
+
+#include <linux/can.h>
+
+#define SOL_CAN_RAW (SOL_CAN_BASE + CAN_RAW)
+
+/* for socket options affecting the socket (not the global system) */
+
+enum {
+	CAN_RAW_FILTER = 1,	/* set 0 .. n can_filter(s)          */
+	CAN_RAW_ERR_FILTER,	/* set filter for error frames       */
+	CAN_RAW_LOOPBACK,	/* local loopback (default:on)       */
+	CAN_RAW_RECV_OWN_MSGS,	/* receive my own msgs (default:off) */
+	CAN_RAW_FD_FRAMES,	/* allow CAN FD frames (default:off) */
+};
+
+#endif
-- 
1.7.10

