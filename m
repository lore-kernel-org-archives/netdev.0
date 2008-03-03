From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: [PATCH] Removing unneeded statement from tcp_ipv4.c
Date: Mon, 03 Mar 2008 14:23:38 +0100
Message-ID: <47CBFBDA.7000801@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755335AbYCCNWr@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid setting tstamp_ok because this is done two lines later anyway.

Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 00156bf..a28c4c2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1302,15 +1302,14 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
                tmp_opt.saw_tstamp = 0;
        }

-       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
+       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval)
                /* Some OSes (unknown ones, but I see them on web server, which
                 * contains information interesting only for windows'
                 * users) do not send their stamp in SYN. It is easy case.
                 * We simply do not advertise TS support.
                 */
                tmp_opt.saw_tstamp = 0;
-               tmp_opt.tstamp_ok  = 0;
-       }
+
        tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;

        tcp_openreq_init(req, &tmp_opt, skb);
