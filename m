From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] act_cpu: redirect skb receiving to a special CPU.
Date: Sat, 05 Jun 2010 09:07:04 -0400
Message-ID: <1275743224.3490.44.camel@bigi>
References: <AANLkTikskTWJrULj2IKYhebxh9O_XTOMBy3i0wPY8thq@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:43557 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933319Ab0FENHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 09:07:08 -0400
Received: by vws5 with SMTP id 5so994191vws.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 06:07:07 -0700 (PDT)
In-Reply-To: <AANLkTikskTWJrULj2IKYhebxh9O_XTOMBy3i0wPY8thq@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli,

I like the idea..

My preference would be to not change ingress qdisc to have queues.
The cpuid should be sufficient to map to a remote cpu queue, no?
Now, if you could represent each cpu as a netdevice, then we wouldnt
need any change;-> And we could have multiple types of ways to redirect
to cpus instead of just doing IPIs - example, ive always thought of 
sending over something like HT (I think it would be a lot cheaper).

I didnt queit understand the map OFFSET part. is this part of rfs?

cheers,
jamal

On Sat, 2010-06-05 at 18:56 +0800, Changli Gao wrote:
> I am going to implement a CPU action, which can be used with ingress
> qdisc to redirect skb receiving to a special cpu. It is much like RPS,
> but more flexible:
> 
> * choose the hash function with the help of cls_flow.c
> * pin special traffic to a dedicate CPU
> * weighted packets distributing
> 
> act_cpu will use the function enqueue_to_backlog() supplied by RPS to
> redirect skb receiving, and have two kind paramter:
> 
> * cpu CPUID - the ID of CPU, which handles this traffic
> * map OFFSET - map the mirror class ID to CPUID: CPUID = mirror class ID + CPUID
> 
> sch_ingress will be enhanced to support class tree.
> 

