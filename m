From: David Miller <davem@davemloft.net>
Subject: Re: Commit 270637abff0cdf848b910b9f96ad342e1da61c66 introduced a
 lot new compiler warnings
Date: Fri, 21 Mar 2008 15:43:40 -0700 (PDT)
Message-ID: <20080321.154340.210302849.davem@davemloft.net>
References: <47E40856.6020902@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, vladislav.yasevich@hp.com,
	sri@us.ibm.com, netdev@vger.kernel.org
To: nix.or.die@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57124
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756118AbYCUWn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 18:43:29 -0400
In-Reply-To: <47E40856.6020902@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gabriel C <nix.or.die@googlemail.com>
Date: Fri, 21 Mar 2008 20:11:18 +0100

> I noticed the following new compile warnings on current git head introduced by 270637abff0cdf848b910b9f96ad342e1da61c66 :

Please include netdev@vger.kernel.org for networking bug
reports in the future, thank you.

Thanks for the report, I'll push the following fix:

commit 1233823b0847190976d69a86d7bb1287992ba2c7
Author: David S. Miller <davem@davemloft.net>
Date:   Fri Mar 21 15:40:47 2008 -0700

    [SCTP]: Fix build warnings with IPV6 disabled.
    
    Introduced by 270637abff0cdf848b910b9f96ad342e1da61c66
    ("[SCTP]: Fix a race between module load and protosw access")
    
    Reported by Gabriel C:
    
    In file included from net/sctp/sm_statetable.c:50:
    include/net/sctp/sctp.h: In function 'sctp_v6_pf_init':
    include/net/sctp/sctp.h:392: warning: 'return' with a value, in function returning void
    In file included from net/sctp/sm_statefuns.c:62:
    include/net/sctp/sctp.h: In function 'sctp_v6_pf_init':
    include/net/sctp/sctp.h:392: warning: 'return' with a value, in function returning void
     ...
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 57ed3e3..ea80673 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -389,7 +389,7 @@ void sctp_v6_del_protocol(void);
 
 #else /* #ifdef defined(CONFIG_IPV6) */
 
-static inline void sctp_v6_pf_init(void) { return 0; }
+static inline void sctp_v6_pf_init(void) { return; }
 static inline void sctp_v6_pf_exit(void) { return; }
 static inline int sctp_v6_protosw_init(void) { return 0; }
 static inline void sctp_v6_protosw_exit(void) { return; }
