From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/8] isdn/gigaset: fix readability damage
Date: Thu, 26 Apr 2012 01:02:20 +0200 (CEST)
Message-ID: <20120425-patch-gigaset-04.tilman@imap.cc>
References: <20120425-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:43618 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932416Ab2DYXDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 19:03:04 -0400
In-Reply-To: <20120425-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix up some of the readibility deterioration caused by the recent
whitespace coding style cleanup.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/bas-gigaset.c |   11 +-
 drivers/isdn/gigaset/capi.c        |   84 +++++------
 drivers/isdn/gigaset/ev-layer.c    |  301 ++++++++++++++++++------------------
 drivers/isdn/gigaset/gigaset.h     |   28 ++--
 4 files changed, 208 insertions(+), 216 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index afa0802..d651523 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -410,10 +410,10 @@ static void check_pending(struct bas_cardstate *ucs)
 		if (!(ucs->basstate & BS_RESETTING))
 			ucs->pending = 0;
 		break;
-		/*
-		 * HD_READ_ATMESSAGE and HD_WRITE_ATMESSAGE are handled separately
-		 * and should never end up here
-		 */
+	/*
+	 * HD_READ_ATMESSAGE and HD_WRITE_ATMESSAGE are handled separately
+	 * and should never end up here
+	 */
 	default:
 		dev_warn(&ucs->interface->dev,
 			 "unknown pending request 0x%02x cleared\n",
@@ -877,8 +877,7 @@ static void read_iso_callback(struct urb *urb)
 		for (i = 0; i < BAS_NUMFRAMES; i++) {
 			ubc->isoinlost += urb->iso_frame_desc[i].actual_length;
 			if (unlikely(urb->iso_frame_desc[i].status != 0 &&
-				     urb->iso_frame_desc[i].status !=
-				     -EINPROGRESS))
+				     urb->iso_frame_desc[i].status != -EINPROGRESS))
 				ubc->loststatus = urb->iso_frame_desc[i].status;
 			urb->iso_frame_desc[i].status = 0;
 			urb->iso_frame_desc[i].actual_length = 0;
diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 579aa02..86cee65 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -109,51 +109,35 @@ static struct {
 	u8 *bc;
 	u8 *hlc;
 } cip2bchlc[] = {
-	[1] = { "8090A3", NULL },
-	/* Speech (A-law) */
-	[2] = { "8890", NULL },
-	/* Unrestricted digital information */
-	[3] = { "8990", NULL },
-	/* Restricted digital information */
-	[4] = { "9090A3", NULL },
-	/* 3,1 kHz audio (A-law) */
-	[5] = { "9190", NULL },
-	/* 7 kHz audio */
-	[6] = { "9890", NULL },
-	/* Video */
-	[7] = { "88C0C6E6", NULL },
-	/* Packet mode */
-	[8] = { "8890218F", NULL },
-	/* 56 kbit/s rate adaptation */
-	[9] = { "9190A5", NULL },
-	/* Unrestricted digital information with tones/announcements */
-	[16] = { "8090A3", "9181" },
-	/* Telephony */
-	[17] = { "9090A3", "9184" },
-	/* Group 2/3 facsimile */
-	[18] = { "8890", "91A1" },
-	/* Group 4 facsimile Class 1 */
-	[19] = { "8890", "91A4" },
-	/* Teletex service basic and mixed mode
-	   and Group 4 facsimile service Classes II and III */
-	[20] = { "8890", "91A8" },
-	/* Teletex service basic and processable mode */
-	[21] = { "8890", "91B1" },
-	/* Teletex service basic mode */
-	[22] = { "8890", "91B2" },
-	/* International interworking for Videotex */
-	[23] = { "8890", "91B5" },
-	/* Telex */
-	[24] = { "8890", "91B8" },
-	/* Message Handling Systems in accordance with X.400 */
-	[25] = { "8890", "91C1" },
-	/* OSI application in accordance with X.200 */
-	[26] = { "9190A5", "9181" },
-	/* 7 kHz telephony */
-	[27] = { "9190A5", "916001" },
-	/* Video telephony, first connection */
-	[28] = { "8890", "916002" },
-	/* Video telephony, second connection */
+	[1] = { "8090A3", NULL },	/* Speech (A-law) */
+	[2] = { "8890", NULL },		/* Unrestricted digital information */
+	[3] = { "8990", NULL },		/* Restricted digital information */
+	[4] = { "9090A3", NULL },	/* 3,1 kHz audio (A-law) */
+	[5] = { "9190", NULL },		/* 7 kHz audio */
+	[6] = { "9890", NULL },		/* Video */
+	[7] = { "88C0C6E6", NULL },	/* Packet mode */
+	[8] = { "8890218F", NULL },	/* 56 kbit/s rate adaptation */
+	[9] = { "9190A5", NULL },	/* Unrestricted digital information
+					 * with tones/announcements */
+	[16] = { "8090A3", "9181" },	/* Telephony */
+	[17] = { "9090A3", "9184" },	/* Group 2/3 facsimile */
+	[18] = { "8890", "91A1" },	/* Group 4 facsimile Class 1 */
+	[19] = { "8890", "91A4" },	/* Teletex service basic and mixed mode
+					 * and Group 4 facsimile service
+					 * Classes II and III */
+	[20] = { "8890", "91A8" },	/* Teletex service basic and
+					 * processable mode */
+	[21] = { "8890", "91B1" },	/* Teletex service basic mode */
+	[22] = { "8890", "91B2" },	/* International interworking for
+					 * Videotex */
+	[23] = { "8890", "91B5" },	/* Telex */
+	[24] = { "8890", "91B8" },	/* Message Handling Systems
+					 * in accordance with X.400 */
+	[25] = { "8890", "91C1" },	/* OSI application
+					 * in accordance with X.200 */
+	[26] = { "9190A5", "9181" },	/* 7 kHz telephony */
+	[27] = { "9190A5", "916001" },	/* Video telephony, first connection */
+	[28] = { "8890", "916002" },	/* Video telephony, second connection */
 };
 
 /*
@@ -1197,7 +1181,9 @@ static void do_facility_req(struct gigaset_capi_ctr *iif,
 			confparam[3] = 2;	/* length */
 			capimsg_setu16(confparam, 4, CapiSuccess);
 			break;
-			/* ToDo: add supported services */
+
+		/* ToDo: add supported services */
+
 		default:
 			dev_notice(cs->dev,
 				   "%s: unsupported supplementary service function 0x%04x\n",
@@ -1771,7 +1757,8 @@ static void do_connect_b3_req(struct gigaset_capi_ctr *iif,
 
 	/* NCPI parameter: not applicable for B3 Transparent */
 	ignore_cstruct_param(cs, cmsg->NCPI, "CONNECT_B3_REQ", "NCPI");
-	send_conf(iif, ap, skb, (cmsg->NCPI && cmsg->NCPI[0]) ?
+	send_conf(iif, ap, skb,
+		  (cmsg->NCPI && cmsg->NCPI[0]) ?
 		  CapiNcpiNotSupportedByProtocol : CapiSuccess);
 }
 
@@ -1975,7 +1962,8 @@ static void do_disconnect_b3_req(struct gigaset_capi_ctr *iif,
 	/* NCPI parameter: not applicable for B3 Transparent */
 	ignore_cstruct_param(cs, cmsg->NCPI,
 			     "DISCONNECT_B3_REQ", "NCPI");
-	send_conf(iif, ap, skb, (cmsg->NCPI && cmsg->NCPI[0]) ?
+	send_conf(iif, ap, skb,
+		  (cmsg->NCPI && cmsg->NCPI[0]) ?
 		  CapiNcpiNotSupportedByProtocol : CapiSuccess);
 }
 
diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index 685638a..8391e09 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -153,104 +153,104 @@ struct reply_t gigaset_tab_nocid[] =
  * action, command */
 
 /* initialize device, set cid mode if possible */
-	{RSP_INIT,	 -1,  -1, SEQ_INIT,		100,  1, {ACT_TIMEOUT} },
+	{RSP_INIT,	 -1,  -1, SEQ_INIT,	100,  1, {ACT_TIMEOUT} },
 
-	{EV_TIMEOUT,	100, 100, -1,			101,  3, {0},	"Z\r"},
-	{RSP_OK,	101, 103, -1,			120,  5, {ACT_GETSTRING},
-	 "+GMR\r"},
+	{EV_TIMEOUT,	100, 100, -1,		101,  3, {0},	"Z\r"},
+	{RSP_OK,	101, 103, -1,		120,  5, {ACT_GETSTRING},
+								"+GMR\r"},
 
-	{EV_TIMEOUT,	101, 101, -1,			102,  5, {0},	"Z\r"},
-	{RSP_ERROR,	101, 101, -1,			102,  5, {0},	"Z\r"},
+	{EV_TIMEOUT,	101, 101, -1,		102,  5, {0},	"Z\r"},
+	{RSP_ERROR,	101, 101, -1,		102,  5, {0},	"Z\r"},
 
-	{EV_TIMEOUT,	102, 102, -1,			108,  5, {ACT_SETDLE1},
-	 "^SDLE=0\r"},
-	{RSP_OK,	108, 108, -1,			104, -1},
-	{RSP_ZDLE,	104, 104,  0,			103,  5, {0},	"Z\r"},
-	{EV_TIMEOUT,	104, 104, -1,			  0,  0, {ACT_FAILINIT} },
-	{RSP_ERROR,	108, 108, -1,			  0,  0, {ACT_FAILINIT} },
+	{EV_TIMEOUT,	102, 102, -1,		108,  5, {ACT_SETDLE1},
+								"^SDLE=0\r"},
+	{RSP_OK,	108, 108, -1,		104, -1},
+	{RSP_ZDLE,	104, 104,  0,		103,  5, {0},	"Z\r"},
+	{EV_TIMEOUT,	104, 104, -1,		  0,  0, {ACT_FAILINIT} },
+	{RSP_ERROR,	108, 108, -1,		  0,  0, {ACT_FAILINIT} },
 
-	{EV_TIMEOUT,	108, 108, -1,			105,  2, {ACT_SETDLE0,
-								  ACT_HUPMODEM,
-								  ACT_TIMEOUT} },
-	{EV_TIMEOUT,	105, 105, -1,			103,  5, {0},	"Z\r"},
+	{EV_TIMEOUT,	108, 108, -1,		105,  2, {ACT_SETDLE0,
+							  ACT_HUPMODEM,
+							  ACT_TIMEOUT} },
+	{EV_TIMEOUT,	105, 105, -1,		103,  5, {0},	"Z\r"},
 
-	{RSP_ERROR,	102, 102, -1,			107,  5, {0},	"^GETPRE\r"},
-	{RSP_OK,	107, 107, -1,			  0,  0, {ACT_CONFIGMODE} },
-	{RSP_ERROR,	107, 107, -1,			  0,  0, {ACT_FAILINIT} },
-	{EV_TIMEOUT,	107, 107, -1,			  0,  0, {ACT_FAILINIT} },
+	{RSP_ERROR,	102, 102, -1,		107,  5, {0},	"^GETPRE\r"},
+	{RSP_OK,	107, 107, -1,		  0,  0, {ACT_CONFIGMODE} },
+	{RSP_ERROR,	107, 107, -1,		  0,  0, {ACT_FAILINIT} },
+	{EV_TIMEOUT,	107, 107, -1,		  0,  0, {ACT_FAILINIT} },
 
-	{RSP_ERROR,	103, 103, -1,			  0,  0, {ACT_FAILINIT} },
-	{EV_TIMEOUT,	103, 103, -1,			  0,  0, {ACT_FAILINIT} },
+	{RSP_ERROR,	103, 103, -1,		  0,  0, {ACT_FAILINIT} },
+	{EV_TIMEOUT,	103, 103, -1,		  0,  0, {ACT_FAILINIT} },
 
-	{RSP_STRING,	120, 120, -1,			121, -1, {ACT_SETVER} },
+	{RSP_STRING,	120, 120, -1,		121, -1, {ACT_SETVER} },
 
-	{EV_TIMEOUT,	120, 121, -1,			  0,  0, {ACT_FAILVER,
-								  ACT_INIT} },
-	{RSP_ERROR,	120, 121, -1,			  0,  0, {ACT_FAILVER,
-								  ACT_INIT} },
-	{RSP_OK,	121, 121, -1,			  0,  0, {ACT_GOTVER,
-								  ACT_INIT} },
-	{RSP_NONE,	121, 121, -1,			120,  0, {ACT_GETSTRING} },
+	{EV_TIMEOUT,	120, 121, -1,		  0,  0, {ACT_FAILVER,
+							  ACT_INIT} },
+	{RSP_ERROR,	120, 121, -1,		  0,  0, {ACT_FAILVER,
+							  ACT_INIT} },
+	{RSP_OK,	121, 121, -1,		  0,  0, {ACT_GOTVER,
+							  ACT_INIT} },
+	{RSP_NONE,	121, 121, -1,		120,  0, {ACT_GETSTRING} },
 
 /* leave dle mode */
-	{RSP_INIT,	  0,   0, SEQ_DLE0,		201,  5, {0},	"^SDLE=0\r"},
-	{RSP_OK,	201, 201, -1,			202, -1},
-	{RSP_ZDLE,	202, 202,  0,			  0,  0, {ACT_DLE0} },
-	{RSP_NODEV,	200, 249, -1,			  0,  0, {ACT_FAKEDLE0} },
-	{RSP_ERROR,	200, 249, -1,			  0,  0, {ACT_FAILDLE0} },
-	{EV_TIMEOUT,	200, 249, -1,			  0,  0, {ACT_FAILDLE0} },
+	{RSP_INIT,	  0,   0, SEQ_DLE0,	201,  5, {0},	"^SDLE=0\r"},
+	{RSP_OK,	201, 201, -1,		202, -1},
+	{RSP_ZDLE,	202, 202,  0,		  0,  0, {ACT_DLE0} },
+	{RSP_NODEV,	200, 249, -1,		  0,  0, {ACT_FAKEDLE0} },
+	{RSP_ERROR,	200, 249, -1,		  0,  0, {ACT_FAILDLE0} },
+	{EV_TIMEOUT,	200, 249, -1,		  0,  0, {ACT_FAILDLE0} },
 
 /* enter dle mode */
-	{RSP_INIT,	  0,   0, SEQ_DLE1,		251,  5, {0},	"^SDLE=1\r"},
-	{RSP_OK,	251, 251, -1,			252, -1},
-	{RSP_ZDLE,	252, 252,  1,			  0,  0, {ACT_DLE1} },
-	{RSP_ERROR,	250, 299, -1,			  0,  0, {ACT_FAILDLE1} },
-	{EV_TIMEOUT,	250, 299, -1,			  0,  0, {ACT_FAILDLE1} },
+	{RSP_INIT,	  0,   0, SEQ_DLE1,	251,  5, {0},	"^SDLE=1\r"},
+	{RSP_OK,	251, 251, -1,		252, -1},
+	{RSP_ZDLE,	252, 252,  1,		  0,  0, {ACT_DLE1} },
+	{RSP_ERROR,	250, 299, -1,		  0,  0, {ACT_FAILDLE1} },
+	{EV_TIMEOUT,	250, 299, -1,		  0,  0, {ACT_FAILDLE1} },
 
 /* incoming call */
-	{RSP_RING,	 -1,  -1, -1,			 -1, -1, {ACT_RING} },
+	{RSP_RING,	 -1,  -1, -1,		 -1, -1, {ACT_RING} },
 
 /* get cid */
-	{RSP_INIT,	  0,   0, SEQ_CID,		301,  5, {0},	"^SGCI?\r"},
-	{RSP_OK,	301, 301, -1,			302, -1},
-	{RSP_ZGCI,	302, 302, -1,			  0,  0, {ACT_CID} },
-	{RSP_ERROR,	301, 349, -1,			  0,  0, {ACT_FAILCID} },
-	{EV_TIMEOUT,	301, 349, -1,			  0,  0, {ACT_FAILCID} },
+	{RSP_INIT,	  0,   0, SEQ_CID,	301,  5, {0},	"^SGCI?\r"},
+	{RSP_OK,	301, 301, -1,		302, -1},
+	{RSP_ZGCI,	302, 302, -1,		  0,  0, {ACT_CID} },
+	{RSP_ERROR,	301, 349, -1,		  0,  0, {ACT_FAILCID} },
+	{EV_TIMEOUT,	301, 349, -1,		  0,  0, {ACT_FAILCID} },
 
 /* enter cid mode */
-	{RSP_INIT,	  0,   0, SEQ_CIDMODE,		150,  5, {0},	"^SGCI=1\r"},
-	{RSP_OK,	150, 150, -1,			  0,  0, {ACT_CMODESET} },
-	{RSP_ERROR,	150, 150, -1,			  0,  0, {ACT_FAILCMODE} },
-	{EV_TIMEOUT,	150, 150, -1,			  0,  0, {ACT_FAILCMODE} },
+	{RSP_INIT,	  0,   0, SEQ_CIDMODE,	150,  5, {0},	"^SGCI=1\r"},
+	{RSP_OK,	150, 150, -1,		  0,  0, {ACT_CMODESET} },
+	{RSP_ERROR,	150, 150, -1,		  0,  0, {ACT_FAILCMODE} },
+	{EV_TIMEOUT,	150, 150, -1,		  0,  0, {ACT_FAILCMODE} },
 
 /* leave cid mode */
-	{RSP_INIT,	  0,   0, SEQ_UMMODE,		160,  5, {0},	"Z\r"},
-	{RSP_OK,	160, 160, -1,			  0,  0, {ACT_UMODESET} },
-	{RSP_ERROR,	160, 160, -1,			  0,  0, {ACT_FAILUMODE} },
-	{EV_TIMEOUT,	160, 160, -1,			  0,  0, {ACT_FAILUMODE} },
+	{RSP_INIT,	  0,   0, SEQ_UMMODE,	160,  5, {0},	"Z\r"},
+	{RSP_OK,	160, 160, -1,		  0,  0, {ACT_UMODESET} },
+	{RSP_ERROR,	160, 160, -1,		  0,  0, {ACT_FAILUMODE} },
+	{EV_TIMEOUT,	160, 160, -1,		  0,  0, {ACT_FAILUMODE} },
 
 /* abort getting cid */
-	{RSP_INIT,	  0,   0, SEQ_NOCID,		  0,  0, {ACT_ABORTCID} },
+	{RSP_INIT,	  0,   0, SEQ_NOCID,	  0,  0, {ACT_ABORTCID} },
 
 /* reset */
-	{RSP_INIT,	  0,   0, SEQ_SHUTDOWN,		504,  5, {0},	"Z\r"},
-	{RSP_OK,	504, 504, -1,			  0,  0, {ACT_SDOWN} },
-	{RSP_ERROR,	501, 599, -1,			  0,  0, {ACT_FAILSDOWN} },
-	{EV_TIMEOUT,	501, 599, -1,			  0,  0, {ACT_FAILSDOWN} },
-	{RSP_NODEV,	501, 599, -1,			  0,  0, {ACT_FAKESDOWN} },
-
-	{EV_PROC_CIDMODE, -1, -1, -1,			 -1, -1, {ACT_PROC_CIDMODE} },
-	{EV_IF_LOCK,	 -1,  -1, -1,			 -1, -1, {ACT_IF_LOCK} },
-	{EV_IF_VER,	 -1,  -1, -1,			 -1, -1, {ACT_IF_VER} },
-	{EV_START,	 -1,  -1, -1,			 -1, -1, {ACT_START} },
-	{EV_STOP,	 -1,  -1, -1,			 -1, -1, {ACT_STOP} },
-	{EV_SHUTDOWN,	 -1,  -1, -1,			 -1, -1, {ACT_SHUTDOWN} },
+	{RSP_INIT,	  0,   0, SEQ_SHUTDOWN,	504,  5, {0},	"Z\r"},
+	{RSP_OK,	504, 504, -1,		  0,  0, {ACT_SDOWN} },
+	{RSP_ERROR,	501, 599, -1,		  0,  0, {ACT_FAILSDOWN} },
+	{EV_TIMEOUT,	501, 599, -1,		  0,  0, {ACT_FAILSDOWN} },
+	{RSP_NODEV,	501, 599, -1,		  0,  0, {ACT_FAKESDOWN} },
+
+	{EV_PROC_CIDMODE, -1, -1, -1,		 -1, -1, {ACT_PROC_CIDMODE} },
+	{EV_IF_LOCK,	 -1,  -1, -1,		 -1, -1, {ACT_IF_LOCK} },
+	{EV_IF_VER,	 -1,  -1, -1,		 -1, -1, {ACT_IF_VER} },
+	{EV_START,	 -1,  -1, -1,		 -1, -1, {ACT_START} },
+	{EV_STOP,	 -1,  -1, -1,		 -1, -1, {ACT_STOP} },
+	{EV_SHUTDOWN,	 -1,  -1, -1,		 -1, -1, {ACT_SHUTDOWN} },
 
 /* misc. */
-	{RSP_ERROR,	 -1,  -1, -1,			 -1, -1, {ACT_ERROR} },
-	{RSP_ZCAU,	 -1,  -1, -1,			 -1, -1, {ACT_ZCAU} },
-	{RSP_NONE,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-	{RSP_ANY,	 -1,  -1, -1,			 -1, -1, {ACT_WARN} },
+	{RSP_ERROR,	 -1,  -1, -1,		 -1, -1, {ACT_ERROR} },
+	{RSP_ZCAU,	 -1,  -1, -1,		 -1, -1, {ACT_ZCAU} },
+	{RSP_NONE,	 -1,  -1, -1,		 -1, -1, {ACT_DEBUG} },
+	{RSP_ANY,	 -1,  -1, -1,		 -1, -1, {ACT_WARN} },
 	{RSP_LAST}
 };
 
@@ -262,90 +262,90 @@ struct reply_t gigaset_tab_cid[] =
  * action, command */
 
 /* dial */
-	{EV_DIAL,	 -1,  -1, -1,			 -1, -1, {ACT_DIAL} },
-	{RSP_INIT,	  0,   0, SEQ_DIAL,		601,  5, {ACT_CMD + AT_BC} },
-	{RSP_OK,	601, 601, -1,			603,  5, {ACT_CMD + AT_PROTO} },
-	{RSP_OK,	603, 603, -1,			604,  5, {ACT_CMD + AT_TYPE} },
-	{RSP_OK,	604, 604, -1,			605,  5, {ACT_CMD + AT_MSN} },
-	{RSP_NULL,	605, 605, -1,			606,  5, {ACT_CMD + AT_CLIP} },
-	{RSP_OK,	605, 605, -1,			606,  5, {ACT_CMD + AT_CLIP} },
-	{RSP_NULL,	606, 606, -1,			607,  5, {ACT_CMD + AT_ISO} },
-	{RSP_OK,	606, 606, -1,			607,  5, {ACT_CMD + AT_ISO} },
-	{RSP_OK,	607, 607, -1,			608,  5, {0},	"+VLS=17\r"},
-	{RSP_OK,	608, 608, -1,			609, -1},
-	{RSP_ZSAU,	609, 609, ZSAU_PROCEEDING,	610,  5, {ACT_CMD + AT_DIAL} },
-	{RSP_OK,	610, 610, -1,			650,  0, {ACT_DIALING} },
-
-	{RSP_ERROR,	601, 610, -1,			  0,  0, {ACT_ABORTDIAL} },
-	{EV_TIMEOUT,	601, 610, -1,			  0,  0, {ACT_ABORTDIAL} },
+	{EV_DIAL,	 -1,  -1, -1,		 -1, -1, {ACT_DIAL} },
+	{RSP_INIT,	  0,   0, SEQ_DIAL,	601,  5, {ACT_CMD + AT_BC} },
+	{RSP_OK,	601, 601, -1,		603,  5, {ACT_CMD + AT_PROTO} },
+	{RSP_OK,	603, 603, -1,		604,  5, {ACT_CMD + AT_TYPE} },
+	{RSP_OK,	604, 604, -1,		605,  5, {ACT_CMD + AT_MSN} },
+	{RSP_NULL,	605, 605, -1,		606,  5, {ACT_CMD + AT_CLIP} },
+	{RSP_OK,	605, 605, -1,		606,  5, {ACT_CMD + AT_CLIP} },
+	{RSP_NULL,	606, 606, -1,		607,  5, {ACT_CMD + AT_ISO} },
+	{RSP_OK,	606, 606, -1,		607,  5, {ACT_CMD + AT_ISO} },
+	{RSP_OK,	607, 607, -1,		608,  5, {0},	"+VLS=17\r"},
+	{RSP_OK,	608, 608, -1,		609, -1},
+	{RSP_ZSAU,	609, 609, ZSAU_PROCEEDING, 610, 5, {ACT_CMD + AT_DIAL} },
+	{RSP_OK,	610, 610, -1,		650,  0, {ACT_DIALING} },
+
+	{RSP_ERROR,	601, 610, -1,		  0,  0, {ACT_ABORTDIAL} },
+	{EV_TIMEOUT,	601, 610, -1,		  0,  0, {ACT_ABORTDIAL} },
 
 /* optional dialing responses */
-	{EV_BC_OPEN,	650, 650, -1,			651, -1},
-	{RSP_ZVLS,	609, 651, 17,			 -1, -1, {ACT_DEBUG} },
-	{RSP_ZCTP,	610, 651, -1,			 -1, -1, {ACT_DEBUG} },
-	{RSP_ZCPN,	610, 651, -1,			 -1, -1, {ACT_DEBUG} },
-	{RSP_ZSAU,	650, 651, ZSAU_CALL_DELIVERED,	 -1, -1, {ACT_DEBUG} },
+	{EV_BC_OPEN,	650, 650, -1,		651, -1},
+	{RSP_ZVLS,	609, 651, 17,		 -1, -1, {ACT_DEBUG} },
+	{RSP_ZCTP,	610, 651, -1,		 -1, -1, {ACT_DEBUG} },
+	{RSP_ZCPN,	610, 651, -1,		 -1, -1, {ACT_DEBUG} },
+	{RSP_ZSAU,	650, 651, ZSAU_CALL_DELIVERED, -1, -1, {ACT_DEBUG} },
 
 /* connect */
-	{RSP_ZSAU,	650, 650, ZSAU_ACTIVE,		800, -1, {ACT_CONNECT} },
-	{RSP_ZSAU,	651, 651, ZSAU_ACTIVE,		800, -1, {ACT_CONNECT,
-								  ACT_NOTIFY_BC_UP} },
-	{RSP_ZSAU,	750, 750, ZSAU_ACTIVE,		800, -1, {ACT_CONNECT} },
-	{RSP_ZSAU,	751, 751, ZSAU_ACTIVE,		800, -1, {ACT_CONNECT,
-								  ACT_NOTIFY_BC_UP} },
-	{EV_BC_OPEN,	800, 800, -1,			800, -1, {ACT_NOTIFY_BC_UP} },
+	{RSP_ZSAU,	650, 650, ZSAU_ACTIVE,	800, -1, {ACT_CONNECT} },
+	{RSP_ZSAU,	651, 651, ZSAU_ACTIVE,	800, -1, {ACT_CONNECT,
+							  ACT_NOTIFY_BC_UP} },
+	{RSP_ZSAU,	750, 750, ZSAU_ACTIVE,	800, -1, {ACT_CONNECT} },
+	{RSP_ZSAU,	751, 751, ZSAU_ACTIVE,	800, -1, {ACT_CONNECT,
+							  ACT_NOTIFY_BC_UP} },
+	{EV_BC_OPEN,	800, 800, -1,		800, -1, {ACT_NOTIFY_BC_UP} },
 
 /* remote hangup */
-	{RSP_ZSAU,	650, 651, ZSAU_DISCONNECT_IND,	  0,  0, {ACT_REMOTEREJECT} },
-	{RSP_ZSAU,	750, 751, ZSAU_DISCONNECT_IND,	  0,  0, {ACT_REMOTEHUP} },
-	{RSP_ZSAU,	800, 800, ZSAU_DISCONNECT_IND,	  0,  0, {ACT_REMOTEHUP} },
+	{RSP_ZSAU,	650, 651, ZSAU_DISCONNECT_IND, 0, 0, {ACT_REMOTEREJECT} },
+	{RSP_ZSAU,	750, 751, ZSAU_DISCONNECT_IND, 0, 0, {ACT_REMOTEHUP} },
+	{RSP_ZSAU,	800, 800, ZSAU_DISCONNECT_IND, 0, 0, {ACT_REMOTEHUP} },
 
 /* hangup */
-	{EV_HUP,	 -1,  -1, -1,			 -1, -1, {ACT_HUP} },
-	{RSP_INIT,	 -1,  -1, SEQ_HUP,		401,  5, {0},	"+VLS=0\r"},
-	{RSP_OK,	401, 401, -1,			402,  5},
-	{RSP_ZVLS,	402, 402,  0,			403,  5},
-	{RSP_ZSAU,	403, 403, ZSAU_DISCONNECT_REQ,	 -1, -1, {ACT_DEBUG} },
-	{RSP_ZSAU,	403, 403, ZSAU_NULL,		  0,  0, {ACT_DISCONNECT} },
-	{RSP_NODEV,	401, 403, -1,			  0,  0, {ACT_FAKEHUP} },
-	{RSP_ERROR,	401, 401, -1,			  0,  0, {ACT_ABORTHUP} },
-	{EV_TIMEOUT,	401, 403, -1,			  0,  0, {ACT_ABORTHUP} },
-
-	{EV_BC_CLOSED,	  0,   0, -1,			  0, -1, {ACT_NOTIFY_BC_DOWN} },
+	{EV_HUP,	 -1,  -1, -1,		 -1, -1, {ACT_HUP} },
+	{RSP_INIT,	 -1,  -1, SEQ_HUP,	401,  5, {0},	"+VLS=0\r"},
+	{RSP_OK,	401, 401, -1,		402,  5},
+	{RSP_ZVLS,	402, 402,  0,		403,  5},
+	{RSP_ZSAU,	403, 403, ZSAU_DISCONNECT_REQ, -1, -1, {ACT_DEBUG} },
+	{RSP_ZSAU,	403, 403, ZSAU_NULL,	  0,  0, {ACT_DISCONNECT} },
+	{RSP_NODEV,	401, 403, -1,		  0,  0, {ACT_FAKEHUP} },
+	{RSP_ERROR,	401, 401, -1,		  0,  0, {ACT_ABORTHUP} },
+	{EV_TIMEOUT,	401, 403, -1,		  0,  0, {ACT_ABORTHUP} },
+
+	{EV_BC_CLOSED,	  0,   0, -1,		  0, -1, {ACT_NOTIFY_BC_DOWN} },
 
 /* ring */
-	{RSP_ZBC,	700, 700, -1,			 -1, -1, {0} },
-	{RSP_ZHLC,	700, 700, -1,			 -1, -1, {0} },
-	{RSP_NMBR,	700, 700, -1,			 -1, -1, {0} },
-	{RSP_ZCPN,	700, 700, -1,			 -1, -1, {0} },
-	{RSP_ZCTP,	700, 700, -1,			 -1, -1, {0} },
-	{EV_TIMEOUT,	700, 700, -1,			720, 720, {ACT_ICALL} },
-	{EV_BC_CLOSED,	720, 720, -1,			  0, -1, {ACT_NOTIFY_BC_DOWN} },
+	{RSP_ZBC,	700, 700, -1,		 -1, -1, {0} },
+	{RSP_ZHLC,	700, 700, -1,		 -1, -1, {0} },
+	{RSP_NMBR,	700, 700, -1,		 -1, -1, {0} },
+	{RSP_ZCPN,	700, 700, -1,		 -1, -1, {0} },
+	{RSP_ZCTP,	700, 700, -1,		 -1, -1, {0} },
+	{EV_TIMEOUT,	700, 700, -1,		720, 720, {ACT_ICALL} },
+	{EV_BC_CLOSED,	720, 720, -1,		  0, -1, {ACT_NOTIFY_BC_DOWN} },
 
 /*accept icall*/
-	{EV_ACCEPT,	 -1,  -1, -1,			 -1, -1, {ACT_ACCEPT} },
-	{RSP_INIT,	720, 720, SEQ_ACCEPT,		721,  5, {ACT_CMD + AT_PROTO} },
-	{RSP_OK,	721, 721, -1,			722,  5, {ACT_CMD + AT_ISO} },
-	{RSP_OK,	722, 722, -1,			723,  5, {0},	"+VLS=17\r"},
-	{RSP_OK,	723, 723, -1,			724,  5, {0} },
-	{RSP_ZVLS,	724, 724, 17,			750, 50, {ACT_ACCEPTED} },
-	{RSP_ERROR,	721, 729, -1,			  0,  0, {ACT_ABORTACCEPT} },
-	{EV_TIMEOUT,	721, 729, -1,			  0,  0, {ACT_ABORTACCEPT} },
-	{RSP_ZSAU,	700, 729, ZSAU_NULL,		  0,  0, {ACT_ABORTACCEPT} },
-	{RSP_ZSAU,	700, 729, ZSAU_ACTIVE,		  0,  0, {ACT_ABORTACCEPT} },
-	{RSP_ZSAU,	700, 729, ZSAU_DISCONNECT_IND,	  0,  0, {ACT_ABORTACCEPT} },
-
-	{EV_BC_OPEN,	750, 750, -1,			751, -1},
-	{EV_TIMEOUT,	750, 751, -1,			  0,  0, {ACT_CONNTIMEOUT} },
+	{EV_ACCEPT,	 -1,  -1, -1,		 -1, -1, {ACT_ACCEPT} },
+	{RSP_INIT,	720, 720, SEQ_ACCEPT,	721,  5, {ACT_CMD + AT_PROTO} },
+	{RSP_OK,	721, 721, -1,		722,  5, {ACT_CMD + AT_ISO} },
+	{RSP_OK,	722, 722, -1,		723,  5, {0},	"+VLS=17\r"},
+	{RSP_OK,	723, 723, -1,		724,  5, {0} },
+	{RSP_ZVLS,	724, 724, 17,		750, 50, {ACT_ACCEPTED} },
+	{RSP_ERROR,	721, 729, -1,		  0,  0, {ACT_ABORTACCEPT} },
+	{EV_TIMEOUT,	721, 729, -1,		  0,  0, {ACT_ABORTACCEPT} },
+	{RSP_ZSAU,	700, 729, ZSAU_NULL,	  0,  0, {ACT_ABORTACCEPT} },
+	{RSP_ZSAU,	700, 729, ZSAU_ACTIVE,	  0,  0, {ACT_ABORTACCEPT} },
+	{RSP_ZSAU,	700, 729, ZSAU_DISCONNECT_IND, 0, 0, {ACT_ABORTACCEPT} },
+
+	{EV_BC_OPEN,	750, 750, -1,		751, -1},
+	{EV_TIMEOUT,	750, 751, -1,		  0,  0, {ACT_CONNTIMEOUT} },
 
 /* B channel closed (general case) */
-	{EV_BC_CLOSED,	 -1,  -1, -1,			 -1, -1, {ACT_NOTIFY_BC_DOWN} },
+	{EV_BC_CLOSED,	 -1,  -1, -1,		 -1, -1, {ACT_NOTIFY_BC_DOWN} },
 
 /* misc. */
-	{RSP_ZCON,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-	{RSP_ZCAU,	 -1,  -1, -1,			 -1, -1, {ACT_ZCAU} },
-	{RSP_NONE,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-	{RSP_ANY,	 -1,  -1, -1,			 -1, -1, {ACT_WARN} },
+	{RSP_ZCON,	 -1,  -1, -1,		 -1, -1, {ACT_DEBUG} },
+	{RSP_ZCAU,	 -1,  -1, -1,		 -1, -1, {ACT_ZCAU} },
+	{RSP_NONE,	 -1,  -1, -1,		 -1, -1, {ACT_DEBUG} },
+	{RSP_ANY,	 -1,  -1, -1,		 -1, -1, {ACT_WARN} },
 	{RSP_LAST}
 };
 
@@ -649,9 +649,9 @@ static void disconnect(struct at_state_t **at_state_p)
 static inline struct at_state_t *get_free_channel(struct cardstate *cs,
 						  int cid)
 /* cids: >0: siemens-cid
-   0: without cid
-   -1: no cid assigned yet
-*/
+ *        0: without cid
+ *       -1: no cid assigned yet
+ */
 {
 	unsigned long flags;
 	int i;
@@ -1374,7 +1374,8 @@ static void do_action(int action, struct cardstate *cs,
 			 ev->parameter, at_state->ConState);
 		break;
 
-		/* events from the LL */
+	/* events from the LL */
+
 	case ACT_DIAL:
 		start_dial(at_state, ev->ptr, ev->parameter);
 		break;
@@ -1387,7 +1388,8 @@ static void do_action(int action, struct cardstate *cs,
 		cs->commands_pending = 1;
 		break;
 
-		/* hotplug events */
+	/* hotplug events */
+
 	case ACT_STOP:
 		do_stop(cs);
 		break;
@@ -1395,7 +1397,8 @@ static void do_action(int action, struct cardstate *cs,
 		do_start(cs);
 		break;
 
-		/* events from the interface */
+	/* events from the interface */
+
 	case ACT_IF_LOCK:
 		cs->cmd_result = ev->parameter ? do_lock(cs) : do_unlock(cs);
 		cs->waiting = 0;
@@ -1414,7 +1417,8 @@ static void do_action(int action, struct cardstate *cs,
 		wake_up(&cs->waitqueue);
 		break;
 
-		/* events from the proc file system */
+	/* events from the proc file system */
+
 	case ACT_PROC_CIDMODE:
 		spin_lock_irqsave(&cs->lock, flags);
 		if (ev->parameter != cs->cidmode) {
@@ -1433,7 +1437,8 @@ static void do_action(int action, struct cardstate *cs,
 		wake_up(&cs->waitqueue);
 		break;
 
-		/* events from the hardware drivers */
+	/* events from the hardware drivers */
+
 	case ACT_NOTIFY_BC_DOWN:
 		bchannel_down(bcs);
 		break;
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 1dc2513..eae7351 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -163,8 +163,8 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 #define BAS_LOWFRAME	5	/* "    "    with negative flow control */
 #define BAS_CORRFRAMES	4	/* flow control multiplicator */
 
-#define BAS_INBUFSIZE	(BAS_MAXFRAME * BAS_NUMFRAMES)
-/* size of isoc in buf per URB */
+#define BAS_INBUFSIZE	(BAS_MAXFRAME * BAS_NUMFRAMES)	/* size of isoc in buf
+							 * per URB */
 #define BAS_OUTBUFSIZE	4096		/* size of common isoc out buffer */
 #define BAS_OUTBUFPAD	BAS_MAXFRAME	/* size of pad area for isoc out buf */
 
@@ -471,18 +471,18 @@ struct cardstate {
 					   for */
 	int commands_pending;		/* flag(s) in xxx.commands_pending have
 					   been set */
-	struct tasklet_struct event_tasklet;
-	/* tasklet for serializing AT commands.
-	 * Scheduled
-	 *   -> for modem reponses (and
-	 *      incoming data for M10x)
-	 *   -> on timeout
-	 *   -> after setting bits in
-	 *      xxx.at_state.pending_command
-	 *      (e.g. command from LL) */
-	struct tasklet_struct write_tasklet;
-	/* tasklet for serial output
-	 * (not used in base driver) */
+	struct tasklet_struct
+		event_tasklet;		/* tasklet for serializing AT commands.
+					 * Scheduled
+					 *   -> for modem reponses (and
+					 *      incoming data for M10x)
+					 *   -> on timeout
+					 *   -> after setting bits in
+					 *      xxx.at_state.pending_command
+					 *      (e.g. command from LL) */
+	struct tasklet_struct
+		write_tasklet;		/* tasklet for serial output
+					 * (not used in base driver) */
 
 	/* event queue */
 	struct event_t events[MAX_EVENTS];
-- 
1.7.3.4
