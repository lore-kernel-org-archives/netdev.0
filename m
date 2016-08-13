From: Piotr Jurkiewicz <piotr.jerzy.jurkiewicz@gmail.com>
Subject: Issues related to TCP Fast Open flags: TFO_SERVER_COOKIE_NOT_CHKED
 and TFO_SERVER_WO_SOCKOPT2
Date: Sun, 14 Aug 2016 01:05:38 +0200
Message-ID: <58f77827-c57c-0602-255f-a76fdd3cd472@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34820 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbcHNKQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 06:16:02 -0400
Received: by mail-wm0-f50.google.com with SMTP id f65so46849743wmi.0
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 03:16:01 -0700 (PDT)
Received: from [192.168.1.100] (static-202-152.is.net.pl. [217.144.202.152])
        by smtp.googlemail.com with ESMTPSA id q36sm2051489lfi.26.2016.08.13.16.05.38
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Aug 2016 16:05:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Handling of TFO_SERVER_COOKIE_NOT_CHKED flag was removed back in 2014, but this flag is still mentioned in the documentation:

Documentation/networking/ip-sysctl.txt:
	0x100: Accept SYN data w/o validating the cookie.

2. There is no explanation how TFO_SERVER_WO_SOCKOPT1 and TFO_SERVER_WO_SOCKOPT2 differ, the docs only say:

Documentation/networking/ip-sysctl.txt:
	0x400/0x800: Enable Fast Open on all listeners regardless of the
	   TCP_FASTOPEN socket option. The two different flags designate two
	   different ways of setting max_qlen without the TCP_FASTOPEN socket
	   option.

3. When TFO_SERVER_WO_SOCKOPT2 flag is set, the fastopenq.max_qlen is set to the value of sysctl bitmap containing flags (sysctl_tcp_fastopen), what is (at least for me) completely irrational and I believe is a bug:

net/ipv4/af_inet.c:
225                         else if ((sysctl_tcp_fastopen &
226                                   TFO_SERVER_WO_SOCKOPT2) != 0)
227                                 fastopen_queue_tune(sk,
228                                     ((uint)sysctl_tcp_fastopen) >> 16);
