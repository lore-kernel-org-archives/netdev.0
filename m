From: Eric Wheeler <netdev@lists.ewheeler.net>
Subject: Re: [PATCH net] bna: page allocation during interrupts to use a
 mempool.
Date: Mon, 6 Oct 2014 20:05:39 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1410061956410.7392@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>  <20140929092833.6c2cb7e9@urahara>  <262CB373A6D1F14F9B81E82F74F77D5A4704FAE7@avmb2.qlogic.org>  <alpine.DEB.2.00.1410061850120.5129@ware.dreamhost.com>
 <1412646735.11091.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from homie.mail.dreamhost.com ([208.97.132.208]:51760 "EHLO
	homiemail-a4.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751720AbaJGCuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 22:50:17 -0400
In-Reply-To: <1412646735.11091.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Oct 2014, Eric Dumazet wrote:
> On Mon, 2014-10-06 at 18:57 -0700, Eric Wheeler wrote:
>> This patch fixes an order:2 memory allocation error backtrace by
>> guaranteeing that memory is available during simultaneous high memory
>> pressure and packet rates when using 9k jumbo frames.
>
> This is highly suspect to me.
> Most likely yet another truesize lie.
> At a first glance, bnad_cq_setup_skb_frags() is buggy here :
> skb->truesize += totlen;

skb->truesize wasn't part of my patch, can you explain in more detail what 
you suggest a better fix might be? If you write a quick patch I can test 
it.

The patch in question implements a simple mempool for the interrupt page 
allocs---which definitely fixes the problem even if a better solution 
might exist.  I have no problem giving up a small amount of memory to 
guarantee page allocs in the interrupt handler.

It would be great to see this patch pushed through since it does fix the 
problem---at least until we can come up with a better fix.  I'm happy to 
test if you can send a patch.

-Eric

>
> With this kind of lies, system can OOM very fast.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
