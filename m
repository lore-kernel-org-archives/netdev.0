From: "Meda, Prasanna" <pmeda@akamai.com>
Subject: rcv_wnd = init_cwnd*mss
Date: Wed, 27 Oct 2004 22:14:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <DB2C167D8FFDEA45B8FC0B1B75E3EE154A3B07@usca1ex-priv1.sanmateo.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>, <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


What is the reason for checking mss with 1<<rcv_wscale?
include/net/tcp.h:
static inline void tcp_select_initial_window(int __space, __u32 mss,
        __u32 *rcv_wnd,
        __u32 *window_clamp,
        int wscale_ok,
        __u8 *rcv_wscale)
{
.....
        /* Set initial window to value enough for senders,
         * following RFC1414. Senders, not following this RFC,
         * will be satisfied with 2.
         */
        if (mss > (1<<*rcv_wscale)) {
                int init_cwnd = 4;
                if (mss > 1460*3)
                        init_cwnd = 2;
                else if (mss > 1460)
                        init_cwnd = 3;
                if (*rcv_wnd > init_cwnd*mss)
                        *rcv_wnd = init_cwnd*mss;
        }
 ......
}
---------
Perhaps the motivation was checking for
     if (mss >  rcv_wnd * (1<<*rcv_wscale)) {



Thanks,
Prasanna.
