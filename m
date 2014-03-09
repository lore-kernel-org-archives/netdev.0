From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are
 enabled
Date: Sat, 08 Mar 2014 19:29:14 -0800
Message-ID: <1394335754.20149.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	 <1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAG+wggaUHeD5Vm_HF9m4+1SZZOUo_GeQroM+0kyA_qTC5c8=3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: Ming Chen <v.mingchen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:65491 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbaCID3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 22:29:16 -0500
Received: by mail-pb0-f46.google.com with SMTP id rq2so5792573pbb.19
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 19:29:16 -0800 (PST)
In-Reply-To: <CAG+wggaUHeD5Vm_HF9m4+1SZZOUo_GeQroM+0kyA_qTC5c8=3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-03-08 at 19:30 -0500, Ming Chen wrote:
> Hi Eric,
> 
> Thanks for the suggestion. I believe "tc qdisc replace dev eth0 root
> fq" can achieve fairness if we have only one queue. My understanding
> is that we cannot directly apply FQ to a multiqueue devices, isn't it?
> If we apply FQ separately to each tx queue, then what if we have one
> flow (fl-0) in tx-0, but two flows (fl-1 and fl-2) in tx-1? With FQ,
> the two flows in tx-1 should get the same bandwidth. But how about
> fl-0 and fl-1?

You do not need multiqueue to send traffic for few TCP flows, because
packets will reach 64KB size very fast.

If you want fairness, then multiqueue wont do it, unless you add some
kind of shaper.

TCP is handling one flow, not an arbitrary number of flows.

If you need fairness, then you need an AQM like FQ.
