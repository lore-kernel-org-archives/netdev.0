From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH - SCTP] Fix multihomed connection failures on 64-bit systems.
Date: Fri, 7 May 2004 14:51:02 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405071443050.17510@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

The following patch from Vladislav Yasevich fixes an SCTP issue with 64-bit
systems.
This applies to 2.4 tree also with a small offset.

[SCTP] Fix multihomed connection failures on 64-bit systems.

Avoid the use of sizeof() and pointer arithmetic to get to the end
of sctp_cookie structure. Instead use the last element peer_init which
is a zero-sized array as the offset.

diff -Nru a/net/sctp/associola.c b/net/sctp/associola.c
--- a/net/sctp/associola.c      Fri May  7 14:37:34 2004
+++ b/net/sctp/associola.c      Fri May  7 14:37:34 2004
@@ -1195,7 +1195,7 @@
 {
        int var_size2 = ntohs(cookie->peer_init->chunk_hdr.length);
        int var_size3 = cookie->raw_addr_list_len;
-       __u8 *raw = (__u8 *)cookie + sizeof(struct sctp_cookie) + var_size2;
+       __u8 *raw = (__u8 *)cookie->peer_init + var_size2;

        return sctp_raw_to_bind_addrs(&asoc->base.bind_addr, raw, var_size3,
                                      asoc->ep->base.bind_addr.port, gfp);
