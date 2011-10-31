From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC v2] tcp: Export TCP Delayed ACK parameters to user
Date: Mon, 31 Oct 2011 14:29:30 -0700
Message-ID: <4EAF133A.2080505@hp.com>
References: <CAEnQRZCxSPb8NRceB+tfdZnkN=K-jGbdmXDgNwEhZFYAWGmvAg@mail.gmail.com> <20111028.183107.2091450715774357523.davem@davemloft.net> <4EAB2F58.7080509@hp.com> <20111028.222430.1568567893138453593.davem@davemloft.net> <CAEnQRZCggUnoVZXyXfZ6-Om+hwQL_6Oo3dPODsXAH+iJYqN=jw@mail.gmail.com> <4EAEE487.5080905@hp.com> <CAEnQRZAGc42q1LCEDs=QigLkXeHBui=KnAm5=5xrEzvA-LDcGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org, luto@amacapital.net
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:12054 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141Ab1JaV3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2011 17:29:34 -0400
In-Reply-To: <CAEnQRZAGc42q1LCEDs=QigLkXeHBui=KnAm5=5xrEzvA-LDcGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2011 01:02 PM, Daniel Baluta wrote:
> On Mon, Oct 31, 2011 at 8:10 PM, Rick Jones<rick.jones2@hp.com>  wrote:
>> Whether tracked as bytes or segments, my take is that to ask applications to
>> have to think about another non-portable socket option is ungood.  I would
>> suggest taking the time to work-out the automagic heuristic to drop the
>> deferred ACK count on connections where it being large is un-desirable and
>> then not need to worry about the limits being global.
>
> Your suggestion deserves further investigation, it looks tricky to
> find a good heuristic for increasing/decreasing the ACK deferred count.

Well, presumably you can observe the behaviour of some HP-UX and/or 
Solaris receivers to get some ideas.

>> If I recall correctly, in one of your earlier posts you mentioned something
>> about a 20% performance boost.  What were the specific conditions of that
>> testing?  Was it over a setup where the receiver already had LRO/GRO or was
>> it over a more plain receiver NIC without that functionality?
>
> If I remember correctly on the receiver side there was no LRO/GRO, but we
> tweaked some of /proc/sys/net/ipv4 parameters (e.g tcp_rmem).
> Also, the traffic was highly unidirectional with many clients feeding multimedia
> content to a server.
>
> Anyhow, we used our custom kernel which is an older kernel version.
> Are there any recommended benchmarks/tools for testing this kind of parameters?

Well, the last time I was tilting after the ACK avoidance windmill I 
used my favorite tool, netperf.  I believe I posted some HP-UX data 
showing the effect of different values of tcp_deferred_ack_max.  Both on 
throughput, and on CPU utilization/service demand.  Of course, I have 
something of a bias in that regard :)

rick jones
