From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPv6 Extension Headers with UDP
Date: Fri, 16 Apr 2004 19:36:15 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416.193615.62247078.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, takamiya@po.ntts.co.jp, usagi-core@linux-ipv6.org,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

D: Fix SEGV when sending UDPv6 with extension headers using ancillary data. (fix is based on patch from <takamiya@po.ntts.co.jp>)

Thanks.

--yoshfuji

===== net/ipv6/udp.c 1.60 vs edited =====
--- 1.60/net/ipv6/udp.c	Wed Feb 25 17:17:45 2004
+++ edited/net/ipv6/udp.c	Fri Apr 16 19:23:38 2004
@@ -913,6 +913,7 @@
 	if (msg->msg_controllen) {
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
+		opt->tot_len = sizeof(*opt);
 
 		err = datagram_send_ctl(msg, fl, opt, &hlimit);
 		if (err < 0) {

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
