From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/phy: Remove return value for a void function
Date: Tue, 01 Apr 2014 11:04:05 -0700
Message-ID: <1396375445.21529.95.camel@joe-AO722>
References: <1396363464-28923-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	emmedve1@Freescale.com
To: Shruti@Freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0083.hostedemail.com ([216.40.44.83]:42226 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751913AbaDASEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 14:04:09 -0400
In-Reply-To: <1396363464-28923-1-git-send-email-Shruti@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a spatch script for this:

$ cat void_return.cocci
@@
identifier func;
expression S;
@@
void func(...) {
...
	if (...)
-		return S;
+		{ S; return; }
...
}

@@
identifier func;
expression S;
@@
void func(...) {
...
	if (...) {
...
-		return S;
+		S;
	}
...
}

@@
identifier func;
expression S;
@@
void func(...) {
...
-	return S;
+	S;
}
