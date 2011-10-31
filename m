From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC v2] tcp: Export TCP Delayed ACK parameters to user
Date: Mon, 31 Oct 2011 11:10:15 -0700
Message-ID: <4EAEE487.5080905@hp.com>
References: <CAEnQRZCxSPb8NRceB+tfdZnkN=K-jGbdmXDgNwEhZFYAWGmvAg@mail.gmail.com> <20111028.183107.2091450715774357523.davem@davemloft.net> <4EAB2F58.7080509@hp.com> <20111028.222430.1568567893138453593.davem@davemloft.net> <CAEnQRZCggUnoVZXyXfZ6-Om+hwQL_6Oo3dPODsXAH+iJYqN=jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org, luto@amacapital.net
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:24220 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933655Ab1JaSTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2011 14:19:19 -0400
In-Reply-To: <CAEnQRZCggUnoVZXyXfZ6-Om+hwQL_6Oo3dPODsXAH+iJYqN=jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whether tracked as bytes or segments, my take is that to ask 
applications to have to think about another non-portable socket option 
is ungood.  I would suggest taking the time to work-out the automagic 
heuristic to drop the deferred ACK count on connections where it being 
large is un-desirable and then not need to worry about the limits being 
global.

Given the stack's existing propensity to try to decide when to increase 
the window I might even go so far as to suggest the sense of the 
heuristic be flipped and it seek to decide when it is ok to increase the 
number of segments/bytes per ACK.  To what extent one needs to go beyond 
what happens already with the stretching of ACKs via GRO/LRO or if that 
mechanism can serve as part of the logic of the heuristic is probably a 
fertile area for discussion.

If I recall correctly, in one of your earlier posts you mentioned 
something about a 20% performance boost.  What were the specific 
conditions of that testing?  Was it over a setup where the receiver 
already had LRO/GRO or was it over a more plain receiver NIC without 
that functionality?

rick jones
