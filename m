From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: fedora 14 kernel performance with ip forwarding workload
Date: Wed, 6 Apr 2011 11:51:06 -0700
Message-ID: <BANLkTikZfp_GLyNRufAzqv3Yeb5d12BPDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	NetDEV list <netdev@vger.kernel.org>
To: fedora-kernel-list@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50286 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756518Ab1DFSvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 14:51:08 -0400
Received: by bwz15 with SMTP id 15so1403366bwz.19
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 11:51:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The other day I was running the stock fedora kernel on my ip
forwarding setup, to see what the performance was, and the performance
wasn't very good.

system is S5520HC dual socket 2.93GHz Xeon 5570 (Nehalem) with 3 quad
port 82580 adapters (12 ports).  Traffic is bidirectional 64 byte
packets being forwarded and received on each port, basically port to
port routing.  I am only using 12 flows currently.

The driver is igb, and I am using an affinity script that lines up
each pair of ports that are forwarding traffic into optimal
configurations for cache locality.  I am also disabling
remote_node_defrag_ratio to stop cross node traffic.

With the fedora default kernel from F14 it appears that
CONFIG_NETFILTER=y means that I cannot unload all of netfilter even if
I stop iptables service.

perf showed netfilter being prominent, and removing it gives me much
higher throughput.  Is there a reason CONFIG_NETFILTER=y ?  Isn't it a
good thing to be able to disable netfilter if you want to?

Jesse
