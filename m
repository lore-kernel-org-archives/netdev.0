From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 02/13] ISDN: Clean up isdnhdlc code
Date: Wed, 8 Jul 2009 19:11:09 +0200
Message-ID: <6bd4bcd3cd8affc09eaee7efbc037f65f4a71501.1248546896.git.keil@b1-systems.de>
References: <cover.1248546896.git.keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752855AbZGYVCq@vger.kernel.org>
In-Reply-To: <cover.1248546896.git.keil@b1-systems.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clean up isdnhdlc to meet current code standard.
Remove hint to already removed bit reversal table.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/i4l/isdnhdlc.c |  366 +++++++++++++++++++++++------------=
--------
 include/linux/isdn/hdlc.h   |   68 +++++----
 2 files changed, 231 insertions(+), 203 deletions(-)

diff --git a/drivers/isdn/i4l/isdnhdlc.c b/drivers/isdn/i4l/isdnhdlc.c
index 44ec741..b80e55a 100644
--- a/drivers/isdn/i4l/isdnhdlc.c
+++ b/drivers/isdn/i4l/isdnhdlc.c
@@ -1,23 +1,24 @@
 /*
  * isdnhdlc.c  --  General purpose ISDN HDLC decoder.
  *
- *Copyright (C) 2002	Wolfgang M=C3=BCes      <wolfgang@iksw-muees.de>
- *		2001 	Frode Isaksen      <fisaksen@bewan.com>
- *              2001 	Kai Germaschewski  <kai.germaschewski@gmx.de>
+ * Copyright (C)
+ *	2002	Wolfgang M=C3=BCes		<wolfgang@iksw-muees.de>
+ *	2001	Frode Isaksen		<fisaksen@bewan.com>
+ *	2001	Kai Germaschewski	<kai.germaschewski@gmx.de>
  *
- *      This program is free software; you can redistribute it and/or =
modify
- *      it under the terms of the GNU General Public License as publis=
hed by
- *      the Free Software Foundation; either version 2 of the License,=
 or
- *      (at your option) any later version.
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License as published b=
y
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
  *
- *      This program is distributed in the hope that it will be useful=
,
- *      but WITHOUT ANY WARRANTY; without even the implied warranty of
- *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- *      GNU General Public License for more details.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
  *
- *      You should have received a copy of the GNU General Public Lice=
nse
- *      along with this program; if not, write to the Free Software
- *      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
=20
 #include <linux/module.h>
@@ -36,20 +37,20 @@ MODULE_LICENSE("GPL");
 /*-------------------------------------------------------------------*=
/
=20
 enum {
-	HDLC_FAST_IDLE,HDLC_GET_FLAG_B0,HDLC_GETFLAG_B1A6,HDLC_GETFLAG_B7,
-	HDLC_GET_DATA,HDLC_FAST_FLAG
+	HDLC_FAST_IDLE, HDLC_GET_FLAG_B0, HDLC_GETFLAG_B1A6, HDLC_GETFLAG_B7,
+	HDLC_GET_DATA, HDLC_FAST_FLAG
 };
=20
 enum {
-	HDLC_SEND_DATA,HDLC_SEND_CRC1,HDLC_SEND_FAST_FLAG,
-	HDLC_SEND_FIRST_FLAG,HDLC_SEND_CRC2,HDLC_SEND_CLOSING_FLAG,
-	HDLC_SEND_IDLE1,HDLC_SEND_FAST_IDLE,HDLC_SENDFLAG_B0,
-	HDLC_SENDFLAG_B1A6,HDLC_SENDFLAG_B7,STOPPED
+	HDLC_SEND_DATA, HDLC_SEND_CRC1, HDLC_SEND_FAST_FLAG,
+	HDLC_SEND_FIRST_FLAG, HDLC_SEND_CRC2, HDLC_SEND_CLOSING_FLAG,
+	HDLC_SEND_IDLE1, HDLC_SEND_FAST_IDLE, HDLC_SENDFLAG_B0,
+	HDLC_SENDFLAG_B1A6, HDLC_SENDFLAG_B7, STOPPED
 };
=20
-void isdnhdlc_rcv_init (struct isdnhdlc_vars *hdlc, int do_adapt56)
+void isdnhdlc_rcv_init(struct isdnhdlc_vars *hdlc, int do_adapt56)
 {
-   	hdlc->bit_shift =3D 0;
+	hdlc->bit_shift =3D 0;
 	hdlc->hdlc_bits1 =3D 0;
 	hdlc->data_bits =3D 0;
 	hdlc->ffbit_shift =3D 0;
@@ -63,10 +64,12 @@ void isdnhdlc_rcv_init (struct isdnhdlc_vars *hdlc,=
 int do_adapt56)
 	hdlc->ffvalue =3D 0;
 	hdlc->dstpos =3D 0;
 }
+EXPORT_SYMBOL(isdnhdlc_out_init);
=20
-void isdnhdlc_out_init (struct isdnhdlc_vars *hdlc, int is_d_channel, =
int do_adapt56)
+void isdnhdlc_out_init(struct isdnhdlc_vars *hdlc, int is_d_channel,
+	int do_adapt56)
 {
-   	hdlc->bit_shift =3D 0;
+	hdlc->bit_shift =3D 0;
 	hdlc->hdlc_bits1 =3D 0;
 	hdlc->data_bits =3D 0;
 	hdlc->ffbit_shift =3D 0;
@@ -83,7 +86,7 @@ void isdnhdlc_out_init (struct isdnhdlc_vars *hdlc, i=
nt is_d_channel, int do_ada
 	}
 	hdlc->cbin =3D 0x7e;
 	hdlc->bit_shift =3D 0;
-	if(do_adapt56){
+	if (do_adapt56) {
 		hdlc->do_adapt56 =3D 1;
 		hdlc->data_bits =3D 0;
 		hdlc->state =3D HDLC_SENDFLAG_B0;
@@ -93,6 +96,25 @@ void isdnhdlc_out_init (struct isdnhdlc_vars *hdlc, =
int is_d_channel, int do_ada
 	}
 	hdlc->shift_reg =3D 0;
 }
+EXPORT_SYMBOL(isdnhdlc_rcv_init);
+
+static int
+check_frame(struct isdnhdlc_vars *hdlc)
+{
+	int status;
+
+	if (hdlc->dstpos < 2) 	/* too small - framing error */
+		status =3D -HDLC_FRAMING_ERROR;
+	else if (hdlc->crc !=3D 0xf0b8)	/* crc error */
+		status =3D -HDLC_CRC_ERROR;
+	else {
+		/* remove CRC */
+		hdlc->dstpos -=3D 2;
+		/* good frame */
+		status =3D hdlc->dstpos;
+	}
+	return status;
+}
=20
 /*
   isdnhdlc_decode - decodes HDLC frames from a transparent bit stream.
@@ -121,40 +143,63 @@ void isdnhdlc_out_init (struct isdnhdlc_vars *hdl=
c, int is_d_channel, int do_ada
   returns - number of decoded bytes in the destination buffer and stat=
us
   flag.
  */
-int isdnhdlc_decode (struct isdnhdlc_vars *hdlc, const unsigned char *=
src,
-		     int slen, int *count, unsigned char *dst, int dsize)
+int isdnhdlc_decode(struct isdnhdlc_vars *hdlc, const u8 *src, int sle=
n,
+	int *count, u8 *dst, int dsize)
 {
-	int status=3D0;
+	int status =3D 0;
=20
-	static const unsigned char fast_flag[]=3D{
-		0x00,0x00,0x00,0x20,0x30,0x38,0x3c,0x3e,0x3f
+	static const unsigned char fast_flag[] =3D {
+		0x00, 0x00, 0x00, 0x20, 0x30, 0x38, 0x3c, 0x3e, 0x3f
 	};
=20
-	static const unsigned char fast_flag_value[]=3D{
-		0x00,0x7e,0xfc,0xf9,0xf3,0xe7,0xcf,0x9f,0x3f
+	static const unsigned char fast_flag_value[] =3D {
+		0x00, 0x7e, 0xfc, 0xf9, 0xf3, 0xe7, 0xcf, 0x9f, 0x3f
 	};
=20
-	static const unsigned char fast_abort[]=3D{
-		0x00,0x00,0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0xfe,0xff
+	static const unsigned char fast_abort[] =3D {
+		0x00, 0x00, 0x80, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc, 0xfe, 0xff
 	};
=20
+#define handle_fast_flag(h) \
+	do {\
+		if (h->cbin =3D=3D fast_flag[h->bit_shift]) {\
+			h->ffvalue =3D fast_flag_value[h->bit_shift];\
+			h->state =3D HDLC_FAST_FLAG;\
+			h->ffbit_shift =3D h->bit_shift;\
+			h->bit_shift =3D 1;\
+		} else {\
+			h->state =3D HDLC_GET_DATA;\
+			h->data_received =3D 0;\
+		} \
+	} while (0)
+
+#define handle_abort(h) \
+	do {\
+		h->shift_reg =3D fast_abort[h->ffbit_shift - 1];\
+		h->hdlc_bits1 =3D h->ffbit_shift - 2;\
+		if (h->hdlc_bits1 < 0)\
+			h->hdlc_bits1 =3D 0;\
+		h->data_bits =3D h->ffbit_shift - 1;\
+		h->state =3D HDLC_GET_DATA;\
+		h->data_received =3D 0;\
+	} while (0)
+
 	*count =3D slen;
=20
-	while(slen > 0){
-		if(hdlc->bit_shift=3D=3D0){
+	while (slen > 0) {
+		if (hdlc->bit_shift =3D=3D 0) {
 			hdlc->cbin =3D *src++;
 			slen--;
 			hdlc->bit_shift =3D 8;
-			if(hdlc->do_adapt56){
-				hdlc->bit_shift --;
-			}
+			if (hdlc->do_adapt56)
+				hdlc->bit_shift--;
 		}
=20
-		switch(hdlc->state){
+		switch (hdlc->state) {
 		case STOPPED:
 			return 0;
 		case HDLC_FAST_IDLE:
-			if(hdlc->cbin =3D=3D 0xff){
+			if (hdlc->cbin =3D=3D 0xff) {
 				hdlc->bit_shift =3D 0;
 				break;
 			}
@@ -163,32 +208,30 @@ int isdnhdlc_decode (struct isdnhdlc_vars *hdlc, =
const unsigned char *src,
 			hdlc->bit_shift =3D 8;
 			break;
 		case HDLC_GET_FLAG_B0:
-			if(!(hdlc->cbin & 0x80)) {
+			if (!(hdlc->cbin & 0x80)) {
 				hdlc->state =3D HDLC_GETFLAG_B1A6;
 				hdlc->hdlc_bits1 =3D 0;
 			} else {
-				if(!hdlc->do_adapt56){
-					if(++hdlc->hdlc_bits1 >=3D8 ) if(hdlc->bit_shift=3D=3D1)
+				if ((!hdlc->do_adapt56) &&
+				    (++hdlc->hdlc_bits1 >=3D 8) &&
+				    (hdlc->bit_shift =3D=3D 1))
 						hdlc->state =3D HDLC_FAST_IDLE;
-				}
 			}
-			hdlc->cbin<<=3D1;
-			hdlc->bit_shift --;
+			hdlc->cbin <<=3D 1;
+			hdlc->bit_shift--;
 			break;
 		case HDLC_GETFLAG_B1A6:
-			if(hdlc->cbin & 0x80){
+			if (hdlc->cbin & 0x80) {
 				hdlc->hdlc_bits1++;
-				if(hdlc->hdlc_bits1=3D=3D6){
+				if (hdlc->hdlc_bits1 =3D=3D 6)
 					hdlc->state =3D HDLC_GETFLAG_B7;
-				}
-			} else {
+			} else
 				hdlc->hdlc_bits1 =3D 0;
-			}
-			hdlc->cbin<<=3D1;
-			hdlc->bit_shift --;
+			hdlc->cbin <<=3D 1;
+			hdlc->bit_shift--;
 			break;
 		case HDLC_GETFLAG_B7:
-			if(hdlc->cbin & 0x80) {
+			if (hdlc->cbin & 0x80) {
 				hdlc->state =3D HDLC_GET_FLAG_B0;
 			} else {
 				hdlc->state =3D HDLC_GET_DATA;
@@ -198,74 +241,55 @@ int isdnhdlc_decode (struct isdnhdlc_vars *hdlc, =
const unsigned char *src,
 				hdlc->data_bits =3D 0;
 				hdlc->data_received =3D 0;
 			}
-			hdlc->cbin<<=3D1;
-			hdlc->bit_shift --;
+			hdlc->cbin <<=3D 1;
+			hdlc->bit_shift--;
 			break;
 		case HDLC_GET_DATA:
-			if(hdlc->cbin & 0x80){
+			if (hdlc->cbin & 0x80) {
 				hdlc->hdlc_bits1++;
-				switch(hdlc->hdlc_bits1){
+				switch (hdlc->hdlc_bits1) {
 				case 6:
 					break;
 				case 7:
-					if(hdlc->data_received) {
-						// bad frame
+					if (hdlc->data_received)
+						/* bad frame */
 						status =3D -HDLC_FRAMING_ERROR;
-					}
-					if(!hdlc->do_adapt56){
-						if(hdlc->cbin=3D=3Dfast_abort[hdlc->bit_shift+1]){
-							hdlc->state =3D HDLC_FAST_IDLE;
-							hdlc->bit_shift=3D1;
+					if (!hdlc->do_adapt56) {
+						if (hdlc->cbin =3D=3D fast_abort
+						    [hdlc->bit_shift + 1]) {
+							hdlc->state =3D
+								HDLC_FAST_IDLE;
+							hdlc->bit_shift =3D 1;
 							break;
 						}
-					} else {
+					} else
 						hdlc->state =3D HDLC_GET_FLAG_B0;
-					}
 					break;
 				default:
-					hdlc->shift_reg>>=3D1;
+					hdlc->shift_reg >>=3D 1;
 					hdlc->shift_reg |=3D 0x80;
 					hdlc->data_bits++;
 					break;
 				}
 			} else {
-				switch(hdlc->hdlc_bits1){
+				switch (hdlc->hdlc_bits1) {
 				case 5:
 					break;
 				case 6:
-					if(hdlc->data_received){
-						if (hdlc->dstpos < 2) {
-							status =3D -HDLC_FRAMING_ERROR;
-						} else if (hdlc->crc !=3D 0xf0b8){
-							// crc error
-							status =3D -HDLC_CRC_ERROR;
-						} else {
-							// remove CRC
-							hdlc->dstpos -=3D 2;
-							// good frame
-							status =3D hdlc->dstpos;
-						}
-					}
+					if (hdlc->data_received)
+						status =3D check_frame(hdlc);
 					hdlc->crc =3D 0xffff;
 					hdlc->shift_reg =3D 0;
 					hdlc->data_bits =3D 0;
-					if(!hdlc->do_adapt56){
-						if(hdlc->cbin=3D=3Dfast_flag[hdlc->bit_shift]){
-							hdlc->ffvalue =3D fast_flag_value[hdlc->bit_shift];
-							hdlc->state =3D HDLC_FAST_FLAG;
-							hdlc->ffbit_shift =3D hdlc->bit_shift;
-							hdlc->bit_shift =3D 1;
-						} else {
-							hdlc->state =3D HDLC_GET_DATA;
-							hdlc->data_received =3D 0;
-						}
-					} else {
+					if (!hdlc->do_adapt56)
+						handle_fast_flag(hdlc);
+					else {
 						hdlc->state =3D HDLC_GET_DATA;
 						hdlc->data_received =3D 0;
 					}
 					break;
 				default:
-					hdlc->shift_reg>>=3D1;
+					hdlc->shift_reg >>=3D 1;
 					hdlc->data_bits++;
 					break;
 				}
@@ -278,16 +302,17 @@ int isdnhdlc_decode (struct isdnhdlc_vars *hdlc, =
const unsigned char *src,
 				hdlc->bit_shift--;
 				return status;
 			}
-			if(hdlc->data_bits=3D=3D8){
+			if (hdlc->data_bits =3D=3D 8) {
 				hdlc->data_bits =3D 0;
 				hdlc->data_received =3D 1;
-				hdlc->crc =3D crc_ccitt_byte(hdlc->crc, hdlc->shift_reg);
+				hdlc->crc =3D crc_ccitt_byte(hdlc->crc,
+						hdlc->shift_reg);
=20
-				// good byte received
-				if (hdlc->dstpos < dsize) {
+				/* good byte received */
+				if (hdlc->dstpos < dsize)
 					dst[hdlc->dstpos++] =3D hdlc->shift_reg;
-				} else {
-					// frame too long
+				else {
+					/* frame too long */
 					status =3D -HDLC_LENGTH_ERROR;
 					hdlc->dstpos =3D 0;
 				}
@@ -296,24 +321,18 @@ int isdnhdlc_decode (struct isdnhdlc_vars *hdlc, =
const unsigned char *src,
 			hdlc->bit_shift--;
 			break;
 		case HDLC_FAST_FLAG:
-			if(hdlc->cbin=3D=3Dhdlc->ffvalue){
+			if (hdlc->cbin =3D=3D hdlc->ffvalue) {
 				hdlc->bit_shift =3D 0;
 				break;
 			} else {
-				if(hdlc->cbin =3D=3D 0xff){
+				if (hdlc->cbin =3D=3D 0xff) {
 					hdlc->state =3D HDLC_FAST_IDLE;
-					hdlc->bit_shift=3D0;
-				} else if(hdlc->ffbit_shift=3D=3D8){
+					hdlc->bit_shift =3D 0;
+				} else if (hdlc->ffbit_shift =3D=3D 8) {
 					hdlc->state =3D HDLC_GETFLAG_B7;
 					break;
-				} else {
-					hdlc->shift_reg =3D fast_abort[hdlc->ffbit_shift-1];
-					hdlc->hdlc_bits1 =3D hdlc->ffbit_shift-2;
-					if(hdlc->hdlc_bits1<0)hdlc->hdlc_bits1 =3D 0;
-					hdlc->data_bits =3D hdlc->ffbit_shift-1;
-					hdlc->state =3D HDLC_GET_DATA;
-					hdlc->data_received =3D 0;
-				}
+				} else
+					handle_abort(hdlc);
 			}
 			break;
 		default:
@@ -323,7 +342,7 @@ int isdnhdlc_decode (struct isdnhdlc_vars *hdlc, co=
nst unsigned char *src,
 	*count -=3D slen;
 	return 0;
 }
-
+EXPORT_SYMBOL(isdnhdlc_decode);
 /*
   isdnhdlc_encode - encodes HDLC frames to a transparent bit stream.
=20
@@ -343,12 +362,11 @@ int isdnhdlc_decode (struct isdnhdlc_vars *hdlc, =
const unsigned char *src,
   dsize - destination buffer size
   returns - number of encoded bytes in the destination buffer
 */
-int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, const unsigned char *s=
rc,
-		unsigned short slen, int *count,
-		unsigned char *dst, int dsize)
+int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, const u8 *src, u16 sle=
n,
+	int *count, u8 *dst, int dsize)
 {
 	static const unsigned char xfast_flag_value[] =3D {
-		0x7e,0x3f,0x9f,0xcf,0xe7,0xf3,0xf9,0xfc,0x7e
+		0x7e, 0x3f, 0x9f, 0xcf, 0xe7, 0xf3, 0xf9, 0xfc, 0x7e
 	};
=20
 	int len =3D 0;
@@ -356,31 +374,34 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, c=
onst unsigned char *src,
 	*count =3D slen;
=20
 	while (dsize > 0) {
-		if(hdlc->bit_shift=3D=3D0){
-			if(slen && !hdlc->do_closing){
+		if (hdlc->bit_shift =3D=3D 0) {
+			if (slen && !hdlc->do_closing) {
 				hdlc->shift_reg =3D *src++;
 				slen--;
 				if (slen =3D=3D 0)
-					hdlc->do_closing =3D 1;  /* closing sequence, CRC + flag(s) */
+					/* closing sequence, CRC + flag(s) */
+					hdlc->do_closing =3D 1;
 				hdlc->bit_shift =3D 8;
 			} else {
-				if(hdlc->state =3D=3D HDLC_SEND_DATA){
-					if(hdlc->data_received){
+				if (hdlc->state =3D=3D HDLC_SEND_DATA) {
+					if (hdlc->data_received) {
 						hdlc->state =3D HDLC_SEND_CRC1;
 						hdlc->crc ^=3D 0xffff;
 						hdlc->bit_shift =3D 8;
-						hdlc->shift_reg =3D hdlc->crc & 0xff;
-					} else if(!hdlc->do_adapt56){
-						hdlc->state =3D HDLC_SEND_FAST_FLAG;
-					} else {
-						hdlc->state =3D HDLC_SENDFLAG_B0;
-					}
+						hdlc->shift_reg =3D
+							hdlc->crc & 0xff;
+					} else if (!hdlc->do_adapt56)
+						hdlc->state =3D
+							HDLC_SEND_FAST_FLAG;
+					else
+						hdlc->state =3D
+							HDLC_SENDFLAG_B0;
 				}
=20
 			}
 		}
=20
-		switch(hdlc->state){
+		switch (hdlc->state) {
 		case STOPPED:
 			while (dsize--)
 				*dst++ =3D 0xff;
@@ -388,14 +409,15 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, c=
onst unsigned char *src,
 			return dsize;
 		case HDLC_SEND_FAST_FLAG:
 			hdlc->do_closing =3D 0;
-			if(slen =3D=3D 0){
+			if (slen =3D=3D 0) {
 				*dst++ =3D hdlc->ffvalue;
 				len++;
 				dsize--;
 				break;
 			}
-			if(hdlc->bit_shift=3D=3D8){
-				hdlc->cbin =3D hdlc->ffvalue>>(8-hdlc->data_bits);
+			if (hdlc->bit_shift =3D=3D 8) {
+				hdlc->cbin =3D hdlc->ffvalue >>
+					(8 - hdlc->data_bits);
 				hdlc->state =3D HDLC_SEND_DATA;
 				hdlc->crc =3D 0xffff;
 				hdlc->hdlc_bits1 =3D 0;
@@ -413,17 +435,17 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, c=
onst unsigned char *src,
 			hdlc->cbin <<=3D 1;
 			hdlc->data_bits++;
 			hdlc->cbin++;
-			if(++hdlc->hdlc_bits1 =3D=3D 6)
+			if (++hdlc->hdlc_bits1 =3D=3D 6)
 				hdlc->state =3D HDLC_SENDFLAG_B7;
 			break;
 		case HDLC_SENDFLAG_B7:
 			hdlc->cbin <<=3D 1;
 			hdlc->data_bits++;
-			if(slen =3D=3D 0){
+			if (slen =3D=3D 0) {
 				hdlc->state =3D HDLC_SENDFLAG_B0;
 				break;
 			}
-			if(hdlc->bit_shift=3D=3D8){
+			if (hdlc->bit_shift =3D=3D 8) {
 				hdlc->state =3D HDLC_SEND_DATA;
 				hdlc->crc =3D 0xffff;
 				hdlc->hdlc_bits1 =3D 0;
@@ -432,7 +454,7 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, con=
st unsigned char *src,
 			break;
 		case HDLC_SEND_FIRST_FLAG:
 			hdlc->data_received =3D 1;
-			if(hdlc->data_bits=3D=3D8){
+			if (hdlc->data_bits =3D=3D 8) {
 				hdlc->state =3D HDLC_SEND_DATA;
 				hdlc->crc =3D 0xffff;
 				hdlc->hdlc_bits1 =3D 0;
@@ -440,11 +462,11 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, c=
onst unsigned char *src,
 			}
 			hdlc->cbin <<=3D 1;
 			hdlc->data_bits++;
-			if(hdlc->shift_reg & 0x01)
+			if (hdlc->shift_reg & 0x01)
 				hdlc->cbin++;
 			hdlc->shift_reg >>=3D 1;
 			hdlc->bit_shift--;
-			if(hdlc->bit_shift=3D=3D0){
+			if (hdlc->bit_shift =3D=3D 0) {
 				hdlc->state =3D HDLC_SEND_DATA;
 				hdlc->crc =3D 0xffff;
 				hdlc->hdlc_bits1 =3D 0;
@@ -453,14 +475,14 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, c=
onst unsigned char *src,
 		case HDLC_SEND_DATA:
 			hdlc->cbin <<=3D 1;
 			hdlc->data_bits++;
-			if(hdlc->hdlc_bits1 =3D=3D 5){
+			if (hdlc->hdlc_bits1 =3D=3D 5) {
 				hdlc->hdlc_bits1 =3D 0;
 				break;
 			}
-			if(hdlc->bit_shift=3D=3D8){
-				hdlc->crc =3D crc_ccitt_byte(hdlc->crc, hdlc->shift_reg);
-			}
-			if(hdlc->shift_reg & 0x01){
+			if (hdlc->bit_shift =3D=3D 8)
+				hdlc->crc =3D crc_ccitt_byte(hdlc->crc,
+					hdlc->shift_reg);
+			if (hdlc->shift_reg & 0x01) {
 				hdlc->hdlc_bits1++;
 				hdlc->cbin++;
 				hdlc->shift_reg >>=3D 1;
@@ -474,11 +496,11 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, c=
onst unsigned char *src,
 		case HDLC_SEND_CRC1:
 			hdlc->cbin <<=3D 1;
 			hdlc->data_bits++;
-			if(hdlc->hdlc_bits1 =3D=3D 5){
+			if (hdlc->hdlc_bits1 =3D=3D 5) {
 				hdlc->hdlc_bits1 =3D 0;
 				break;
 			}
-			if(hdlc->shift_reg & 0x01){
+			if (hdlc->shift_reg & 0x01) {
 				hdlc->hdlc_bits1++;
 				hdlc->cbin++;
 				hdlc->shift_reg >>=3D 1;
@@ -488,7 +510,7 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, con=
st unsigned char *src,
 				hdlc->shift_reg >>=3D 1;
 				hdlc->bit_shift--;
 			}
-			if(hdlc->bit_shift=3D=3D0){
+			if (hdlc->bit_shift =3D=3D 0) {
 				hdlc->shift_reg =3D (hdlc->crc >> 8);
 				hdlc->state =3D HDLC_SEND_CRC2;
 				hdlc->bit_shift =3D 8;
@@ -497,11 +519,11 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, c=
onst unsigned char *src,
 		case HDLC_SEND_CRC2:
 			hdlc->cbin <<=3D 1;
 			hdlc->data_bits++;
-			if(hdlc->hdlc_bits1 =3D=3D 5){
+			if (hdlc->hdlc_bits1 =3D=3D 5) {
 				hdlc->hdlc_bits1 =3D 0;
 				break;
 			}
-			if(hdlc->shift_reg & 0x01){
+			if (hdlc->shift_reg & 0x01) {
 				hdlc->hdlc_bits1++;
 				hdlc->cbin++;
 				hdlc->shift_reg >>=3D 1;
@@ -511,7 +533,7 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, con=
st unsigned char *src,
 				hdlc->shift_reg >>=3D 1;
 				hdlc->bit_shift--;
 			}
-			if(hdlc->bit_shift=3D=3D0){
+			if (hdlc->bit_shift =3D=3D 0) {
 				hdlc->shift_reg =3D 0x7e;
 				hdlc->state =3D HDLC_SEND_CLOSING_FLAG;
 				hdlc->bit_shift =3D 8;
@@ -520,33 +542,36 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, c=
onst unsigned char *src,
 		case HDLC_SEND_CLOSING_FLAG:
 			hdlc->cbin <<=3D 1;
 			hdlc->data_bits++;
-			if(hdlc->hdlc_bits1 =3D=3D 5){
+			if (hdlc->hdlc_bits1 =3D=3D 5) {
 				hdlc->hdlc_bits1 =3D 0;
 				break;
 			}
-			if(hdlc->shift_reg & 0x01){
+			if (hdlc->shift_reg & 0x01)
 				hdlc->cbin++;
-			}
 			hdlc->shift_reg >>=3D 1;
 			hdlc->bit_shift--;
-			if(hdlc->bit_shift=3D=3D0){
-				hdlc->ffvalue =3D xfast_flag_value[hdlc->data_bits];
-				if(hdlc->dchannel){
+			if (hdlc->bit_shift =3D=3D 0) {
+				hdlc->ffvalue =3D
+					xfast_flag_value[hdlc->data_bits];
+				if (hdlc->dchannel) {
 					hdlc->ffvalue =3D 0x7e;
 					hdlc->state =3D HDLC_SEND_IDLE1;
 					hdlc->bit_shift =3D 8-hdlc->data_bits;
-					if(hdlc->bit_shift=3D=3D0)
-						hdlc->state =3D HDLC_SEND_FAST_IDLE;
+					if (hdlc->bit_shift =3D=3D 0)
+						hdlc->state =3D
+							HDLC_SEND_FAST_IDLE;
 				} else {
-					if(!hdlc->do_adapt56){
-						hdlc->state =3D HDLC_SEND_FAST_FLAG;
+					if (!hdlc->do_adapt56) {
+						hdlc->state =3D
+							HDLC_SEND_FAST_FLAG;
 						hdlc->data_received =3D 0;
 					} else {
 						hdlc->state =3D HDLC_SENDFLAG_B0;
 						hdlc->data_received =3D 0;
 					}
-					// Finished with this frame, send flags
-					if (dsize > 1) dsize =3D 1;
+					/* Finished this frame, send flags */
+					if (dsize > 1)
+						dsize =3D 1;
 				}
 			}
 			break;
@@ -556,7 +581,7 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, con=
st unsigned char *src,
 			hdlc->cbin++;
 			hdlc->data_bits++;
 			hdlc->bit_shift--;
-			if(hdlc->bit_shift=3D=3D0){
+			if (hdlc->bit_shift =3D=3D 0) {
 				hdlc->state =3D HDLC_SEND_FAST_IDLE;
 				hdlc->bit_shift =3D 0;
 			}
@@ -565,12 +590,13 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, c=
onst unsigned char *src,
 			hdlc->do_closing =3D 0;
 			hdlc->cbin =3D 0xff;
 			hdlc->data_bits =3D 8;
-			if(hdlc->bit_shift =3D=3D 8){
+			if (hdlc->bit_shift =3D=3D 8) {
 				hdlc->cbin =3D 0x7e;
 				hdlc->state =3D HDLC_SEND_FIRST_FLAG;
 			} else {
 				*dst++ =3D hdlc->cbin;
-				hdlc->bit_shift =3D hdlc->data_bits =3D 0;
+				hdlc->bit_shift =3D 0;
+				hdlc->data_bits =3D 0;
 				len++;
 				dsize =3D 0;
 			}
@@ -578,14 +604,14 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, c=
onst unsigned char *src,
 		default:
 			break;
 		}
-		if(hdlc->do_adapt56){
-			if(hdlc->data_bits=3D=3D7){
+		if (hdlc->do_adapt56) {
+			if (hdlc->data_bits =3D=3D 7) {
 				hdlc->cbin <<=3D 1;
 				hdlc->cbin++;
 				hdlc->data_bits++;
 			}
 		}
-		if(hdlc->data_bits=3D=3D8){
+		if (hdlc->data_bits =3D=3D 8) {
 			*dst++ =3D hdlc->cbin;
 			hdlc->data_bits =3D 0;
 			len++;
@@ -596,8 +622,4 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, con=
st unsigned char *src,
=20
 	return len;
 }
-
-EXPORT_SYMBOL(isdnhdlc_rcv_init);
-EXPORT_SYMBOL(isdnhdlc_decode);
-EXPORT_SYMBOL(isdnhdlc_out_init);
 EXPORT_SYMBOL(isdnhdlc_encode);
diff --git a/include/linux/isdn/hdlc.h b/include/linux/isdn/hdlc.h
index cf0a95a..8f3540c 100644
--- a/include/linux/isdn/hdlc.h
+++ b/include/linux/isdn/hdlc.h
@@ -1,27 +1,28 @@
 /*
- * isdnhdlc.h  --  General purpose ISDN HDLC decoder.
+ * hdlc.h  --  General purpose ISDN HDLC decoder.
  *
  * Implementation of a HDLC decoder/encoder in software.
  * Neccessary because some ISDN devices don't have HDLC
- * controllers. Also included: a bit reversal table.
+ * controllers.
  *
- *Copyright (C) 2002    Wolfgang M=C3=BCes      <wolfgang@iksw-muees.d=
e>
- *		2001 	Frode Isaksen      <fisaksen@bewan.com>
- *              2001 	Kai Germaschewski  <kai.germaschewski@gmx.de>
+ * Copyright (C)
+ *	2002	Wolfgang M=C3=BCes		<wolfgang@iksw-muees.de>
+ *	2001	Frode Isaksen		<fisaksen@bewan.com>
+ *	2001	Kai Germaschewski	<kai.germaschewski@gmx.de>
  *
- *      This program is free software; you can redistribute it and/or =
modify
- *      it under the terms of the GNU General Public License as publis=
hed by
- *      the Free Software Foundation; either version 2 of the License,=
 or
- *      (at your option) any later version.
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License as published b=
y
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
  *
- *      This program is distributed in the hope that it will be useful=
,
- *      but WITHOUT ANY WARRANTY; without even the implied warranty of
- *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- *      GNU General Public License for more details.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
  *
- *      You should have received a copy of the GNU General Public Lice=
nse
- *      along with this program; if not, write to the Free Software
- *      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
=20
 #ifndef __ISDNHDLC_H__
@@ -31,20 +32,24 @@ struct isdnhdlc_vars {
 	int bit_shift;
 	int hdlc_bits1;
 	int data_bits;
-	int ffbit_shift; 	// encoding only
+	int ffbit_shift;	/* encoding only */
 	int state;
 	int dstpos;
=20
-	unsigned short crc;
+	u16 crc;
=20
-	unsigned char cbin;
-	unsigned char shift_reg;
-	unsigned char ffvalue;
+	u8 cbin;
+	u8 shift_reg;
+	u8 ffvalue;
=20
-	unsigned int data_received:1; 	// set if transferring data
-	unsigned int dchannel:1; 	// set if D channel (send idle instead of f=
lags)
-	unsigned int do_adapt56:1; 	// set if 56K adaptation
-	unsigned int do_closing:1; 	// set if in closing phase (need to send =
CRC + flag
+	/* set if transferring data */
+	u32 data_received:1;
+	/* set if D channel (send idle instead of flags) */
+	u32 dchannel:1;
+	/* set if 56K adaptation */
+	u32 do_adapt56:1;
+	/* set if in closing phase (need to send CRC + flag) */
+	u32 do_closing:1;
 };
=20
=20
@@ -57,14 +62,15 @@ struct isdnhdlc_vars {
 #define HDLC_CRC_ERROR         2
 #define HDLC_LENGTH_ERROR      3
=20
-extern void isdnhdlc_rcv_init (struct isdnhdlc_vars *hdlc, int do_adap=
t56);
+extern void	isdnhdlc_rcv_init(struct isdnhdlc_vars *hdlc, int do_adapt=
56);
=20
-extern int isdnhdlc_decode (struct isdnhdlc_vars *hdlc, const unsigned=
 char *src, int slen,int *count,
-	                    unsigned char *dst, int dsize);
+extern int	isdnhdlc_decode(struct isdnhdlc_vars *hdlc, const u8 *src,
+			int slen, int *count, u8 *dst, int dsize);
=20
-extern void isdnhdlc_out_init (struct isdnhdlc_vars *hdlc,int is_d_cha=
nnel,int do_adapt56);
+extern void	isdnhdlc_out_init(struct isdnhdlc_vars *hdlc, int is_d_cha=
nnel,
+			int do_adapt56);
=20
-extern int isdnhdlc_encode (struct isdnhdlc_vars *hdlc,const unsigned =
char *src,unsigned short slen,int *count,
-	                    unsigned char *dst,int dsize);
+extern int	isdnhdlc_encode(struct isdnhdlc_vars *hdlc, const u8 *src,
+			u16 slen, int *count, u8 *dst, int dsize);
=20
 #endif /* __ISDNHDLC_H__ */
--=20
1.6.0.2
