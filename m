From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFC 12/12] nfp: bpf: add denser mode of execution
Date: Wed, 1 Jun 2016 23:47:23 +0100
Message-ID: <20160601234723.098ef2af@jkicinski-Precision-T1700>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
	<1464799814-4453-13-git-send-email-jakub.kicinski@netronome.com>
	<20160601220114.GC24671@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35214 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbcFAWr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 18:47:28 -0400
Received: by mail-wm0-f43.google.com with SMTP id a136so204013228wme.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 15:47:28 -0700 (PDT)
In-Reply-To: <20160601220114.GC24671@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Jun 2016 15:01:16 -0700, Alexei Starovoitov wrote:
> On Wed, Jun 01, 2016 at 05:50:14PM +0100, Jakub Kicinski wrote:
> > If BPF uses less than 7 registers programmable engines
> > can process twice as many packets in parallel.  Signal
> > this denser mode of operation to FW by setting the lowest
> > bit in DMA address of the machine code buffer.
> > 
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> > Reviewed-by: Simon Horman <simon.horman@netronome.com>  
> 
> wow. that sounds pretty cool.
> I was about to ask whether we can help HW to be more efficient
> by doing something on bpf side like annotating the registers or
> adding 'hw_only' registers...
> but looks like less registers is actually good, since NFP jit
> can parallelize it? Truly wow.
> if you can share the hw architecture details and explain more
> on how this 'dense_mode' works, would be awesome.
 
I think the best resource of information about the card and its
internals would be the open-nfp website [1].  Regarding optimizations
there are definitely things which could be done.  The most obvious is 
helping 32bit JITs in general.  Annotations which registers are
32bit-only, which operations need zero-extending etc.  There is some
state in the verifier that would be useful here as well.  Knowing which
registers contain the skb pointer for instance would help to ignore any
operations on them (since as exemplified by simple optimization in
patch 10 the skb pointer has no meaning for the HW).  I'm sure more
such things will come up with time.

[1] http://open-nfp.org/resources/
