From: Takashi Hibi <hibi665@oki.com>
Subject: About MLDv2 specification
Date: Mon, 21 Jun 2004 18:11:46 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040621181146.20bde98%hibi665@oki.com>
Mime-Version: 1.0
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

MLDv2 was now issued as RFC3810.
We found a small problem in the current implementation.
In 5.2.12 of RFC3810, there is a following statement.

      Value  Name and Meaning
      -----  ----------------
        1    MODE_IS_INCLUDE - indicates that the interface has a filter
             mode of INCLUDE for the specified multicast address.  The
             Source Address [i] fields in this Multicast Address Record
             contain the interface's source list for the specified
             multicast address.  A MODE_IS_INCLUDE Record is never sent
             with an empty source list.

The last part (A MODE_IS_INCLUDE Record is ...) causes a problem.
This restriction is added since draft 7 of MLDv2.

The current implementation of MLDv2 sends MODE_IS_INCLUDE record with
an empty list after leaving multicast group.

I think that it can be fixed easily by:

--- linux-2.6.7/net/ipv6/mcast.c.orig   2004-05-10 11:33:13.000000000 +0900
+++ linux-2.6.7/net/ipv6/mcast.c        2004-06-16 19:43:35.000000000 +0900
@@ -1388,7 +1388,8 @@

        if (!*psf_list) {
                if (type == MLD2_ALLOW_NEW_SOURCES ||
-                   type == MLD2_BLOCK_OLD_SOURCES)
+                   type == MLD2_BLOCK_OLD_SOURCES ||
+                   type == MLD2_MODE_IS_INCLUDE)
                        return skb;
                if (pmc->mca_crcount || isquery) {
                        /* make sure we have room for group header and at



Regards,
Takashi Hibi
