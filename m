From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Patch for NETLINK_TCPDIAG
Date: Tue, 20 May 2003 11:49:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF172D8043.CEAC83BF-ON88256D2C.0066D5DE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Hi,

I am not sure if there is a reason why ACK cannot be set for
NETLINK_TCPDIAG.
If it is settable, please apply following patch.

thanks,

- KK

diff -ruN linux-2.5.68.org/net/ipv4/tcp_diag.c linux-2.5.68/net/ipv4/tcp_diag.c
--- linux-2.5.68.org/net/ipv4/tcp_diag.c  2003-05-20 11:38:06.000000000 -0700
+++ linux-2.5.68/net/ipv4/tcp_diag.c      2003-05-20 11:39:48.000000000 -0700
@@ -609,7 +609,7 @@
            if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
                  return;
            err = tcpdiag_rcv_msg(skb, nlh);
-           if (err)
+           if (err || nlh->nlmsg_flags & NLM_F_ACK)
                  netlink_ack(skb, nlh, err);
      }
 }
