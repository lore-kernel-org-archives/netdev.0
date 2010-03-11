From: akpm@linux-foundation.org
Subject: [patch 3/3] i4l: change magic numbers in Eicon DIVA ISDN driver to symbolic names
Date: Thu, 11 Mar 2010 14:07:25 -0800
Message-ID: <201003112207.o2BM7PlG013464@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	imunsie@au.ibm.com, mac@melware.de, sgayda2@uiuc.edu
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46085 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758265Ab0CKWHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 17:07:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Munsie <imunsie@au.ibm.com>

Replace references to the '20' magic number found throughout the Eicon
ISDN driver for the length of the station_id field in the T30_INFO struct
with the T30_MAX_STATION_ID_LENGTH symbolic constant.

Signed-off-by: Ian Munsie <imunsie@au.ibm.com>
Cc: Armin Schindler <mac@melware.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: Stoyan Gaydarov <sgayda2@uiuc.edu>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hardware/eicon/message.c |   32 ++++++++++++------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff -puN drivers/isdn/hardware/eicon/message.c~i4l-change-magic-numbers-in-eicon-diva-isdn-driver-to-symbolic-names drivers/isdn/hardware/eicon/message.c
--- a/drivers/isdn/hardware/eicon/message.c~i4l-change-magic-numbers-in-eicon-diva-isdn-driver-to-symbolic-names
+++ a/drivers/isdn/hardware/eicon/message.c
@@ -2754,7 +2754,7 @@ static byte connect_b3_req(dword Id, wor
                     for (i = 0; i < w; i++)
                       ((T30_INFO   *)(plci->fax_connect_info_buffer))->station_id[i] = fax_parms[4].info[1+i];
                     ((T30_INFO   *)(plci->fax_connect_info_buffer))->head_line_len = 0;
-                    len = offsetof(T30_INFO, station_id) + 20;
+                    len = offsetof(T30_INFO, station_id) + T30_MAX_STATION_ID_LENGTH;
                     w = fax_parms[5].length;
                     if (w > 20)
                       w = 20;
@@ -2892,7 +2892,7 @@ static byte connect_b3_res(dword Id, wor
     && (plci->nsf_control_bits & T30_NSF_CONTROL_BIT_ENABLE_NSF)
     && (plci->nsf_control_bits & T30_NSF_CONTROL_BIT_NEGOTIATE_RESP))
    {
-            len = offsetof(T30_INFO, station_id) + 20;
+            len = offsetof(T30_INFO, station_id) + T30_MAX_STATION_ID_LENGTH;
             if (plci->fax_connect_info_length < len)
             {
               ((T30_INFO *)(plci->fax_connect_info_buffer))->station_id_len = 0;
@@ -3802,7 +3802,7 @@ static byte manufacturer_res(dword Id, w
       break;
     }
     ncpi = &m_parms[1];
-    len = offsetof(T30_INFO, station_id) + 20;
+    len = offsetof(T30_INFO, station_id) + T30_MAX_STATION_ID_LENGTH;
     if (plci->fax_connect_info_length < len)
     {
       ((T30_INFO *)(plci->fax_connect_info_buffer))->station_id_len = 0;
@@ -6830,7 +6830,7 @@ static void nl_ind(PLCI *plci)
         if(((T30_INFO   *)plci->NL.RBuffer->P)->station_id_len)
         {
           plci->ncpi_buffer[len] = 20;
-          for (i = 0; i < 20; i++)
+          for (i = 0; i < T30_MAX_STATION_ID_LENGTH; i++)
             plci->ncpi_buffer[++len] = ((T30_INFO   *)plci->NL.RBuffer->P)->station_id[i];
         }
         if (((plci->NL.Ind & 0x0f) == N_DISC) || ((plci->NL.Ind & 0x0f) == N_DISC_ACK))
@@ -6844,7 +6844,7 @@ static void nl_ind(PLCI *plci)
         if ((plci->requested_options_conn | plci->requested_options | a->requested_options_table[plci->appl->Id-1])
           & ((1L << PRIVATE_FAX_SUB_SEP_PWD) | (1L << PRIVATE_FAX_NONSTANDARD)))
         {
-          i = offsetof(T30_INFO, station_id) + 20 + ((T30_INFO   *)plci->NL.RBuffer->P)->head_line_len;
+          i = offsetof(T30_INFO, station_id) + T30_MAX_STATION_ID_LENGTH + ((T30_INFO   *)plci->NL.RBuffer->P)->head_line_len;
           while (i < plci->NL.RBuffer->length)
             plci->ncpi_buffer[++len] = plci->NL.RBuffer->P[i++];
         }
@@ -8400,7 +8400,7 @@ static word add_b23(PLCI *plci, API_PARS
         }
       }
       /* copy station id to NLC */
-      for(i=0; i<20; i++)
+      for(i=0; i < T30_MAX_STATION_ID_LENGTH; i++)
       {
         if(i<b3_config_parms[2].length)
         {
@@ -8411,29 +8411,29 @@ static word add_b23(PLCI *plci, API_PARS
           ((T30_INFO *)&nlc[1])->station_id[i] = ' ';
         }
       }
-      ((T30_INFO *)&nlc[1])->station_id_len = 20;
+      ((T30_INFO *)&nlc[1])->station_id_len = T30_MAX_STATION_ID_LENGTH;
       /* copy head line to NLC */
       if(b3_config_parms[3].length)
       {
 
-        pos = (byte)(fax_head_line_time (&(((T30_INFO *)&nlc[1])->station_id[20])));
+        pos = (byte)(fax_head_line_time (&(((T30_INFO *)&nlc[1])->station_id[T30_MAX_STATION_ID_LENGTH])));
         if (pos != 0)
         {
           if (CAPI_MAX_DATE_TIME_LENGTH + 2 + b3_config_parms[3].length > CAPI_MAX_HEAD_LINE_SPACE)
             pos = 0;
           else
           {
-            nlc[1 + offsetof(T30_INFO, station_id) + 20 + pos++] = ' ';
-            nlc[1 + offsetof(T30_INFO, station_id) + 20 + pos++] = ' ';
+            nlc[1 + offsetof(T30_INFO, station_id) + T30_MAX_STATION_ID_LENGTH + pos++] = ' ';
+            nlc[1 + offsetof(T30_INFO, station_id) + T30_MAX_STATION_ID_LENGTH + pos++] = ' ';
             len = (byte)b3_config_parms[2].length;
             if (len > 20)
               len = 20;
             if (CAPI_MAX_DATE_TIME_LENGTH + 2 + len + 2 + b3_config_parms[3].length <= CAPI_MAX_HEAD_LINE_SPACE)
             {
               for (i = 0; i < len; i++)
-                nlc[1 + offsetof(T30_INFO, station_id) + 20 + pos++] = ((byte   *)b3_config_parms[2].info)[1+i];
-              nlc[1 + offsetof(T30_INFO, station_id) + 20 + pos++] = ' ';
-              nlc[1 + offsetof(T30_INFO, station_id) + 20 + pos++] = ' ';
+                nlc[1 + offsetof(T30_INFO, station_id) + T30_MAX_STATION_ID_LENGTH + pos++] = ((byte   *)b3_config_parms[2].info)[1+i];
+              nlc[1 + offsetof(T30_INFO, station_id) + T30_MAX_STATION_ID_LENGTH + pos++] = ' ';
+              nlc[1 + offsetof(T30_INFO, station_id) + T30_MAX_STATION_ID_LENGTH + pos++] = ' ';
             }
           }
         }
@@ -8444,7 +8444,7 @@ static word add_b23(PLCI *plci, API_PARS
         ((T30_INFO *)&nlc[1])->head_line_len = (byte)(pos + len);
         nlc[0] += (byte)(pos + len);
         for (i = 0; i < len; i++)
-          nlc[1 + offsetof(T30_INFO, station_id) + 20 + pos++] =  ((byte   *)b3_config_parms[3].info)[1+i];
+          nlc[1 + offsetof(T30_INFO, station_id) + T30_MAX_STATION_ID_LENGTH + pos++] =  ((byte   *)b3_config_parms[3].info)[1+i];
       } else
         ((T30_INFO *)&nlc[1])->head_line_len = 0;
 
@@ -8472,7 +8472,7 @@ static word add_b23(PLCI *plci, API_PARS
             fax_control_bits |= T30_CONTROL_BIT_ACCEPT_SEL_POLLING;
           }
             len = nlc[0];
-          pos = offsetof(T30_INFO, station_id) + 20;
+          pos = offsetof(T30_INFO, station_id) + T30_MAX_STATION_ID_LENGTH;
    if (pos < plci->fax_connect_info_length)
    {
      for (i = 1 + plci->fax_connect_info_buffer[pos]; i != 0; i--)
@@ -8524,7 +8524,7 @@ static word add_b23(PLCI *plci, API_PARS
       }
 
       PUT_WORD(&(((T30_INFO *)&nlc[1])->control_bits_low), fax_control_bits);
-      len = offsetof(T30_INFO, station_id) + 20;
+      len = offsetof(T30_INFO, station_id) + T30_MAX_STATION_ID_LENGTH;
       for (i = 0; i < len; i++)
         plci->fax_connect_info_buffer[i] = nlc[1+i];
       ((T30_INFO   *) plci->fax_connect_info_buffer)->head_line_len = 0;
_
