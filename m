From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 8/9] gigaset: checkpatch cleanup of ev-layer.c
Date: Sun, 25 Oct 2009 20:30:47 +0100 (CET)
Message-ID: <20091023-patch-gigaset-08.tilman@imap.cc>
References: <20091023-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754151AbZJYTbD@vger.kernel.org>
In-Reply-To: <20091023-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On more step towards the holy grail of checkpatch.pl silence.

Impact: cosmetic
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c |  478 +++++++++++++++++++--------------------
 1 files changed, 231 insertions(+), 247 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index 369927f..a9a3975 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -40,8 +40,8 @@
 
 /* Possible ASCII responses */
 #define RSP_OK		0
-//#define RSP_BUSY	1
-//#define RSP_CONNECT	2
+#define RSP_BUSY	1
+#define RSP_CONNECT	2
 #define RSP_ZGCI	3
 #define RSP_RING	4
 #define RSP_ZAOC	5
@@ -68,7 +68,6 @@
 #define RSP_ZHLC	(RSP_STR + STR_ZHLC)
 #define RSP_ERROR	-1	/* ERROR              */
 #define RSP_WRONG_CID	-2	/* unknown cid in cmd */
-//#define RSP_EMPTY	-3
 #define RSP_UNKNOWN	-4	/* unknown response   */
 #define RSP_FAIL	-5	/* internal error     */
 #define RSP_INVAL	-6	/* invalid response   */
@@ -76,9 +75,9 @@
 #define RSP_NONE	-19
 #define RSP_STRING	-20
 #define RSP_NULL	-21
-//#define RSP_RETRYFAIL	-22
-//#define RSP_RETRY	-23
-//#define RSP_SKIP	-24
+#define RSP_RETRYFAIL	-22
+#define RSP_RETRY	-23
+#define RSP_SKIP	-24
 #define RSP_INIT	-27
 #define RSP_ANY		-26
 #define RSP_LAST	-28
@@ -158,229 +157,225 @@
 #define SEQ_UMMODE	11
 
 
-// 100: init, 200: dle0, 250:dle1, 300: get cid (dial), 350: "hup" (no cid), 400: hup, 500: reset, 600: dial, 700: ring
+/* 100: init, 200: dle0, 250:dle1, 300: get cid (dial), 350: "hup" (no cid),
+ * 400: hup, 500: reset, 600: dial, 700: ring */
 struct reply_t gigaset_tab_nocid[] =
 {
-	/* resp_code, min_ConState, max_ConState, parameter, new_ConState, timeout, action, command */
-
-	/* initialize device, set cid mode if possible */
-	//{RSP_INIT,     -1, -1,100,                900, 0, {ACT_TEST}},
-	//{RSP_ERROR,   900,900, -1,                  0, 0, {ACT_FAILINIT}},
-	//{RSP_OK,      900,900, -1,                100, INIT_TIMEOUT,
-	//                                                  {ACT_TIMEOUT}},
-
-	{RSP_INIT,     -1, -1,SEQ_INIT,           100, INIT_TIMEOUT,
-							  {ACT_TIMEOUT}},                /* wait until device is ready */
-
-	{EV_TIMEOUT,  100,100, -1,                101, 3, {0},             "Z\r"},       /* device in transparent mode? try to initialize it. */
-	{RSP_OK,      101,103, -1,                120, 5, {ACT_GETSTRING}, "+GMR\r"},    /* get version */
-
-	{EV_TIMEOUT,  101,101, -1,                102, 5, {0},             "Z\r"},       /* timeout => try once again. */
-	{RSP_ERROR,   101,101, -1,                102, 5, {0},             "Z\r"},       /* error => try once again. */
-
-	{EV_TIMEOUT,  102,102, -1,                108, 5, {ACT_SETDLE1},   "^SDLE=0\r"}, /* timeout => try again in DLE mode. */
-	{RSP_OK,      108,108, -1,                104,-1},
-	{RSP_ZDLE,    104,104,  0,                103, 5, {0},             "Z\r"},
-	{EV_TIMEOUT,  104,104, -1,                  0, 0, {ACT_FAILINIT}},
-	{RSP_ERROR,   108,108, -1,                  0, 0, {ACT_FAILINIT}},
-
-	{EV_TIMEOUT,  108,108, -1,                105, 2, {ACT_SETDLE0,
-							   ACT_HUPMODEM,
-							   ACT_TIMEOUT}},                /* still timeout => connection in unimodem mode? */
-	{EV_TIMEOUT,  105,105, -1,                103, 5, {0},             "Z\r"},
-
-	{RSP_ERROR,   102,102, -1,                107, 5, {0},             "^GETPRE\r"}, /* ERROR on ATZ => maybe in config mode? */
-	{RSP_OK,      107,107, -1,                  0, 0, {ACT_CONFIGMODE}},
-	{RSP_ERROR,   107,107, -1,                  0, 0, {ACT_FAILINIT}},
-	{EV_TIMEOUT,  107,107, -1,                  0, 0, {ACT_FAILINIT}},
-
-	{RSP_ERROR,   103,103, -1,                  0, 0, {ACT_FAILINIT}},
-	{EV_TIMEOUT,  103,103, -1,                  0, 0, {ACT_FAILINIT}},
-
-	{RSP_STRING,  120,120, -1,                121,-1, {ACT_SETVER}},
-
-	{EV_TIMEOUT,  120,121, -1,                  0, 0, {ACT_FAILVER, ACT_INIT}},
-	{RSP_ERROR,   120,121, -1,                  0, 0, {ACT_FAILVER, ACT_INIT}},
-	{RSP_OK,      121,121, -1,                  0, 0, {ACT_GOTVER,  ACT_INIT}},
-
-	/* leave dle mode */
-	{RSP_INIT,      0,  0,SEQ_DLE0,           201, 5, {0},             "^SDLE=0\r"},
-	{RSP_OK,      201,201, -1,                202,-1},
-	{RSP_ZDLE,    202,202,  0,                  0, 0, {ACT_DLE0}},
-	{RSP_NODEV,   200,249, -1,                  0, 0, {ACT_FAKEDLE0}},
-	{RSP_ERROR,   200,249, -1,                  0, 0, {ACT_FAILDLE0}},
-	{EV_TIMEOUT,  200,249, -1,                  0, 0, {ACT_FAILDLE0}},
-
-	/* enter dle mode */
-	{RSP_INIT,      0,  0,SEQ_DLE1,           251, 5, {0},             "^SDLE=1\r"},
-	{RSP_OK,      251,251, -1,                252,-1},
-	{RSP_ZDLE,    252,252,  1,                  0, 0, {ACT_DLE1}},
-	{RSP_ERROR,   250,299, -1,                  0, 0, {ACT_FAILDLE1}},
-	{EV_TIMEOUT,  250,299, -1,                  0, 0, {ACT_FAILDLE1}},
-
-	/* incoming call */
-	{RSP_RING,     -1, -1, -1,                 -1,-1, {ACT_RING}},
-
-	/* get cid */
-	//{RSP_INIT,      0,  0,300,                901, 0, {ACT_TEST}},
-	//{RSP_ERROR,   901,901, -1,                  0, 0, {ACT_FAILCID}},
-	//{RSP_OK,      901,901, -1,                301, 5, {0},             "^SGCI?\r"},
-
-	{RSP_INIT,      0,  0,SEQ_CID,            301, 5, {0},             "^SGCI?\r"},
-	{RSP_OK,      301,301, -1,                302,-1},
-	{RSP_ZGCI,    302,302, -1,                  0, 0, {ACT_CID}},
-	{RSP_ERROR,   301,349, -1,                  0, 0, {ACT_FAILCID}},
-	{EV_TIMEOUT,  301,349, -1,                  0, 0, {ACT_FAILCID}},
-
-	/* enter cid mode */
-	{RSP_INIT,      0,  0,SEQ_CIDMODE,        150, 5, {0},             "^SGCI=1\r"},
-	{RSP_OK,      150,150, -1,                  0, 0, {ACT_CMODESET}},
-	{RSP_ERROR,   150,150, -1,                  0, 0, {ACT_FAILCMODE}},
-	{EV_TIMEOUT,  150,150, -1,                  0, 0, {ACT_FAILCMODE}},
-
-	/* leave cid mode */
-	//{RSP_INIT,      0,  0,SEQ_UMMODE,         160, 5, {0},             "^SGCI=0\r"},
-	{RSP_INIT,      0,  0,SEQ_UMMODE,         160, 5, {0},             "Z\r"},
-	{RSP_OK,      160,160, -1,                  0, 0, {ACT_UMODESET}},
-	{RSP_ERROR,   160,160, -1,                  0, 0, {ACT_FAILUMODE}},
-	{EV_TIMEOUT,  160,160, -1,                  0, 0, {ACT_FAILUMODE}},
-
-	/* abort getting cid */
-	{RSP_INIT,      0,  0,SEQ_NOCID,            0, 0, {ACT_ABORTCID}},
-
-	/* reset */
-	{RSP_INIT,      0,  0,SEQ_SHUTDOWN,       504, 5, {0},             "Z\r"},
-	{RSP_OK,      504,504, -1,                  0, 0, {ACT_SDOWN}},
-	{RSP_ERROR,   501,599, -1,                  0, 0, {ACT_FAILSDOWN}},
-	{EV_TIMEOUT,  501,599, -1,                  0, 0, {ACT_FAILSDOWN}},
-	{RSP_NODEV,   501,599, -1,                  0, 0, {ACT_FAKESDOWN}},
-
-	{EV_PROC_CIDMODE,-1, -1, -1,               -1,-1, {ACT_PROC_CIDMODE}}, //FIXME
-	{EV_IF_LOCK,   -1, -1, -1,                 -1,-1, {ACT_IF_LOCK}}, //FIXME
-	{EV_IF_VER,    -1, -1, -1,                 -1,-1, {ACT_IF_VER}}, //FIXME
-	{EV_START,     -1, -1, -1,                 -1,-1, {ACT_START}}, //FIXME
-	{EV_STOP,      -1, -1, -1,                 -1,-1, {ACT_STOP}}, //FIXME
-	{EV_SHUTDOWN,  -1, -1, -1,                 -1,-1, {ACT_SHUTDOWN}}, //FIXME
-
-	/* misc. */
-	{RSP_ERROR,    -1, -1, -1,                 -1, -1, {ACT_ERROR} },
-	{RSP_EMPTY,    -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
-	{RSP_ZCFGT,    -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
-	{RSP_ZCFG,     -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
-	{RSP_ZLOG,     -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
-	{RSP_ZMWI,     -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
-	{RSP_ZABINFO,  -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
-	{RSP_ZSMLSTCHG,-1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
-
-	{RSP_ZCAU,     -1, -1, -1,                 -1,-1, {ACT_ZCAU}},
-	{RSP_NONE,     -1, -1, -1,                 -1,-1, {ACT_DEBUG}},
-	{RSP_ANY,      -1, -1, -1,                 -1,-1, {ACT_WARN}},
-	{RSP_LAST}
+/* resp_code, min_ConState, max_ConState, parameter, new_ConState, timeout,
+ * action, command */
+
+/* initialize device, set cid mode if possible */
+{RSP_INIT,	 -1,  -1, SEQ_INIT,		100,  1, {ACT_TIMEOUT} },
+
+{EV_TIMEOUT,	100, 100, -1,			101,  3, {0},	"Z\r"},
+{RSP_OK,	101, 103, -1,			120,  5, {ACT_GETSTRING},
+								"+GMR\r"},
+
+{EV_TIMEOUT,	101, 101, -1,			102,  5, {0},	"Z\r"},
+{RSP_ERROR,	101, 101, -1,			102,  5, {0},	"Z\r"},
+
+{EV_TIMEOUT,	102, 102, -1,			108,  5, {ACT_SETDLE1},
+								"^SDLE=0\r"},
+{RSP_OK,	108, 108, -1,			104, -1},
+{RSP_ZDLE,	104, 104,  0,			103,  5, {0},	"Z\r"},
+{EV_TIMEOUT,	104, 104, -1,			  0,  0, {ACT_FAILINIT} },
+{RSP_ERROR,	108, 108, -1,			  0,  0, {ACT_FAILINIT} },
+
+{EV_TIMEOUT,	108, 108, -1,			105,  2, {ACT_SETDLE0,
+							  ACT_HUPMODEM,
+							  ACT_TIMEOUT} },
+{EV_TIMEOUT,	105, 105, -1,			103,  5, {0},	"Z\r"},
+
+{RSP_ERROR,	102, 102, -1,			107,  5, {0},	"^GETPRE\r"},
+{RSP_OK,	107, 107, -1,			  0,  0, {ACT_CONFIGMODE} },
+{RSP_ERROR,	107, 107, -1,			  0,  0, {ACT_FAILINIT} },
+{EV_TIMEOUT,	107, 107, -1,			  0,  0, {ACT_FAILINIT} },
+
+{RSP_ERROR,	103, 103, -1,			  0,  0, {ACT_FAILINIT} },
+{EV_TIMEOUT,	103, 103, -1,			  0,  0, {ACT_FAILINIT} },
+
+{RSP_STRING,	120, 120, -1,			121, -1, {ACT_SETVER} },
+
+{EV_TIMEOUT,	120, 121, -1,			  0,  0, {ACT_FAILVER,
+							  ACT_INIT} },
+{RSP_ERROR,	120, 121, -1,			  0,  0, {ACT_FAILVER,
+							  ACT_INIT} },
+{RSP_OK,	121, 121, -1,			  0,  0, {ACT_GOTVER,
+							  ACT_INIT} },
+
+/* leave dle mode */
+{RSP_INIT,	  0,   0, SEQ_DLE0,		201,  5, {0},	"^SDLE=0\r"},
+{RSP_OK,	201, 201, -1,			202, -1},
+{RSP_ZDLE,	202, 202,  0,			  0,  0, {ACT_DLE0} },
+{RSP_NODEV,	200, 249, -1,			  0,  0, {ACT_FAKEDLE0} },
+{RSP_ERROR,	200, 249, -1,			  0,  0, {ACT_FAILDLE0} },
+{EV_TIMEOUT,	200, 249, -1,			  0,  0, {ACT_FAILDLE0} },
+
+/* enter dle mode */
+{RSP_INIT,	  0,   0, SEQ_DLE1,		251,  5, {0},	"^SDLE=1\r"},
+{RSP_OK,	251, 251, -1,			252, -1},
+{RSP_ZDLE,	252, 252,  1,			  0,  0, {ACT_DLE1} },
+{RSP_ERROR,	250, 299, -1,			  0,  0, {ACT_FAILDLE1} },
+{EV_TIMEOUT,	250, 299, -1,			  0,  0, {ACT_FAILDLE1} },
+
+/* incoming call */
+{RSP_RING,	 -1,  -1, -1,			 -1, -1, {ACT_RING} },
+
+/* get cid */
+{RSP_INIT,	  0,   0, SEQ_CID,		301,  5, {0},	"^SGCI?\r"},
+{RSP_OK,	301, 301, -1,			302, -1},
+{RSP_ZGCI,	302, 302, -1,			  0,  0, {ACT_CID} },
+{RSP_ERROR,	301, 349, -1,			  0,  0, {ACT_FAILCID} },
+{EV_TIMEOUT,	301, 349, -1,			  0,  0, {ACT_FAILCID} },
+
+/* enter cid mode */
+{RSP_INIT,	  0,   0, SEQ_CIDMODE,		150,  5, {0},	"^SGCI=1\r"},
+{RSP_OK,	150, 150, -1,			  0,  0, {ACT_CMODESET} },
+{RSP_ERROR,	150, 150, -1,			  0,  0, {ACT_FAILCMODE} },
+{EV_TIMEOUT,	150, 150, -1,			  0,  0, {ACT_FAILCMODE} },
+
+/* leave cid mode */
+{RSP_INIT,	  0,   0, SEQ_UMMODE,		160,  5, {0},	"Z\r"},
+{RSP_OK,	160, 160, -1,			  0,  0, {ACT_UMODESET} },
+{RSP_ERROR,	160, 160, -1,			  0,  0, {ACT_FAILUMODE} },
+{EV_TIMEOUT,	160, 160, -1,			  0,  0, {ACT_FAILUMODE} },
+
+/* abort getting cid */
+{RSP_INIT,	  0,   0, SEQ_NOCID,		  0,  0, {ACT_ABORTCID} },
+
+/* reset */
+{RSP_INIT,	  0,   0, SEQ_SHUTDOWN,		504,  5, {0},	"Z\r"},
+{RSP_OK,	504, 504, -1,			  0,  0, {ACT_SDOWN} },
+{RSP_ERROR,	501, 599, -1,			  0,  0, {ACT_FAILSDOWN} },
+{EV_TIMEOUT,	501, 599, -1,			  0,  0, {ACT_FAILSDOWN} },
+{RSP_NODEV,	501, 599, -1,			  0,  0, {ACT_FAKESDOWN} },
+
+{EV_PROC_CIDMODE, -1, -1, -1,			 -1, -1, {ACT_PROC_CIDMODE} },
+{EV_IF_LOCK,	 -1,  -1, -1,			 -1, -1, {ACT_IF_LOCK} },
+{EV_IF_VER,	 -1,  -1, -1,			 -1, -1, {ACT_IF_VER} },
+{EV_START,	 -1,  -1, -1,			 -1, -1, {ACT_START} },
+{EV_STOP,	 -1,  -1, -1,			 -1, -1, {ACT_STOP} },
+{EV_SHUTDOWN,	 -1,  -1, -1,			 -1, -1, {ACT_SHUTDOWN} },
+
+/* misc. */
+{RSP_ERROR,	 -1,  -1, -1,			 -1, -1, {ACT_ERROR} },
+{RSP_ZCFGT,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
+{RSP_ZCFG,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
+{RSP_ZLOG,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
+{RSP_ZMWI,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
+{RSP_ZABINFO,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
+{RSP_ZSMLSTCHG,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
+
+{RSP_ZCAU,	 -1,  -1, -1,			 -1, -1, {ACT_ZCAU} },
+{RSP_NONE,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
+{RSP_ANY,	 -1,  -1, -1,			 -1, -1, {ACT_WARN} },
+{RSP_LAST}
 };
 
-// 600: start dialing, 650: dial in progress, 800: connection is up, 700: ring, 400: hup, 750: accepted icall
+/* 600: start dialing, 650: dial in progress, 800: connection is up, 700: ring,
+ * 400: hup, 750: accepted icall */
 struct reply_t gigaset_tab_cid[] =
 {
-	/* resp_code, min_ConState, max_ConState, parameter, new_ConState, timeout, action, command */
-
-	/* dial */
-	{EV_DIAL,      -1, -1, -1,                 -1,-1, {ACT_DIAL}}, //FIXME
-	{RSP_INIT,      0,  0,SEQ_DIAL,           601, 5, {ACT_CMD+AT_BC}},
-	{RSP_OK,      601,601, -1,                602, 5, {ACT_CMD+AT_HLC}},
-	{RSP_NULL,    602,602, -1,                603, 5, {ACT_CMD+AT_PROTO}},
-	{RSP_OK,      602,602, -1,                603, 5, {ACT_CMD+AT_PROTO}},
-	{RSP_OK,      603,603, -1,                604, 5, {ACT_CMD+AT_TYPE}},
-	{RSP_OK,      604,604, -1,                605, 5, {ACT_CMD+AT_MSN}},
-	{RSP_NULL,    605, 605, -1,               606, 5, {ACT_CMD+AT_CLIP} },
-	{RSP_OK,      605, 605, -1,               606, 5, {ACT_CMD+AT_CLIP} },
-	{RSP_NULL,    606, 606, -1,               607, 5, {ACT_CMD+AT_ISO} },
-	{RSP_OK,      606, 606, -1,               607, 5, {ACT_CMD+AT_ISO} },
-	{RSP_OK,      607, 607, -1,               608, 5, {0}, "+VLS=17\r"},
-	{RSP_OK,      608, 608, -1,               609, -1},
-	{RSP_ZSAU,    609, 609, ZSAU_PROCEEDING,  610, 5, {ACT_CMD+AT_DIAL} },
-	{RSP_OK,      610, 610, -1,               650, 0, {ACT_DIALING} },
-
-	{RSP_ERROR,   601, 610, -1,                 0, 0, {ACT_ABORTDIAL} },
-	{EV_TIMEOUT,  601, 610, -1,                 0, 0, {ACT_ABORTDIAL} },
-
-	/* optional dialing responses */
-	{EV_BC_OPEN,  650,650, -1,                651,-1},
-	{RSP_ZVLS,    609, 651, 17,                -1, -1, {ACT_DEBUG} },
-	{RSP_ZCTP,    610, 651, -1,                -1, -1, {ACT_DEBUG} },
-	{RSP_ZCPN,    610, 651, -1,                -1, -1, {ACT_DEBUG} },
-	{RSP_ZSAU,    650,651,ZSAU_CALL_DELIVERED, -1,-1, {ACT_DEBUG}},
-
-	/* connect */
-	{RSP_ZSAU,    650,650,ZSAU_ACTIVE,        800,-1, {ACT_CONNECT}},
-	{RSP_ZSAU,    651,651,ZSAU_ACTIVE,        800,-1, {ACT_CONNECT,
-							   ACT_NOTIFY_BC_UP}},
-	{RSP_ZSAU,    750,750,ZSAU_ACTIVE,        800,-1, {ACT_CONNECT}},
-	{RSP_ZSAU,    751,751,ZSAU_ACTIVE,        800,-1, {ACT_CONNECT,
-							   ACT_NOTIFY_BC_UP}},
-	{EV_BC_OPEN,  800,800, -1,                800,-1, {ACT_NOTIFY_BC_UP}},
-
-	/* remote hangup */
-	{RSP_ZSAU,    650,651,ZSAU_DISCONNECT_IND,  0, 0, {ACT_REMOTEREJECT}},
-	{RSP_ZSAU,    750,751,ZSAU_DISCONNECT_IND,  0, 0, {ACT_REMOTEHUP}},
-	{RSP_ZSAU,    800,800,ZSAU_DISCONNECT_IND,  0, 0, {ACT_REMOTEHUP}},
-
-	/* hangup */
-	{EV_HUP,       -1, -1, -1,                 -1,-1, {ACT_HUP}}, //FIXME
-	{RSP_INIT,     -1, -1,SEQ_HUP,            401, 5, {0},             "+VLS=0\r"}, /* hang up */ //-1,-1?
-	{RSP_OK,      401,401, -1,                402, 5},
-	{RSP_ZVLS,    402,402,  0,                403, 5},
-	{RSP_ZSAU,    403, 403, ZSAU_DISCONNECT_REQ, -1, -1, {ACT_DEBUG} },
-	{RSP_ZSAU,    403, 403, ZSAU_NULL,            0,  0, {ACT_DISCONNECT} },
-	{RSP_NODEV,   401, 403, -1,                   0,  0, {ACT_FAKEHUP} },
-	{RSP_ERROR,   401,401, -1,                  0, 0, {ACT_ABORTHUP}},
-	{EV_TIMEOUT,  401,403, -1,                  0, 0, {ACT_ABORTHUP}},
-
-	{EV_BC_CLOSED,  0,  0, -1,                  0,-1, {ACT_NOTIFY_BC_DOWN}}, //FIXME new constate + timeout
-
-	/* ring */
-	{RSP_ZBC,     700,700, -1,                 -1,-1, {0}},
-	{RSP_ZHLC,    700,700, -1,                 -1,-1, {0}},
-	{RSP_NMBR,    700,700, -1,                 -1,-1, {0}},
-	{RSP_ZCPN,    700,700, -1,                 -1,-1, {0}},
-	{RSP_ZCTP,    700,700, -1,                 -1,-1, {0}},
-	{EV_TIMEOUT,  700,700, -1,               720,720, {ACT_ICALL}},
-	{EV_BC_CLOSED,720,720, -1,                  0,-1, {ACT_NOTIFY_BC_DOWN}},
-
-	/*accept icall*/
-	{EV_ACCEPT,    -1, -1, -1,                 -1,-1, {ACT_ACCEPT}}, //FIXME
-	{RSP_INIT,    720,720,SEQ_ACCEPT,         721, 5, {ACT_CMD+AT_PROTO}},
-	{RSP_OK,      721,721, -1,                722, 5, {ACT_CMD+AT_ISO}},
-	{RSP_OK,      722,722, -1,                723, 5, {0},             "+VLS=17\r"}, /* set "Endgeraetemodus" */
-	{RSP_OK,      723,723, -1,                724, 5, {0}},
-	{RSP_ZVLS,    724,724, 17,                750,50, {ACT_ACCEPTED}},
-	{RSP_ERROR,   721,729, -1,                  0, 0, {ACT_ABORTACCEPT}},
-	{EV_TIMEOUT,  721,729, -1,                  0, 0, {ACT_ABORTACCEPT}},
-	{RSP_ZSAU,    700,729,ZSAU_NULL,            0, 0, {ACT_ABORTACCEPT}},
-	{RSP_ZSAU,    700,729,ZSAU_ACTIVE,          0, 0, {ACT_ABORTACCEPT}},
-	{RSP_ZSAU,    700,729,ZSAU_DISCONNECT_IND,  0, 0, {ACT_ABORTACCEPT}},
-
-	{EV_BC_OPEN,  750,750, -1,                751,-1},
-	{EV_TIMEOUT,  750,751, -1,                  0, 0, {ACT_CONNTIMEOUT}},
-
-	/* B channel closed (general case) */
-	{EV_BC_CLOSED, -1, -1, -1,                 -1,-1, {ACT_NOTIFY_BC_DOWN}}, //FIXME
-
-	/* misc. */
-	{RSP_ZCON,     -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
-	{RSP_ZCCR,     -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
-	{RSP_ZAOC,     -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
-	{RSP_ZCSTR,    -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
-
-	{RSP_ZCAU,     -1, -1, -1,                 -1,-1, {ACT_ZCAU}},
-	{RSP_NONE,     -1, -1, -1,                 -1,-1, {ACT_DEBUG}},
-	{RSP_ANY,      -1, -1, -1,                 -1,-1, {ACT_WARN}},
-	{RSP_LAST}
+/* resp_code, min_ConState, max_ConState, parameter, new_ConState, timeout,
+ * action, command */
+
+/* dial */
+{EV_DIAL,	 -1,  -1, -1,			 -1, -1, {ACT_DIAL} },
+{RSP_INIT,	  0,   0, SEQ_DIAL,		601,  5, {ACT_CMD+AT_BC} },
+{RSP_OK,	601, 601, -1,			602,  5, {ACT_CMD+AT_HLC} },
+{RSP_NULL,	602, 602, -1,			603,  5, {ACT_CMD+AT_PROTO} },
+{RSP_OK,	602, 602, -1,			603,  5, {ACT_CMD+AT_PROTO} },
+{RSP_OK,	603, 603, -1,			604,  5, {ACT_CMD+AT_TYPE} },
+{RSP_OK,	604, 604, -1,			605,  5, {ACT_CMD+AT_MSN} },
+{RSP_NULL,	605, 605, -1,			606,  5, {ACT_CMD+AT_CLIP} },
+{RSP_OK,	605, 605, -1,			606,  5, {ACT_CMD+AT_CLIP} },
+{RSP_NULL,	606, 606, -1,			607,  5, {ACT_CMD+AT_ISO} },
+{RSP_OK,	606, 606, -1,			607,  5, {ACT_CMD+AT_ISO} },
+{RSP_OK,	607, 607, -1,			608,  5, {0},	"+VLS=17\r"},
+{RSP_OK,	608, 608, -1,			609, -1},
+{RSP_ZSAU,	609, 609, ZSAU_PROCEEDING,	610,  5, {ACT_CMD+AT_DIAL} },
+{RSP_OK,	610, 610, -1,			650,  0, {ACT_DIALING} },
+
+{RSP_ERROR,	601, 610, -1,			  0,  0, {ACT_ABORTDIAL} },
+{EV_TIMEOUT,	601, 610, -1,			  0,  0, {ACT_ABORTDIAL} },
+
+/* optional dialing responses */
+{EV_BC_OPEN,	650, 650, -1,			651, -1},
+{RSP_ZVLS,	609, 651, 17,			 -1, -1, {ACT_DEBUG} },
+{RSP_ZCTP,	610, 651, -1,			 -1, -1, {ACT_DEBUG} },
+{RSP_ZCPN,	610, 651, -1,			 -1, -1, {ACT_DEBUG} },
+{RSP_ZSAU,	650, 651, ZSAU_CALL_DELIVERED,	 -1, -1, {ACT_DEBUG} },
+
+/* connect */
+{RSP_ZSAU,	650, 650, ZSAU_ACTIVE,		800, -1, {ACT_CONNECT} },
+{RSP_ZSAU,	651, 651, ZSAU_ACTIVE,		800, -1, {ACT_CONNECT,
+							  ACT_NOTIFY_BC_UP} },
+{RSP_ZSAU,	750, 750, ZSAU_ACTIVE,		800, -1, {ACT_CONNECT} },
+{RSP_ZSAU,	751, 751, ZSAU_ACTIVE,		800, -1, {ACT_CONNECT,
+							  ACT_NOTIFY_BC_UP} },
+{EV_BC_OPEN,	800, 800, -1,			800, -1, {ACT_NOTIFY_BC_UP} },
+
+/* remote hangup */
+{RSP_ZSAU,	650, 651, ZSAU_DISCONNECT_IND,	  0,  0, {ACT_REMOTEREJECT} },
+{RSP_ZSAU,	750, 751, ZSAU_DISCONNECT_IND,	  0,  0, {ACT_REMOTEHUP} },
+{RSP_ZSAU,	800, 800, ZSAU_DISCONNECT_IND,	  0,  0, {ACT_REMOTEHUP} },
+
+/* hangup */
+{EV_HUP,	 -1,  -1, -1,			 -1, -1, {ACT_HUP} },
+{RSP_INIT,	 -1,  -1, SEQ_HUP,		401,  5, {0},	"+VLS=0\r"},
+{RSP_OK,	401, 401, -1,			402,  5},
+{RSP_ZVLS,	402, 402,  0,			403,  5},
+{RSP_ZSAU,	403, 403, ZSAU_DISCONNECT_REQ,	 -1, -1, {ACT_DEBUG} },
+{RSP_ZSAU,	403, 403, ZSAU_NULL,		  0,  0, {ACT_DISCONNECT} },
+{RSP_NODEV,	401, 403, -1,			  0,  0, {ACT_FAKEHUP} },
+{RSP_ERROR,	401, 401, -1,			  0,  0, {ACT_ABORTHUP} },
+{EV_TIMEOUT,	401, 403, -1,			  0,  0, {ACT_ABORTHUP} },
+
+{EV_BC_CLOSED,	  0,   0, -1,			  0, -1, {ACT_NOTIFY_BC_DOWN} },
+
+/* ring */
+{RSP_ZBC,	700, 700, -1,			 -1, -1, {0} },
+{RSP_ZHLC,	700, 700, -1,			 -1, -1, {0} },
+{RSP_NMBR,	700, 700, -1,			 -1, -1, {0} },
+{RSP_ZCPN,	700, 700, -1,			 -1, -1, {0} },
+{RSP_ZCTP,	700, 700, -1,			 -1, -1, {0} },
+{EV_TIMEOUT,	700, 700, -1,			720, 720, {ACT_ICALL} },
+{EV_BC_CLOSED,	720, 720, -1,			  0, -1, {ACT_NOTIFY_BC_DOWN} },
+
+/*accept icall*/
+{EV_ACCEPT,	 -1,  -1, -1,			 -1, -1, {ACT_ACCEPT} },
+{RSP_INIT,	720, 720, SEQ_ACCEPT,		721,  5, {ACT_CMD+AT_PROTO} },
+{RSP_OK,	721, 721, -1,			722,  5, {ACT_CMD+AT_ISO} },
+{RSP_OK,	722, 722, -1,			723,  5, {0},	"+VLS=17\r"},
+{RSP_OK,	723, 723, -1,			724,  5, {0} },
+{RSP_ZVLS,	724, 724, 17,			750, 50, {ACT_ACCEPTED} },
+{RSP_ERROR,	721, 729, -1,			  0,  0, {ACT_ABORTACCEPT} },
+{EV_TIMEOUT,	721, 729, -1,			  0,  0, {ACT_ABORTACCEPT} },
+{RSP_ZSAU,	700, 729, ZSAU_NULL,		  0,  0, {ACT_ABORTACCEPT} },
+{RSP_ZSAU,	700, 729, ZSAU_ACTIVE,		  0,  0, {ACT_ABORTACCEPT} },
+{RSP_ZSAU,	700, 729, ZSAU_DISCONNECT_IND,	  0,  0, {ACT_ABORTACCEPT} },
+
+{EV_BC_OPEN,	750, 750, -1,			751, -1},
+{EV_TIMEOUT,	750, 751, -1,			  0,  0, {ACT_CONNTIMEOUT} },
+
+/* B channel closed (general case) */
+{EV_BC_CLOSED,	 -1,  -1, -1,			 -1, -1, {ACT_NOTIFY_BC_DOWN} },
+
+/* misc. */
+{RSP_ZCON,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
+{RSP_ZCCR,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
+{RSP_ZAOC,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
+{RSP_ZCSTR,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
+
+{RSP_ZCAU,	 -1,  -1, -1,			 -1, -1, {ACT_ZCAU} },
+{RSP_NONE,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
+{RSP_ANY,	 -1,  -1, -1,			 -1, -1, {ACT_WARN} },
+{RSP_LAST}
 };
 
 
 static const struct resp_type_t resp_type[] =
 {
-	/*{"",		RSP_EMPTY,	RT_NOTHING},*/
 	{"OK",		RSP_OK,		RT_NOTHING},
 	{"ERROR",	RSP_ERROR,	RT_NOTHING},
 	{"ZSAU",	RSP_ZSAU,	RT_ZSAU},
@@ -404,7 +399,7 @@ static const struct resp_type_t resp_type[] =
 	{"ZLOG",	RSP_ZLOG,	RT_NOTHING},
 	{"ZABINFO",	RSP_ZABINFO,	RT_NOTHING},
 	{"ZSMLSTCHG",	RSP_ZSMLSTCHG,	RT_NOTHING},
-	{NULL,0,0}
+	{NULL,		0,		0}
 };
 
 /*
@@ -469,7 +464,6 @@ static int cid_of_response(char *s)
 	if (cid < 1 || cid > 65535)
 		return -1;	/* CID out of range */
 	return cid;
-	//FIXME is ;<digit>+ at end of non-CID response really impossible?
 }
 
 /**
@@ -613,7 +607,8 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 				break;
 			}
 			if (!strcmp(argv[curarg], "OUTGOING_CALL_PROCEEDING"))
-				event->parameter = ZSAU_OUTGOING_CALL_PROCEEDING;
+				event->parameter =
+					ZSAU_OUTGOING_CALL_PROCEEDING;
 			else if (!strcmp(argv[curarg], "CALL_DELIVERED"))
 				event->parameter = ZSAU_CALL_DELIVERED;
 			else if (!strcmp(argv[curarg], "ACTIVE"))
@@ -896,7 +891,8 @@ static void bchannel_up(struct bc_state *bcs)
 	gigaset_isdn_connB(bcs);
 }
 
-static void start_dial(struct at_state_t *at_state, void *data, unsigned seq_index)
+static void start_dial(struct at_state_t *at_state, void *data,
+			unsigned seq_index)
 {
 	struct bc_state *bcs = at_state->bcs;
 	struct cardstate *cs = at_state->cs;
@@ -973,8 +969,6 @@ static void do_start(struct cardstate *cs)
 
 	cs->isdn_up = 1;
 	gigaset_isdn_start(cs);
-					// FIXME: not in locked mode
-					// FIXME 2: only after init sequence
 
 	cs->waiting = 0;
 	wake_up(&cs->waitqueue);
@@ -1128,7 +1122,6 @@ static int do_lock(struct cardstate *cs)
 
 		break;
 	case MS_LOCKED:
-		//retval = -EACCES;
 		break;
 	default:
 		return -EBUSY;
@@ -1384,7 +1377,7 @@ static void do_action(int action, struct cardstate *cs,
 		cs->cur_at_seq = SEQ_NONE;
 		break;
 
-	case ACT_ABORTACCEPT:	/* hangup/error/timeout during ICALL processing */
+	case ACT_ABORTACCEPT:	/* hangup/error/timeout during ICALL procssng */
 		disconnect(p_at_state);
 		break;
 
@@ -1458,17 +1451,6 @@ static void do_action(int action, struct cardstate *cs,
 			__func__, at_state->ConState);
 		cs->cur_at_seq = SEQ_NONE;
 		break;
-#ifdef CONFIG_GIGASET_DEBUG
-	case ACT_TEST:
-		{
-			static int count = 3; //2; //1;
-			*p_genresp = 1;
-			*p_resp_code = count ? RSP_ERROR : RSP_OK;
-			if (count > 0)
-				--count;
-		}
-		break;
-#endif
 	case ACT_DEBUG:
 		gig_dbg(DEBUG_ANY, "%s: resp_code %d in ConState %d",
 			__func__, ev->type, at_state->ConState);
@@ -1503,7 +1485,7 @@ static void do_action(int action, struct cardstate *cs,
 		do_start(cs);
 		break;
 
-	/* events from the interface */ // FIXME without ACT_xxxx?
+	/* events from the interface */
 	case ACT_IF_LOCK:
 		cs->cmd_result = ev->parameter ? do_lock(cs) : do_unlock(cs);
 		cs->waiting = 0;
@@ -1522,7 +1504,7 @@ static void do_action(int action, struct cardstate *cs,
 		wake_up(&cs->waitqueue);
 		break;
 
-	/* events from the proc file system */ // FIXME without ACT_xxxx?
+	/* events from the proc file system */
 	case ACT_PROC_CIDMODE:
 		spin_lock_irqsave(&cs->lock, flags);
 		if (ev->parameter != cs->cidmode) {
@@ -1659,7 +1641,8 @@ static void process_event(struct cardstate *cs, struct event_t *ev)
 	for (curact = 0; curact < MAXACT; ++curact) {
 		/* The row tells us what we should do  ..
 		 */
-		do_action(rep->action[curact], cs, bcs, &at_state, &p_command, &genresp, &resp_code, ev);
+		do_action(rep->action[curact], cs, bcs, &at_state, &p_command,
+			  &genresp, &resp_code, ev);
 		if (!at_state)
 			break; /* may be freed after disconnect */
 	}
@@ -1671,13 +1654,14 @@ static void process_event(struct cardstate *cs, struct event_t *ev)
 
 		if (genresp) {
 			spin_lock_irqsave(&cs->lock, flags);
-			at_state->timer_expires = 0; //FIXME
-			at_state->timer_active = 0; //FIXME
+			at_state->timer_expires = 0;
+			at_state->timer_active = 0;
 			spin_unlock_irqrestore(&cs->lock, flags);
-			gigaset_add_event(cs, at_state, resp_code, NULL, 0, NULL);
+			gigaset_add_event(cs, at_state, resp_code,
+					  NULL, 0, NULL);
 		} else {
 			/* Send command to modem if not NULL... */
-			if (p_command/*rep->command*/) {
+			if (p_command) {
 				if (cs->connected)
 					send_command(cs, p_command,
 						     sendcid, cs->dle,
@@ -1764,7 +1748,8 @@ static void process_command_flags(struct cardstate *cs)
 		}
 	}
 
-	/* only switch back to unimodem mode, if no commands are pending and no channels are up */
+	/* only switch back to unimodem mode if no commands are pending and
+	 * no channels are up */
 	spin_lock_irqsave(&cs->lock, flags);
 	if (cs->at_state.pending_commands == PC_UMMODE
 	    && !cs->cidmode
@@ -1823,9 +1808,8 @@ static void process_command_flags(struct cardstate *cs)
 
 	if (cs->at_state.pending_commands & PC_INIT) {
 		cs->at_state.pending_commands &= ~PC_INIT;
-		cs->dle = 0; //FIXME
+		cs->dle = 0;
 		cs->inbuf->inputstate = INS_command;
-		//FIXME reset card state (or -> LOCK0)?
 		schedule_sequence(cs, &cs->at_state, SEQ_INIT);
 		return;
 	}
-- 
1.6.2.1.214.ge986c
