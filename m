From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 06:33:09 -0400
Message-ID: <1206700389.4429.34.camel@localhost>
References: <47EC3182.7080005@sun.com>
	 <20080327.170235.53674739.davem@davemloft.net> <47EC399E.90804@sun.com>
	 <20080327.173418.18777696.davem@davemloft.net>
	 <20080328012234.GA20465@gondor.apana.org.au>  <47EC50BA.6080908@sun.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.250]:57538 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982AbYC1KdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 06:33:24 -0400
Received: by ag-out-0708.google.com with SMTP id 35so8733922aga.10
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 03:33:21 -0700 (PDT)
In-Reply-To: <47EC50BA.6080908@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-27-03 at 18:58 -0700, Matheos Worku wrote:

> In general, while the TX serialization  improves performance in terms to 
> lock contention, wouldn't it reduce throughput since only one guy is 
> doing the actual TX at any given time.  Wondering if it would be 
> worthwhile to have an  enable/disable option specially for multi queue TX.

Empirical evidence so far says at some point the bottleneck is going to
be the wire i.e modern CPUs are "fast enough" that sooner than later
they will fill up the DMA ring of transmitting driver and go back to
doing other things. 
It is hard to create the condition you seem to have come across. I had
access to a dual core opteron but found it very hard with parallel UDP
sessions to keep the TX CPU locked in that region (while the other 3
were busy pumping packets). My folly could have been that i had a Gige
wire and maybe a 10G would have recreated the condition. 
If you can reproduce this at will, can you try to reduce the number of
sending TX u/iperfs and see when it begins to happen?
Are all the iperfs destined out of the same netdevice?

[Typically the TX path on the driver side is inefficient either because
of coding (ex: unnecessary locks) or expensive IO. But this has not
mattered much thus far (given fast enough CPUs).
It all could be improved by reducing the per packet operations the
driver incurs -  as an example, the CPU (to the driver) could batch a
set of packet to the device then kick the device DMA once for the batch
etc.]

cheers,
jamal

