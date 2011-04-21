From: zhou rui <zhourui.cn@gmail.com>
Subject: automatically decrease sender throughput when network traffic is heavy?
Date: Thu, 21 Apr 2011 14:50:00 +0800
Message-ID: <BANLkTi=fJ=R8_odPA2NAcjf-dsA+9nihkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:55281 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428Ab1DUGuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 02:50:01 -0400
Received: by qyk7 with SMTP id 7so2652952qyk.19
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 23:50:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi
meet a strange situation:

usually throughput between sender(tcpreplay)  ->  receiver(my app) is
about 800~900Mbps(different machine,1G nic)

my kernel module will do a complicated work when it receive a packet,
I register a hook func like this:

 prot_hook.func = my_packet_rcv;
 prot_hook.type = htons(ETH_P_ALL);
 dev_add_pack(&prot_hook);

I suppose the nic driver will drop packets when traffic is heavy,
however, surprised that the sender throught is dreased to 500-600Mbps
why? what happened?

top - 14:00:46 up 5 days, 23:25,  3 users,  load average: 1.20, 0.44, 0.64
Tasks: 126 total,   5 running, 121 sleeping,   0 stopped,   0 zombie
Cpu(s):  1.9%us,  8.9%sy,  0.0%ni, 76.5%id,  0.0%wa,  0.0%hi, 12.6%si,  0.0%st
Mem:     16077M total,     3427M used,    12650M free,       87M buffers
Swap:     2055M total,        0M used,     2055M free,      850M cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
   25 root      20   0     0    0    0 R   98  0.0  10:33.29 ksoftirqd/6


the kernel is 2.6.36.4-0.7-default #5 SMP Thu Apr 14 15:37:53 SGT 2011
x86_64 x86_64 x86_64 GNU/Linux

before that same test was done on kernel 2.6.16 and no this problem seen

thanks
rui
