From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 10:37:29 +0200
Message-ID: <20140827103729.69551e29@redhat.com>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	<20140826082815.18034199@redhat.com>
	<20140826121347.0ec7f2ac@redhat.com>
	<20140826145225.6673ab3f@redhat.com>
	<53FCB944.9060904@intel.com>
	<20140827094859.65f4f0fc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com,
	Jeremy Eder <jeder@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085AbaH0Iho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 04:37:44 -0400
In-Reply-To: <20140827094859.65f4f0fc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Aug 2014 09:48:59 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> Reading Jeremy Eder's blog post:
>  http://www.breakage.org/2012/11/14/processor-max_cstate-intel_idle-max_cstate-and-devcpu_dma_latency/
> 
> It seems the best method for disabling these C and P states, and
> keeping all CPUs in C0/C1 state is doing:
> 
> # tuned-adm profile latency-performance
[...]
> I'm also going to disable Hyper-threading in BIOS, even-though I'm only
> using one CPU in these tests (I worry that some process running on a
> sibling could disturb the accuracy).

Disabling Hyper-Threading in BIOS helped the accuracy, now the latency
variation is below 0.1ns min:-0.031 and max:0.054 over 120 sec.

Still using:
 # tuned-adm profile latency-performance

> Setting:
>  * sudo ethtool -C eth5 rx-usecs 30
> Result:
>  * instant rx:1 tx:5603644 pps n:120 average: rx:0 tx:5603317 pps
>    (instant variation TX 0.010 ns (min:-0.132 max:0.114) RX 0.000 ns)
>  * instant rx:1 tx:5599820 pps n:300 average: rx:1 tx:5602382 pps
>    (instant variation TX -0.082 ns (min:-0.209 max:0.114) RX 0.000 ns)

With no HT:
 * instant rx:1 tx:5597616 pps n:120 average: rx:1 tx:5596283 pps
  (instant variation TX 0.043 ns (min:-0.031 max:0.054) RX 0.000 ns)

With this setup, I think we are ready to measure the effect of our API
changes with sufficient accuracy.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
