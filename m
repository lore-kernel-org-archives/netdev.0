From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are
 enabled
Date: Sun, 09 Mar 2014 06:44:22 -0700
Message-ID: <1394372662.20149.92.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	 <1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAG+wggaUHeD5Vm_HF9m4+1SZZOUo_GeQroM+0kyA_qTC5c8=3Q@mail.gmail.com>
	 <1394335754.20149.73.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAG+wggY=5BWaDujaiP6hnD5vTsXiOBNqBDYnqjEW_F4fdaMOyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: Ming Chen <v.mingchen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:44331 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209AbaCINo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 09:44:26 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so6125504pad.21
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 06:44:25 -0700 (PDT)
In-Reply-To: <CAG+wggY=5BWaDujaiP6hnD5vTsXiOBNqBDYnqjEW_F4fdaMOyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-03-09 at 01:43 -0500, Ming Chen wrote:

> I am trying to experiment using only one queue for all the TCP flows.
> But, how do we force that. I was thinking about XPS. But I just
> realized that /sys/class/net/p3p1/queues/tx-n/xps_cpus only set which
> CPUs can use them. How to let all CPUs choose one single tx queue? Or,
> should I use mqprio and assign all flows to one tc that contains only
> one tx queue?

If you want to use a single queue, just declare a single queue on your
NIC...

ethtool -L eth0 rx 1 tx 1

Multiqueue is not a requirement in your case. You can easily reach line
rate with a single queue on a 10Gbe NIC.
