From: Hua Zhong <hzhong@gmail.com>
Subject: [PATCH]: suspicious unlikely usage in tcp_transmit_skb()
Date: Mon, 24 Apr 2006 16:25:39 -0700
Message-ID: <444D5E73.7020803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.194]:33708 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751480AbWDXXZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 19:25:42 -0400
Received: by nz-out-0102.google.com with SMTP id r28so1005366nza
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2006 16:25:41 -0700 (PDT)
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am developing a profiling tool to check if likely/unlikely usages are wise. I find that the following one is always a miss:

      # Hit    # miss Function:Filename@Line
!         0     50505 tcp_transmit_skb():net/ipv4/tcp_output.c@468

There is a chance that my tool is buggy, but I just want to confirm with you whether this does look suspicious and what your opinion is.

Signed-off-by: Hua Zhong <hzhong@gmail.com>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a28ae59..743016b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -465,7 +465,7 @@ #define SYSCTL_FLAG_SACK    0x4
        TCP_INC_STATS(TCP_MIB_OUTSEGS);
 
        err = icsk->icsk_af_ops->queue_xmit(skb, 0);
-       if (unlikely(err <= 0))
+       if (likely(err <= 0))
                return err;
 
        tcp_enter_cwr(sk);


