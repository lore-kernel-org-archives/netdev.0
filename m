From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 0/2] inet_diag: Fix old/new inet_diag_req-s structures
Date: Wed, 11 Jan 2012 12:35:32 +0400
Message-ID: <4F0D49D4.7040100@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:28617 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752172Ab2AKIfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 03:35:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent changes to inet_diag broke the compilation of tools using kernel headers.

Fix this by doing two sequential renames:

 inet_diag_req -> inet_diag_req_v2
 inet_diag_req_compat -> inet_diag_req

After this the changes in the user-space visible part of the inet_diag.h are
* add the inet_diag_req_v2
* extend the INET_DIAG_ extensions list

The set applies to current net tree.


David, Stephen, I'm a little bit confused with the situation with this header. Can
you please comment on the (quite ancient) commit 73c1f4a0 ([TCPDIAG]: Just rename 
everything to inet_diag) from acme@? This commit did the similar thing with inet_diag
header -- flushed away the old struct and introduced a new one keeping just the binary
compatibility. Why was the breakage of tools caused by this commit considered as 
acceptable?

Thanks,
Pavel
