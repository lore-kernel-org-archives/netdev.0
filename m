From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 08:29:33 -0700
Message-ID: <1412954973.9362.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>
		<20141010035840.21428.359.stgit@ahduyck-workstation.home>
	 <20141010.004708.1975127853551765914.davem@davemloft.net>
	 <5437F072.5060502@redhat.com>
	 <063D6719AE5E284EB5DD2968C1650D6D174C858B@AcuExch.aculab.com>
	 <5437F7CB.5010101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:59843 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236AbaJJP3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 11:29:35 -0400
Received: by mail-pa0-f41.google.com with SMTP id eu11so1958673pac.0
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 08:29:34 -0700 (PDT)
In-Reply-To: <5437F7CB.5010101@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-10 at 08:14 -0700, Alexander Duyck wrote:

> I think you might be coming to this a little late.  The igb and ixgbe 
> drivers had been working this way for a long time.  We did a memcpy to 
> move the headers from the page and into the skb->data at an aligned 
> offset.  In order to determine the length to memcpy we had a function 
> that could walk through the DMA aligned data to get the header length.  
> The function for that was replaced with the __skb_flow_dissect as it was 
> considered a duplication of code with the flow_dissection functions.  
> However that is obviously not the case now that we are hitting these 
> alignment issues.
> 
> The question I have in all this is do I push forward and make 
> __skb_flow_dissect work with unaligned accesses, or do I back off and 
> put something equivilent to igb/ixgbe_get_headlen functions in the 
> kernel in order to deal with the unaligned accesses as they had no 
> issues with them since they were only concerned with getting the header 
> length and kept all accesses 16b aligned.
> 

I see nothing wrong dealing with unaligned accesses, as these helpers
are nop on x86 or CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y arches.
