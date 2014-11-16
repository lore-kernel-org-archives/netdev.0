From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pkt_sched: Fix qdisc len in qdisc_peek_dequeued() [61c9eaf9008]
 - question
Date: Sun, 16 Nov 2014 10:15:25 -0800
Message-ID: <1416161725.17262.92.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5468A0C5.9010409@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:37673 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbaKPSPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 13:15:24 -0500
Received: by mail-ie0-f181.google.com with SMTP id tp5so1166205ieb.12
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 10:15:23 -0800 (PST)
In-Reply-To: <5468A0C5.9010409@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-16 at 14:04 +0100, Michal Soltys wrote:
> Hi,
> 
> I was wondering (probably missing some subtleties) about that particular 
> patch, namely:
> 
> 61c9eaf90081cbe6dc4f389e0056bff76eca19ec
> 
> Why would that qlen++ change be necessary ? As far as peeked qdisc sees 
> things, the packet is already deqeued and gone - so not really part of 
> the queue anymore in this context (not ever requeued either). More 
> advanced qdiscs such as say fq_codel - if for example they decide to 
> drop head during further enqueue operation - obviously won't even 
> consider the peeked packet.

peeked packet has not to be considered by qdisc : Their dequeue()
methods is called only when there is no more peeked packet.

> 
> Increasing qlen from what I can see artificially shortens queue by 1. 
> For some classful schedulers (say like hfsc that instantly peeks next 
> packet length after dequeuing), child qdiscs will be almost all the time 
> formally operating at queue size decreased by 1.

Well, the peeked packet is part of the queue, as it is not yet
transmitted.
