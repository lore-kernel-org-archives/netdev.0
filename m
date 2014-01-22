From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG] null pointer dereference in tcp_gso_segment()
Date: Wed, 22 Jan 2014 23:02:49 +0100
Message-ID: <8761pb7jzq.fsf@natisbad.org>
References: <87r47z7kqo.fsf@natisbad.org>
	<1390427824.27806.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Willy Tarreau <w@1wt.eu>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:45418 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751784AbaAVWDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 17:03:10 -0500
Received: from smtp.natisbad.org (unknown [IPv6:2a01:e35:139b:9f90:221:70ff:fe55:8f78])
	by smtp2-g21.free.fr (Postfix) with ESMTP id 79FB54B001B
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 23:02:59 +0100 (CET)
In-Reply-To: <1390427824.27806.36.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 22 Jan 2014 13:57:04 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Eric Dumazet <eric.dumazet@gmail.com> writes:

>> Unless there is an assumption I missed somewhere in the function, the
>> problem may occur during the first round of the loop, because (unlike
>> the 'while' condition does at line 21) skb->next is not checked against
>> null at lines 17 above before it is passed to tcp_hdr() at line 18.
>> 
>> To be honest, I am asking because I am not familiar w/ the code and it
>> is somewhat old so I wonder why noone got hit before. AFAICT,
>> f4c50d990dcf ([NET]: Add software TSOv4) added TSOv4 support in 2006 via
>> introduction of tcp_tso_segmen() (with the same kind of deref but
>> possibly different assumptions) which was more recently modified via
>> 28850dc7c7 (net: tcp: move GRO/GSO functions to tcp_offload) to become
>> tcp_gso_segment().
>> 
>> David, can you confirm the analysis and possibly comment on the
>> conditions needed for the bug to manifest?
>
> A gso packet contains at least 2 segments.

By whom / where is it enforced?

Cheers,

a+
