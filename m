From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Excessive IPI interrupts with single RX queue devices and
 rps_cpus mask set
Date: Thu, 19 Dec 2013 17:30:54 -0800
Message-ID: <1387503054.19078.405.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAGVrzcawQhyMXw+_0394OJ=UfiN1Lyxf+JThYPbWrJM6LSZ-WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, therbert@google.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:43601 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756516Ab3LTBa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 20:30:56 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so1855249pdj.31
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 17:30:56 -0800 (PST)
In-Reply-To: <CAGVrzcawQhyMXw+_0394OJ=UfiN1Lyxf+JThYPbWrJM6LSZ-WA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 17:12 -0800, Florian Fainelli wrote:
> Hello,
> 
> After configuring the rps_cpus mask to enable all CPUs for a single RX
> queue network device, I noticed that I was getting one interrupt per
> packet received, with the interrupt count being splitted between NAPI
> interrupts and IPI SMP interrupts.
> 
> This behavior was observed on 3.8.13 as well as 3.3. The host was
> receiving a Gigabit UDP stream and the receiver was not consuming the
> SKBs. Whenever there was a listener consuming the SKBs received, the
> number of IPI/sec quickly jumped to about 4 times the number without a
> rps_cpus mask.
> 
> Shall we prevent the rps_cpu mask to be set at all for single RX queue
> devices since this seems to causes excessive IPI interrupts?

Not sure what you mean.

This is the thing that highly depends on workload.

(Most workloads perform better without RPS/RFS)

This is why it is disabled by default.
