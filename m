From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 09:49:13 -0400
Message-ID: <1271425753.4606.65.camel@bigi>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <k2h412e6f7f1004160634v88440075p6e4cb2404abdb006@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:37943 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757571Ab0DPNtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 09:49:14 -0400
Received: by qw-out-2122.google.com with SMTP id 8so829595qwh.37
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 06:49:13 -0700 (PDT)
In-Reply-To: <k2h412e6f7f1004160634v88440075p6e4cb2404abdb006@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-04-16 at 21:34 +0800, Changli Gao wrote:

> 
> +	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
>  		   s->total, s->dropped, s->time_squeeze, 0,
>  		   0, 0, 0, 0, /* was fastroute */
> -		   s->cpu_collision, s->received_rps);
> +		   s->cpu_collision, s->received_rps, s->ipi_rps);
> 
> Do you mean that received_rps is equal to ipi_rps? received_rps is the
> number of IPI used by RPS. And ipi_rps is the number of IPIs sent by
> function generic_exec_single(). If there isn't other user of
> generic_exec_single(), received_rps should be equal to ipi_rps.
> 

my observation is:
s->total is the sum of all packets received by cpu (some directly from
ethernet)
s->received_rps was what the count receiver cpu saw incoming if they
were sent by another cpu. 
s-> ipi_rps is the times we tried to enq to remote cpu but found it to
be empty and had to send an IPI. 
ipi_rps can be < received_rps if we receive > 1 packet without
generating an IPI. What did i miss?

cheers,
jamal

