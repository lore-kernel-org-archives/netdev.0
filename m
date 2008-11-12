From: Douglas Leith <Doug.Leith@nuim.ie>
Subject: Re: [PATCH 2.6.27] tcp_htcp: last_cong bug fix
Date: Wed, 12 Nov 2008 08:36:30 +0000
Message-ID: <98649BFE-855E-429E-AB30-BAFED77A5FF1@nuim.ie>
References: <0E5A87BC-8FA8-40A5-8032-9FA18D07D7CE@nuim.ie>
 <20081110.215033.22437445.davem@davemloft.net>
 <B4ABF490-649C-4981-A953-B5FA55022EBD@nuim.ie>
 <20081111.141600.225275728.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_Z3Esuaz9Zjydcn9Er/v0VA)"
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:47972 "EHLO banyan.nuim.ie"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753770AbYKLIg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 03:36:27 -0500
Received: from [10.220.3.214] ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTPSA id <0KA7002C1P8PN770@mango.nuim.ie> for
 netdev@vger.kernel.org; Wed, 12 Nov 2008 08:36:25 +0000 (GMT)
In-reply-to: <20081111.141600.225275728.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Boundary_(ID_Z3Esuaz9Zjydcn9Er/v0VA)
Content-type: text/plain; charset=US-ASCII; format=flowed
Content-transfer-encoding: 7BIT

Patch attached.

On 11 Nov 2008, at 22:16, David Miller wrote:

> From: Douglas Leith <Doug.Leith@nuim.ie>
> Date: Tue, 11 Nov 2008 15:33:33 +0000
>
>> Revised patch with requested style changes.
>
> Your email client corrupted the patch, turning tab characters
> into spaces.
>
> Please turn off content formatting in your email client,
> or alternatively use an attachment for the patch itself.
>
> There is some help in linux/Documentation/email-clients.txt
>
> Please fix this up and resubmit, thank you very much.

--Boundary_(ID_Z3Esuaz9Zjydcn9Er/v0VA)
Content-type: application/octet-stream; x-unix-mode=0644; name=patch.diff
Content-transfer-encoding: 7bit
Content-disposition: attachment; filename=patch.diff

--- net/ipv4/tcp_htcp.c	2008-11-05 15:50:18.000000000 +0000
+++ net/ipv4/tcp_htcp.c.new	2008-11-11 15:20:31.000000000 +0000
@@ -71,5 +71,8 @@ static u32 htcp_cwnd_undo(struct sock *s
 
-	ca->last_cong = ca->undo_last_cong;
-	ca->maxRTT = ca->undo_maxRTT;
-	ca->old_maxB = ca->undo_old_maxB;
+	if (ca->undo_last_cong) {
+		ca->last_cong = ca->undo_last_cong;
+		ca->maxRTT = ca->undo_maxRTT;
+		ca->old_maxB = ca->undo_old_maxB;
+		ca->undo_last_cong = 0;  
+	}
 
@@ -267,8 +270,11 @@ static void htcp_state(struct sock *sk, 
 	switch (new_state) {
-	case TCP_CA_Open:
+	case TCP_CA_Open: 
 		{
 			struct htcp *ca = inet_csk_ca(sk);
-			ca->last_cong = jiffies;
+        		if (ca->undo_last_cong) { 
+				ca->last_cong = jiffies;   
+				ca->undo_last_cong = 0;
+			}
 		}
-		break;
+		break;	
 	case TCP_CA_CWR:

--Boundary_(ID_Z3Esuaz9Zjydcn9Er/v0VA)--
