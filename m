From: Kevin Curtis <Kevin.Curtis@farsite.com>
Subject: [PATCH 002/007] WAN Drivers: Update farsync driver and introduce
 fsflex driver
Date: Wed, 18 Sep 2013 11:11:53 +0100
Message-ID: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA1@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Dermot Smith <dermot.smith@farsite.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Farsite Communications FarSync driver update

Patch 2 of 7

Introduce a new include file required by the fsflex driver.

Signed-off-by: Kevin Curtis <kevin.curtis@farsite.com>

---

diff -uprN -X linux-3.10.1/Documentation/dontdiff linux-3.10.1/drivers/net/wan/uss_cmn.h linux-3.10.1_new/drivers/net/wan/uss_cmn.h
--- linux-3.10.1/drivers/net/wan/uss_cmn.h      1970-01-01 01:00:00.000000000 +0100
+++ linux-3.10.1_new/drivers/net/wan/uss_cmn.h  2013-08-30 11:30:36.766167447 +0100
@@ -0,0 +1,492 @@
+/*
+ *      FarSync driver for Linux
+ *
+ *      Copyright (C) 2001-2013 FarSite Communications Ltd.
+ *      www.farsite.com
+ *
+ *      This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ *
+ * File        : uss_cmn.h
+ *
+ * Description : FarSync Flex common header file, shared between oncard code
+ *               and Windows and Linux drivers.
+ *
+ *               NOTE: all parameters are in Little Endian format
+ */
+
+#ifndef INC_USS_CMN
+#define INC_USS_CMN
+
+/* All user data frames transmitted/received to/from the FarSync Flex have an
+ *  eight-byte preamble. Although the transmitter does not use all elements of
+ * the preamble, they are included to simplify loopback testing etc.
+ */
+
+#include "fscmn.h"
+
+#define RXDATA_STATUS 0x00
+#define TXDATA_STATUS 0x10
+#define SIGNAL_CHANGE 0x20
+#define TXRX_ERROR    0x30
+
+#define FLEX_TXRX_PREAMBLE FSCMN_TXRX_PREAMBLE
+#define _FLEX_TXRX_PREAMBLE _FSCMN_TXRX_PREAMBLE
+#define PFLEX_TXRX_PREAMBLE PFSCMN_TXRX_PREAMBLE
+
+/* USB Device Requests sent to the card via the default Control Pipe. */
+
+/* When bmRequestType is Vendor; bRequest is defined below.
+ * wValue is a 16-bit parameter whose use varies by command.
+ * wIndex is a 16-bit parameter that usually directs the command to a specific
+ * port, it is sometimes used in conjuncton with wValue to form a 32-bit
+ * parameter for some of the memory access commands.
+ * wLength is is 16-bit paremeter that defines the amount of data associated
+ * with a command. Valid range is zero (no data) to 256 maximum (bytes).
+ * Data is a variable length block containing data specific to each command.
+ */
+
+/* command code */
+
+typedef enum _USS_COMMANDS {
+       USS_CMD_GET_VERSION = 1,        /* 0x01 */
+       USS_CMD_READ_FLASH,     /* 0x02 */
+       USS_CMD_WRITE_FLASH,    /* 0x03 */
+       USS_CMD_ERASE_FLASH,    /* 0x04 */
+
+       USS_CMD_START_PORT,     /* 0x05 */
+       USS_CMD_STOP_PORT,      /* 0x06 */
+       USS_CMD_ABORT_PORT,     /* 0x07 */
+
+       USS_CMD_SET_CONFIG,     /* 0x08 */
+       USS_CMD_GET_CONFIG,     /* 0x09 */
+
+       USS_CMD_SET_SIGNALS,    /* 0x0A */
+       USS_CMD_GET_SIGNALS,    /* 0x0B */
+
+       USS_CMD_START_BREAK,    /* 0x0C */
+       USS_CMD_STOP_BREAK,     /* 0x0D */
+
+       USS_CMD_SEND_XON,       /* 0x0E */
+       USS_CMD_SEND_XOFF,      /* 0x0F */
+
+       USS_CMD_RESET_STATS,    /* 0x10 */
+
+       USS_CMD_RESET_TIME,     /* 0x11 */
+
+       USS_CMD_FLUSH_BUFFERS,  /* 0x12 */
+
+       USS_CMD_SET_DEBUG_LEVEL,        /* 0x13 */
+
+       USS_CMD_SEND_SECURE_MSG,        /* 0x14 */
+       USS_CMD_RECV_SECURE_RSP,        /* 0x15 */
+
+       USS_CMD_SET_INTERFACE,  /* 0x16 */
+       USS_CMD_GET_INTERFACE,  /* 0x17 */
+
+       USS_CMD_SET_TERMINATION,        /* 0x18 */
+       USS_CMD_GET_TERMINATION,        /* 0x19 */
+
+       USS_CMD_SET_LINESPEED,  /* 0x1A */
+       USS_CMD_GET_LINESPEED,  /* 0x1B */
+
+       USS_CMD_SET_CLOCK_SOURCE,       /* 0x1C */
+       USS_CMD_GET_CLOCK_SOURCE,       /* 0x1D */
+
+       USS_CMD_SET_ENCODING,   /* 0x1E */
+       USS_CMD_GET_ENCODING,   /* 0x1F */
+
+       USS_CMD_SET_DATA_MODE,  /* 0x20 */
+       USS_CMD_GET_DATA_MODE,  /* 0x21 */
+
+       USS_CMD_SET_SYNC_CHAR,  /* 0x22 */
+       USS_CMD_GET_SYNC_CHAR,  /* 0x23 */
+
+       USS_CMD_SET_BIT_ORDER,  /* 0x24 */
+       USS_CMD_GET_BIT_ORDER,  /* 0x25 */
+
+       USS_CMD_SET_RXC_INVERT, /* 0x26 */
+       USS_CMD_GET_RXC_INVERT, /* 0x27 */
+
+       USS_CMD_SET_START_MODE, /* 0x28 */
+       USS_CMD_GET_START_MODE, /* 0x29 */
+
+       USS_CMD_SET_NUM_TX_BUFFER,      /* 0x2A */
+       USS_CMD_GET_NUM_TX_BUFFER,      /* 0x2B */
+
+       USS_CMD_SET_NUM_RX_BUFFER,      /* 0x2C */
+       USS_CMD_GET_NUM_RX_BUFFER,      /* 0x2D */
+
+       USS_CMD_SET_SIZE_TX_BUFFER,     /* 0x2E */
+       USS_CMD_GET_SIZE_TX_BUFFER,     /* 0x2F */
+
+       USS_CMD_SET_SIZE_RX_BUFFER,     /* 0x30 */
+       USS_CMD_GET_SIZE_RX_BUFFER,     /* 0x31 */
+
+       USS_CMD_SET_DATA_BITS,  /* 0x32 */
+       USS_CMD_GET_DATA_BITS,  /* 0x33 */
+
+       USS_CMD_SET_PARITY,     /* 0x34 */
+       USS_CMD_GET_PARITY,     /* 0x35 */
+
+       USS_CMD_SET_STOP_BITS,  /* 0x36 */
+       USS_CMD_GET_STOP_BITS,  /* 0x37 */
+
+       USS_CMD_SET_FLOW_CONTROL,       /* 0x38 */
+       USS_CMD_GET_FLOW_CONTROL,       /* 0x39 */
+
+       USS_CMD_SET_RX_TIMEOUT_ENABLE,  /* 0x3A */
+       USS_CMD_GET_RX_TIMEOUT_ENABLE,  /* 0x3B */
+
+       USS_CMD_SET_RX_TIMEOUT_LENGTH,  /* 0x3C */
+       USS_CMD_GET_RX_TIMEOUT_LENGTH,  /* 0x3D */
+
+       USS_CMD_RESET_PORT_STATS,       /* 0x3E */
+       USS_CMD_GET_PORT_STATS, /* 0x3F */
+
+       USS_CMD_SET_IDENTIFY_MODE,      /* 0x40 */
+       USS_CMD_GET_CARD_INFO,  /* 0x41 */
+
+       USS_CMD_RESET_USB_STATS,        /* 0x42 */
+       USS_CMD_GET_USB_STATS,  /* 0x43 */
+
+       USS_CMD_SET_LOOP_MODE,  /* 0x44 */
+       USS_CMD_GET_LOOP_MODE,  /* 0x45 */
+
+       USS_CMD_GET_CLOCK_STATUS,       /* 0x46 */
+       USS_CMD_GET_CLOCK_RATE, /* 0x47 */
+
+       USS_CMD_SET_MONITOR_MODE,       /* 0x48 */
+       USS_CMD_GET_MONITOR_MODE,       /* 0x49 */
+
+       USS_CMD_SET_EXTENDED_CLOCKING,  /* 0x4A */
+       USS_CMD_GET_EXTENDED_CLOCKING,  /* 0x4B */
+
+       USS_CMD_SET_INTERNAL_TX_CLOCK,  /* 0x4C */
+       USS_CMD_GET_INTERNAL_TX_CLOCK,  /* 0x4D */
+
+       USS_CMD_SET_INTERNAL_RX_CLOCK,  /* 0x4E */
+       USS_CMD_GET_INTERNAL_RX_CLOCK,  /* 0x4F */
+
+       USS_CMD_SET_ENABLE_NRZI_CLOCKING,       /* 0x50 */
+       USS_CMD_GET_ENABLE_NRZI_CLOCKING,       /* 0x51 */
+
+       USS_CMD_SET_XON_CHAR,   /* 0x52 */
+       USS_CMD_GET_XON_CHAR,   /* 0x53 */
+
+       USS_CMD_SET_XOFF_CHAR,  /* 0x54 */
+       USS_CMD_GET_XOFF_CHAR,  /* 0x55 */
+
+       USS_CMD_SET_PRESERVE_SIGNALS,   /* 0x56 */
+       USS_CMD_GET_PRESERVE_SIGNALS,   /* 0x57 */
+
+       USS_CMD_SET_ASYNC_RX_MODE,      /* 0x58 */
+       USS_CMD_GET_ASYNC_RX_MODE,      /* 0x59 */
+
+       USS_CMD_INJECT_ERRORS,  /* 0x5A */
+
+       USS_CMD_SOFT_RESET,     /* 0x5B */
+
+       USS_CMD_SET_CRC_RESET,  /* 0x5C */
+       USS_CMD_GET_CRC_RESET,  /* 0x5D */
+
+       USS_CMD_SET_EXT_CONFIG, /* 0x5E */
+       USS_CMD_GET_EXT_CONFIG, /* 0x5F */
+
+       USS_CMD_GET_CAPABILITY_MASK,    /* 0x60 */
+       USS_CMD_GET_FEATURE_MASK,       /* 0x61 */
+
+       USS_CMD_SEND_MARK,      /* 0x62 */
+
+       /*  others to be added... */
+
+       USS_CMD_MAX             /* 0x0 */
+} USS_COMMANDS;
+
+/* Port Configuration Structure */
+
+typedef struct {
+#define FLEX_SERCONF_VERSION  8
+
+       u32 u_version;          /* Version of this structure */
+       u32 iface;              /* interface type */
+       u32 termination;        /* interface termination */
+       u32 line_speed;         /* data rate in bps */
+       u32 clock;              /* clock source */
+       u32 encoding;           /* data encoding */
+       u32 mode;               /* data mode */
+       u32 sync_char;          /* Monosync/Bisync sync characters */
+       u32 bit_order;          /* Tx/Rx MSB first */
+       u32 rxclock;            /* receive clock inversion */
+       u32 start;              /* tx and rx start */
+       u32 num_tx_buffer;
+       u32 num_rx_buffer;
+       u32 size_tx_buffer;
+       u32 size_rx_buffer;
+       u32 data_bits;          /* async data bits */
+       u32 parity;             /* async parity bits */
+       u32 stopbits;           /* async stop bits */
+       u32 flow_control;       /* async flow control */
+       u32 timeout_enable;     /* async timeout enable */
+       u32 timeout_length;     /* async timeout length */
+       u32 monitor_mode;       /* open port in monitor mode,
+                                * when TRUE - added VERSION 2
+                                */
+       u32 extended_clocking;  /* when TRUE, the following overrides clock
+                                * parameter - added VERSION 3
+                                */
+       u32 internal_tx_clock;  /* independent control over transmit clock,
+                                * TRUE => internal
+                                */
+       u32 internal_rx_clock;  /* independent control over receive  clock,
+                                * TRUE => internal
+                                */
+       u32 enable_nrzi_clocking;       /* clocking provided with NRZI data
+                                        * when TRUE - added VERSION 4
+                                        */
+       u32 xonchar;            /* xon  character, 0 => default
+                                * (ctrl-Q, 0x11)
+                                */
+       u32 xoffchar;           /* xoff character, 0 => default
+                                * (ctrl-S, 0x13)
+                                */
+       u32 preserve_signals;   /* preserve signals on port closure,
+                                * when TRUE - added VERSION 5
+                                */
+       u32 async_receive_mode; /* async specifies format of fifo rx data
+                                * - added VERSION 6
+                                */
+       u32 crc_reset;          /* CRC initial value reset - added VERSION 7 */
+       u32 extended_config;    /* Extended Configuration - added VERSION 8 */
+} FLEX_SERCONF, *PFLEX_SERCONF;
+
+/* Card Information */
+
+typedef struct {
+#define FFCARDINFO_VERSION  1
+
+       u32 u_version;          /* Version number of this structure */
+
+       u8 sz_serial_no[16];    /* FarSync Flex serial number */
+       u32 u_major_rev;                /* Major hardware revision number */
+       u32 u_minor_rev;                /* Minor hardware revision number */
+       u32 u_build_state;      /* FarSync Flex build state */
+       u32 u_cpu_speed;                /* ARM 7 CPU speed */
+       u32 u_mode;             /* Internal card mode */
+
+       u32 u_software_version; /* Version number of running code */
+       u32 u_arm_version;      /* USS2828 CHIP_VERSION register */
+       u32 uflash_manf_id;     /* Manufacturer ID of FLASH */
+       u32 uflash_dev_id;      /* Device ID of FLASH */
+       u32 u_serocco_version;  /* SEROCCO-M VER3..0 registers */
+
+       u32 spare[17];
+} FLEX_CARD_INFO, *PFLEX_CARD_INFO;    /* sizeof(FLEX_CARD_INFO) = 128 */
+
+/* USB statistics counters maintained by Flex hardware, modulo 65536 */
+
+typedef struct {
+       u32 u_rx_packet_counter;        /* number of packets received by USB
+                                * (16-bit)
+                                */
+       u32 u_packet_dropped;   /* packets dropped by USB
+                                * (16-bit)
+                                */
+       u32 u_crc_error;                /* CRC errors in token or data packets
+                                * (16-bit)
+                                */
+       u32 u_bit_stuff_error;  /* bit stuff errors (16-bit) */
+       u32 u_pid_error;                /* errors in PID fields (16-bit) */
+       u32 u_framing_error;    /* errors in SYNC and EOP fields (16-bit) */
+       u32 u_tx_packet_counter;        /* number of packets transmitted by USB
+                                * (16-bit)
+                                */
+       u32 u_stat_counter_overflow;    /* overflows in previous counters
+                                        * ( 8-bit)
+                                        */
+} FLEX_USB_STATS, *PFLEX_USB_STATS;
+
+/* Configuration Parameter Defines */
+
+/* Async data bits defines */
+
+#define COM_DATA_BITS_8       0
+#define COM_DATA_BITS_7       1
+#define COM_DATA_BITS_6       2
+#define COM_DATA_BITS_5       3
+
+#define COM_DATA_BITS_DEFAULT COM_DATA_BITS_8
+
+/* Async parity defines */
+
+#define COM_NO_PARITY         0
+#define COM_ODD_PARITY        1
+#define COM_EVEN_PARITY       2
+#define COM_FORCE_PARITY_1    3
+#define COM_FORCE_PARITY_0    4
+
+#define COM_PARITY_DEFAULT COM_NO_PARITY
+
+/* Async stop bit defines */
+
+#define COM_STOP_BITS_1       0
+#define COM_STOP_BITS_1_5     1
+#define COM_STOP_BITS_2       2
+
+#define COM_STOP_DEFAULT COM_STOP_BITS_1
+
+/* Async flow control defines */
+
+#define COM_FLOW_CONTROL_NONE     1
+#define COM_FLOW_CONTROL_RTSCTS   2
+#define COM_FLOW_CONTROL_XONXOFF  3
+
+#define COM_FLOW_CONTROL_DEFAULT COM_FLOW_CONTROL_NONE
+
+/* Flush buffers defines */
+
+#define FLUSH_TX_BUFFERS 1
+#define FLUSH_RX_BUFFERS 2
+
+/* Async timeout enable defines */
+
+#define COM_RX_TIMEOUT_DISABLE   0
+#define COM_RX_TIMEOUT_ENABLE    1
+
+#define COM_RX_TIMEOUT_DEFAULT COM_RX_TIMEOUT_DISABLE
+
+/* Async timeout length defines */
+
+/* Loopback mode defines */
+
+#define FLEX_LOOP_NONE   0
+#define FLEX_LOOP_USB    1
+#define FLEX_LOOP_SERIAL 2
+
+#define FLEX_LOOP_DEFAULT FLEX_LOOP_NONE
+
+/* Extended Configuration defines */
+
+#define EXT_CONFIG_NONE   0
+#define EXT_CONFIG_RTT   1
+#define EXT_CONFIG_TTT    2
+#define EXT_CONFIG_RIV    4
+#define EXT_CONFIG_TIV    8
+
+#define EXT_CONFIG_DEFAULT EXT_CONFIG_NONE
+
+#endif /* INC_USS_CMN */
+
+/*****************************************************************************/
+/* Structure for the device driver interface record.                         */
+/*****************************************************************************/
+
+#define CEDSTCRC  0            /* Frames received with incorrect CRC        */
+#define CEDSTOFL  1            /* Frames received longer than the maximum   */
+#define CEDSTUFL  2            /* Frames received less than 4 octets long   */
+#define CEDSTSPR  3            /* Frames received ending on a non-octet
+                                * bndry
+                                */
+#define CEDSTABT  4            /* Aborted frames received                   */
+#define CEDSTTXU  5            /* Transmitter interrupt underruns           */
+#define CEDSTRXO  6            /* Receiver    interrupt overruns            */
+#define CEDSTDCD  7            /* DCD (RLSD) lost during frame reception    */
+#define CEDSTCTS  8            /* CTS lost while transmitting               */
+#define CEDSTDSR  9            /* DSR drops                                 */
+#define CEDSTHDW 10            /* Hardware failures - adapter errors        */
+
+#define CEDSTMAX 11
+
+#define SACRCERROR        CEDSTCRC
+#define SARXFRAMETOOBIG   CEDSTOFL
+#define SARXFRAMETOOSHORT CEDSTUFL
+#define SASPARE           CEDSTSPR
+#define SARXABORT         CEDSTABT
+#define SATXUNDERRUN      CEDSTTXU
+#define SARXOVERRUN       CEDSTRXO
+#define SADCDDROP         CEDSTDCD
+#define SACTSDROP         CEDSTCTS
+#define SADSRDROP         CEDSTDSR
+#define SAHARDWAREERROR   CEDSTHDW
+
+/* FarSync-specific counters mapped to existing SDCI definitions */
+#define SAFRAMINGERROT       SASARE
+#define SARXERROR            SAHARDWAREERROR
+#define SABUFFERUNAVAILABLE  SADCDDROP
+#define SAPARITY             SACRCERROR
+
+#define SAMAXSTAT           CEDSTMAX
+
+#define STATUS_SUCCESS      0x80
+#define STATUS_PENDING      0x00
+#define STATUS_UNSUCCESSFUL 0x90
+#define STATUS_CANCELLED    0xC0
+
+/* ***************************************************************************
+ * FarSync supports the following counters. All other counter indices are not
+ * used by FarSync.
+ * SA_CRC_Error       Sync & Async modes
+ * SA_FramingError    Sync & Async modes
+ * SA_RxOverrun       Sync & Async modes
+ * SA_RxAbort         (Async) & (M1P Sync) modes only
+ * SA_RxError         Sync mode only
+ * SA_TxUnderrun      Sync mode only
+ * SA_RxFrameTooShort M1P Sync mode only
+ * SA_RxFrameTooBig   Async mode (fifo overflow) & M1P Sync
+ *    Note that
+ *      1) Async mode is currently only supported on the T4U - it is an
+ *         optional extra feature
+ *      2) On a TxU an SA_RxError indicates a received abort OR a rx frame
+ *         length error
+ *         (too big OR too small)
+ *      3) On an M1P an SA_RxError indicates a alternative type of RxO as
+ *         reported via
+ *         SA_RxOverrun
+ * ***************************************************************************
+ */
+
+/*****************************************************************************/
+/* InterfaceRecord definition                                                */
+/*                                                                           */
+/* For use with:                                                             */
+/*                                                                           */
+/*   IoctlCodeReadInterfaceRecord,                                           */
+/*   IoctlCodeFarSyncReadInterfaceRecord                                     */
+/*                                                                           */
+/*****************************************************************************/
+typedef struct _INTERFACE_RECORD {
+       int rx_frame_count;     /* incremented after each frame rx'd */
+       int tx_max_fr_size_now; /* max available frame size av. now  */
+       /* (changes after each Tx DevIoctl   */
+       /* to DD or after Tx completed)      */
+       int status_count;       /* How many status events have been  */
+       /* triggered.                        */
+       u8 v24_in;              /* Last 'getv24 i/p' value got       */
+       u8 v24_out;             /* Last 'setv24 o/p' value set       */
+
+/* The values for the indexes into the link statistics array of the */
+/* various types of statistic. */
+
+       int status_array[SAMAXSTAT];
+
+} IR, *PIR;
+
+/*****************************************************************************/
+/* InterfaceRecordEx definition                                              */
+/*                                                                           */
+/* For use with:                                                             */
+/*                                                                           */
+/*   IoctlCodeFarSyncReadInterfaceRecordEx                                   */
+/*                                                                           */
+/*****************************************************************************/
+typedef struct _INTERFACE_RECORD_EX {
+       IR interface_record;
+       int status_count;       /* How many status events have been  */
+       u32 opened_count;
+       u32 tx_request_count;
+       u32 tx_complete_count;
+       u32 rx_posted_count;
+       u32 rx_complete_count;
+} IREX, *PIREX;
