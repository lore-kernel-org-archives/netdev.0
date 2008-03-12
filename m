From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] Re: WAN: new PPP code for generic HDLC
Date: Wed, 12 Mar 2008 20:38:01 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0803122032410.14822@fbirervta.pbzchgretzou.qr>
References: <m3prtzsszg.fsf@maximus.localdomain> <m3lk4nsskh.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:51983 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbYCLTiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 15:38:04 -0400
In-Reply-To: <m3lk4nsskh.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 12 2008 19:30, Krzysztof Halasa wrote:
>+	/* LCP only */
>+	if (pid == PID_LCP)
>+		switch (cp->code) {
>+		case LCP_PROTO_REJ:
>+			pid = ntohs(*(__be16*)skb->data);

What if skb->data happens to be unaligned (can that even happen?)

BTW, here are some consts:


diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index b626aae..0e4cb1f 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -40,7 +40,7 @@ enum {CP_CONF_REQ = 1, CP_CONF_ACK, CP_CONF_NAK, CP_CONF_REJ, CP_TERM_REQ,
       CP_TERM_ACK, CP_CODE_REJ, LCP_PROTO_REJ, LCP_ECHO_REQ, LCP_ECHO_REPLY,
       LCP_DISC_REQ, CP_CODES};
 #if DEBUG_CP
-static const char *code_names[CP_CODES] = {"0", "ConfReq", "ConfAck",
+static const char *const code_names[] = {"0", "ConfReq", "ConfAck",
 					   "ConfNak", "ConfRej", "TermReq",
 					   "TermAck", "CodeRej", "ProtoRej",
 					   "EchoReq", "EchoReply", "Discard"};
@@ -90,10 +90,10 @@ enum {INV = 0x10, IRC = 0x20, ZRC = 0x40, SCR = 0x80, SCA = 0x100,
       SCN = 0x200, STR = 0x400, STA = 0x800, SCJ = 0x1000};
 
 #if DEBUG_STATE
-static const char *state_names[STATES] = {"Closed", "Stopped", "Stopping",
+static const char *const state_names[] = {"Closed", "Stopped", "Stopping",
 					  "ReqSent", "AckRecv", "AckSent",
 					  "Opened"};
-static const char *event_names[EVENTS] = {"Start", "Stop", "TO+", "TO-",
+static const char *const event_names[] = {"Start", "Stop", "TO+", "TO-",
 					  "RCR+", "RCR-", "RCA", "RCN",
 					  "RTR", "RTA", "RUC", "RXJ+", "RXJ-"};
 #endif
@@ -374,7 +374,7 @@ static void ppp_cp_event(struct net_device *dev, u16 pid, u16 event, u8 code,
 static void ppp_cp_parse_cr(struct net_device *dev, u16 pid, u8 id,
 			    unsigned int len, u8 *data)
 {
-	static u8 valid_accm[6] = { LCP_OPTION_ACCM, 6, 0, 0, 0, 0 };
+	static const u8 valid_accm[] = { LCP_OPTION_ACCM, 6, 0, 0, 0, 0 };
 	u8 *opt, *out;
 	unsigned int nak_len = 0, rej_len = 0;
 
