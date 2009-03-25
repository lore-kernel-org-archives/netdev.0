From: Adam Richter <adam_richter2004@yahoo.com>
Subject: Re: 2.6.29 forcedeth hang W/O NAPI enabled
Date: Wed, 25 Mar 2009 16:24:47 -0700 (PDT)
Message-ID: <774003.62326.qm@web57708.mail.re3.yahoo.com>
Reply-To: adam_richter2004@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: berkley@cs.wustl.edu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web57708.mail.re3.yahoo.com ([68.142.236.71]:42004 "HELO
	web57708.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752893AbZCYXb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 19:31:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	I am experiencing what is probably the same forcedeth ethernet
hang with FORCEDETH_NAPI disabled as reported by Berkley Shands.  I
want to add the following additional data (items 2-7 basically just
confirm what one would expect):

	1) I can narrow where the problem was introduced.  The problem
	   does not occur for me in 2.6.29-rc8-git6, the last git snapshot
	   before 2.6.29.  There are no changes to forcedeth.c between
	   these versions.

	2) The amount of time it takes to reproduce the problem seems
	   to depend on networking utilization.  I can reproduce the
	   problem in about 30 seconds by doing "ping -f" to a
	   computer on my local ethernet for about one minute.
	   Otherwise, my computer, which normally does not do much
	   network communication takes about an hour to exhibit the
	   problem.

	3) I can recover by doing "rmmod forcedeth ; modprobe forcedeth"
	   even without recompiling with NAPI enabled, but the
	   problem seems to recur more quickly, until reloading the
	   forcedeth module no longer seems to work.  (I infer from
	   Berkley Shands' message that reloading the module
	   recompiled with NAPI enabled will cause the problem not
	   to recur.)

	4) Given that this looks like a NAPI problem, it should come
	   as no surprise that ethernet transmit still works when the
	   problem is occuring.  I know this because I can run ping
	   from the effected machine to a target machine running
	   tcpdump, and the target machine sees the ping packets.

	5) When the problem occurs, "ifconfig eth0" reports a gradually
	   increasing count of "RX packets" (I assume from random
	   broadcast packets originating elsewhere on the local
	   ethernet), and no obvious signs of trouble:
 
          RX packets:2092 errors:0 dropped:0 overruns:0 frame:0
          TX packets:34 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:177338 (173.1 KB)  TX bytes:6732 (6.5 KB)

	6) No complaints on the kernel console appear when
	   ethernet receive stops working.

	7) When the problem occurs, the other functions of the
	   computer apparently continue to work fine.  In particular,
	   I can reboot the computer from a user program without
	   incident.

	When I can find some time, I plan to try to narrow the problem
with git bisect, but that may not be today.

Adam Richter



      
