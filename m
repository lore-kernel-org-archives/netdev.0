From: zhou rui <zhourui.cn@gmail.com>
Subject: RPS will assign different smp_processor_id for the same packet?
Date: Thu, 21 Apr 2011 23:50:37 +0800
Message-ID: <BANLkTimvuGKYuiV_ngTo4wtqhNix4iMfmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39850 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123Ab1DUPuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 11:50:37 -0400
Received: by iyb14 with SMTP id 14so1494238iyb.19
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 08:50:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kernel 2.6.36.4
CONFIG_RPS=y but not set the cpu mask

/sys/class/net/eth1/queues/rx-0 # cat rps_cpus
00

register a hook func:
  prot_hook.func = packet_rcv;
  prot_hook.type = htons(ETH_P_ALL);
  dev_add_pack(&prot_hook);


replay the same traffic in very slow speed, printk the
smp_processor_id in packet_rcv():
first time:
cpu=4
cpu=3
cpu=6
cpu=7

second time:
cpu=7
cpu=1
cpu=5
cpu=2

is it normal?

thanks
rui
