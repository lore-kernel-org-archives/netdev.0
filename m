From: Edgar E Iglesias <edgar.iglesias@axis.com>
Subject: ipv4 ipsec
Date: Wed, 1 Jun 2005 00:47:17 +0200
Message-ID: <20050531224717.GE4068@edgar.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Im not sure this is the correct list for ipsec issues, but shouldn't
the size check at the bottom of net/ipv4/esp4.c be the other way
around (2.6.11)?

static int __init esp4_init(void)
{
        struct xfrm_decap_state decap;

        if (sizeof(struct esp_decap_data)  <
            sizeof(decap.decap_data)) {
                extern void decap_data_too_small(void);

                decap_data_too_small();
        }

decap.decap_data should hold an opaque type for the implementation
specific decap state, so I guess it should be the bigger of the
two.

Best regards
-- 
        Programmer
        Edgar E Iglesias <edgar@axis.com> 46.46.272.1946

% diff -bu /usr/src/linux-2.6.11-gentoo-r8/net/ipv4/esp4.c esp4.c
--- /usr/src/linux-2.6.11-gentoo-r8/net/ipv4/esp4.c     2005-05-11 10:05:03.000000000 +0200
+++ esp4.c      2005-06-01 00:38:55.000000000 +0200
@@ -480,7 +480,7 @@
 {
        struct xfrm_decap_state decap;
 
-       if (sizeof(struct esp_decap_data)  <
+       if (sizeof(struct esp_decap_data)  >
            sizeof(decap.decap_data)) {
                extern void decap_data_too_small(void);
 
