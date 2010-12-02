From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: RFS configuration questions
Date: Thu, 2 Dec 2010 15:16:02 -0600
Message-ID: <20101202211602.GA2775@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: therbert@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:51373 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754095Ab0LBVQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 16:16:10 -0500
Received: by mail-vw0-f46.google.com with SMTP id 16so1379664vws.19
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 13:16:09 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been playing around with RPS/RFS on my multiqueue 10g Chelsio NIC
and I've got some questions about configuring RFS.

I've enabled RPS with:

for x in $(seq 0 7); do
    echo FFFFFFFF,FFFFFFFF > /sys/class/net/vlan816/queues/rx-${x}/rps_cpus
done

This appears to work when I watch 'mpstat -P ALL 1' as I can see the
softirq load is now getting distributed across all of the CPUs instead
of just the four (the card is a two port card and assigns four queues
per port) original hw receive queues which I have bound to CPUs
0-3.

To enable RFS I've run:

echo 16384 > /proc/sys/net/core/rps_sock_flow_entries

Is there any explanation of what this sysctl actually does?  Is this
the max number of sockets/flows that the kernel can steer?  Is this a
system wide max, a per interface max, or a per receive queue max?

Next I ran:

for x in $(seq 0 7); do
    echo 16384 > /sys/class/net/vlan816/queues/rx-${x}/rps_flow_cnt
done

Is this correct?  Is these the max number of sockets/flows that can be
steered per receive queue?  Does the sum of these values need to add
up to rps_sock_flow_entries (I also tried 2048)? Is this all that is
needed to enable RFS?

With these settings I can watch 'mpstat -P ALL 1' and it doesn't
appear RFS has changed the softirq load.  To get a better idea if it
was working I used taskset to bind my receiving processes to a set of
cores, yet mpstat still shows the softirq load getting distributed
across all cores, not just the ones where my receiving processes are
bound.  Is there a better way to determine if RFS is actually working?
Have I configured RFS incorrectly?

Thanks,
Shawn
