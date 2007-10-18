From: "Matthew Faulkner" <matthew.faulkner@gmail.com>
Subject: Throughput Bug?
Date: Thu, 18 Oct 2007 16:54:35 +0100
Message-ID: <c565abbb0710180854j6f2f756sdd390161bafd1c4a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:25067 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756413AbXJRPyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 11:54:36 -0400
Received: by py-out-1112.google.com with SMTP id u77so394926pyb
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2007 08:54:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey all

I'm using netperf to perform TCP throughput tests via the localhost
interface. This is being done on a SMP machine. I'm forcing the
netperf server and client to run on the same core. However, for any
packet sizes below 523 the throughput is much lower compared to the
throughput when the packet sizes are greater than 524.

Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    MBytes  /s  % S      % S      us/KB   us/KB
 65536  65536    523    30.01        81.49   50.00    50.00    11.984  11.984
 65536  65536    524    30.01       460.61   49.99    49.99    2.120   2.120

The chances are i'm being stupid and there is an obvious reason for
this, but when i put  the server and client on different cores i don't
see this effect.

Any help explaining this will be greatly appreciated.

Machine details:

Linux 2.6.22-2-amd64 #1 SMP Thu Aug 30 23:43:59 UTC 2007 x86_64 GNU/Linux

sched_affinity is used by netperf internally to set the core affinity.

I tried this on 2.6.18 and i got the same problem!
