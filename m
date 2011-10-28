From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] tcp: Export TCP Delayed ACK parameters to user
Date: Fri, 28 Oct 2011 09:38:52 -0700
Message-ID: <4EAADA9C.30306@hp.com>
References: <1319756841-2051-1-git-send-email-dbaluta@ixiacom.com> <1319760097.19125.55.camel@edumazet-laptop> <CAEnQRZAj4H9neNsGB8hkrQO5trvP8QimhKhpnwchjTVrAo2LGQ@mail.gmail.com> <1319791441.23112.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Baluta <daniel.baluta@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:41964 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932292Ab1J1Qiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 12:38:55 -0400
In-Reply-To: <1319791441.23112.80.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> On Solaris there is a global option tcp_deferred_acks_max [2],
>> which is similar with our tcp_delack_segs.
>>
>
> and also has tcp_deferred_ack_interval

And those have similar settings in HP-UX 11.X.

For the sake of completeness, the ACK avoidance heuristic in HP-UX, and 
I presume Solaris (as they share a common "Mentat" heritage) includes a 
mechanism to reduce the per-connection effective number of segments per 
ACKnowledgement.  I believe this is done to handle cases where the 
sender may have reduced her cwnd.  That would have deployment going back 
to 1997 in the case of HP-UX 11.0, and presumably a few years before 
that in the case of Solaris.  That mechanism in their ACK avoidance 
heuristics may be the reason neither have gone so far as to make the 
settings per-route or per-connection (though I could be wrong).  I 
believe that Solaris does though have two deferred ACK limits - one for 
perceived to be local connections and one (lower) for perceived to be 
remote connections.

There can be "fun" interactions with senders which increase cwnd per ACK 
rather than per bytes ACKed.

Still, I myself am somewhat fond of ACK avoidance heuristics.

rick jones

PS - when discussing the performance benefits of an ACK avoidance 
heuristic, feel free to use netperf and service demand numbers :)
