From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Requeues and ECN marking
Date: Mon, 03 Feb 2014 09:28:23 -0800
Message-ID: <1391448503.28432.101.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMvx-beWMC8awScfEtHs8sSkzz0fGNqBH1fn7hC=k0iaFpJvSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Greg Kuperman <gregk@MIT.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:58314 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbaBCR2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 12:28:25 -0500
Received: by mail-ie0-f175.google.com with SMTP id ar20so6487185iec.20
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 09:28:25 -0800 (PST)
In-Reply-To: <CAMvx-beWMC8awScfEtHs8sSkzz0fGNqBH1fn7hC=k0iaFpJvSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-03 at 09:50 -0500, Greg Kuperman wrote:
> Hi all,
> 
> I am testing a new congestion control protocol that relies on explicit
> congestion notifications (ECN) to notify the receiver of a congestion
> event. I have a rate limited link of 1 Mbps, and I am using the RED
> queuing discipline with ECN enabled. What I have noticed is that no
> matter how small I set my queue size, or how low I set my minimum
> marking level, the first ECN marked packet does not get sent out for
> about 10 seconds after the input rate exceeds the output rate. Further
> examination shows that ECN marking does not occur until the number or
> requeues hits 1000. Below are two queries of tc -s -d qdisc ls dev
> eth1.
> 
> qdisc red 8028: root refcnt 2 limit 10000000b min 1b max 0b ecn ewma
> 30 Plog 21 Scell_log 31
>  Sent 1307892 bytes 1247 pkt (dropped 0, overlimits 0 requeues 960)
>  backlog 1052118b 962p requeues 960
>   marked 0 early 0 pdrop 0 other 0
> 
> qdisc red 8028: root refcnt 2 limit 10000000b min 1b max 0b ecn ewma
> 30 Plog 21 Scell_log 31
>  Sent 1379262 bytes 1312 pkt (dropped 0, overlimits 72 requeues 1024)
>  backlog 1122468b 1027p requeues 1024
>   marked 72 early 0 pdrop 0 other 0
> 
> 
> The txqueuelen defaults to 1000 for the interface, so I figured that
> packets maybe buffering there, and then dequeuing, before any packets
> are marked. I set txqueuelen to lower values (all the way down to 1),
> but the exact same behavior occurs (no marked packets until number of
> dequeues hits 1000). In contrast, if I set txqueuele to something very
> high, I get no requeues, drops, or marked packets.
> 
> My goal is for packets to be marked as soon as the ingress rate
> exceeds the egress. Am I correct in thinking that the requeuing
> operation is the culprit? Can I eliminate requeues? Is there something
> else I can do to get the behavior I am looking for?
> 
> Thank you all for the help. And please cc me in your replies; I'm not
> 100% sure if I get all the messages from this mailing list.

requeues have nothing to do with ECN marking.

How is done your rate limiting ?

Post the whole setup, not part of it, it will help to spot the problem
in one go, instead of many mail exchanges.
