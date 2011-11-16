From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: report ecnseen
Date: Wed, 16 Nov 2011 18:59:06 +0100
Message-ID: <1321466346.4182.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110916103031.7f22b35f@nehalam.linuxnetplumber.net>
	 <20111011165908.0d6ed7de@nehalam.linuxnetplumber.net>
	 <1318389501.3686.8.camel@edumazet-laptop>
	 <1321419087.32381.3.camel@edumazet-laptop>
	 <20111116094550.61b73eee@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42011 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762Ab1KPR7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 12:59:11 -0500
Received: by wyh11 with SMTP id 11so832496wyh.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 09:59:09 -0800 (PST)
In-Reply-To: <20111116094550.61b73eee@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 novembre 2011 =C3=A0 09:45 -0800, Stephen Hemminger a =C3=
=A9crit :

> Please use same name as include/linux/tcp.h TCPI_OPT_ECN_SEEN
> Also, need to get this to glibc to make it included in standard distr=
o
> headers.

Thanks, I'll take care of glibc headers as well.

[PATCH iproute2] ss: report ecnseen

Support ECNSEEN reporting in ss command.

ESTAB      0      0           10.170.73.123:4900
10.170.73.125:51001    uid:501 ino:385994 sk:f31e5f00
         mem:(r0,w0,f0,t0) ts sack ecn ecnseen bic wscale:8,8 rto:210
rtt:18.75/15 ato:40 cwnd:10 send 69.9Mbps rcv_space:32768

"ecn" means TCP session negociated ECN capability (TCP layer) at setup
time

"ecnseen" at least one frame with ECT(0) or ECT(1) or ECN (IP layer) wa=
s
received from peer.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/netinet/tcp.h |    1 +
 misc/ss.c             |    2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/netinet/tcp.h b/include/netinet/tcp.h
index 282b29c..3f890a1 100644
--- a/include/netinet/tcp.h
+++ b/include/netinet/tcp.h
@@ -172,6 +172,7 @@ enum
 # define TCPI_OPT_SACK		2
 # define TCPI_OPT_WSCALE	4
 # define TCPI_OPT_ECN		8
+# define TCPI_OPT_ECN_SEEN	16
=20
 /* Values for tcpi_state.  */
 enum tcp_ca_state
diff --git a/misc/ss.c b/misc/ss.c
index b00841b..487154e 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1357,6 +1357,8 @@ static void tcp_show_info(const struct nlmsghdr *=
nlh, struct inet_diag_msg *r)
 				printf(" sack");
 			if (info->tcpi_options & TCPI_OPT_ECN)
 				printf(" ecn");
+			if (info->tcpi_options & TCPI_OPT_ECN_SEEN)
+				printf(" ecnseen");
 		}
=20
 		if (tb[INET_DIAG_CONG])
