From: Ming Chen <v.mingchen@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are enabled
Date: Sun, 9 Mar 2014 01:43:32 -0500
Message-ID: <CAG+wggY=5BWaDujaiP6hnD5vTsXiOBNqBDYnqjEW_F4fdaMOyw@mail.gmail.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	<1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAG+wggaUHeD5Vm_HF9m4+1SZZOUo_GeQroM+0kyA_qTC5c8=3Q@mail.gmail.com>
	<1394335754.20149.73.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:64475 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbaCIGnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 01:43:33 -0500
Received: by mail-ig0-f170.google.com with SMTP id uq10so6024764igb.1
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 22:43:33 -0800 (PST)
In-Reply-To: <1394335754.20149.73.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 8, 2014 at 10:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> You do not need multiqueue to send traffic for few TCP flows, because
> packets will reach 64KB size very fast.

I am trying to experiment using only one queue for all the TCP flows.
But, how do we force that. I was thinking about XPS. But I just
realized that /sys/class/net/p3p1/queues/tx-n/xps_cpus only set which
CPUs can use them. How to let all CPUs choose one single tx queue? Or,
should I use mqprio and assign all flows to one tc that contains only
one tx queue?

>
> If you want fairness, then multiqueue wont do it, unless you add some
> kind of shaper.
>
> TCP is handling one flow, not an arbitrary number of flows.
>
> If you need fairness, then you need an AQM like FQ.
>

Yeah. You are right. However, if we really want fairness while using
mq, then should AQM and FQ be aware of mq or even the scheduling of
the queues?

Best,
Ming
