From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 0/4] tcp: fix problems when tcp_fin_timeout is greater
 than 60
Date: Mon, 18 Mar 2013 21:36:03 +0900
Message-ID: <1363610163.7121.2.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:37037 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab3CRMgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 08:36:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is resubmission of the patch set that fixes problems when
tcp_fin_timeout is greater than 60.

- fix too short FIN_WAIT2 timer when tcp_fin_timeout is between 60
  and 120.
- fix FIN_WAIT2 timer expression in /proc/net/tcp and inet_diag when
  tcp_fin_timeout is greater than 60.

v2:
 - Separated changes of indentation to another patch.
 - Revised the comment of the patch modifying the expression of
   /proc/net/tcp to explain the reason for change.
 - Modified inet_diag.

Toshiaki Makita (4):
  tcp: fix too short FIN_WAIT2 time out
  tcp: fix FIN_WAIT2 timer expression in /proc/net/tcp
  tcp: fix the indentation in timer calculation of /proc/net/tcp
  inet_diag: fix FIN_WAIT2 timer expression in inet_diag

 include/linux/inet_diag.h |    2 ++
 net/dccp/diag.c           |   15 +++++++++++++++
 net/ipv4/inet_diag.c      |   20 --------------------
 net/ipv4/tcp_diag.c       |   27 +++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c       |   23 +++++++++++++++--------
 net/ipv4/tcp_timer.c      |    8 ++------
 net/ipv6/tcp_ipv6.c       |   23 +++++++++++++++--------
 7 files changed, 76 insertions(+), 42 deletions(-)

-- 
1.7.10.4
