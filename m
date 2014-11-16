From: Michal Soltys <soltys@ziu.info>
Subject: pkt_sched: Fix qdisc len in qdisc_peek_dequeued() [61c9eaf9008] -
 question
Date: Sun, 16 Nov 2014 14:04:05 +0100
Message-ID: <5468A0C5.9010409@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:4594 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751938AbaKPNbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2014 08:31:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was wondering (probably missing some subtleties) about that particular 
patch, namely:

61c9eaf90081cbe6dc4f389e0056bff76eca19ec

Why would that qlen++ change be necessary ? As far as peeked qdisc sees 
things, the packet is already deqeued and gone - so not really part of 
the queue anymore in this context (not ever requeued either). More 
advanced qdiscs such as say fq_codel - if for example they decide to 
drop head during further enqueue operation - obviously won't even 
consider the peeked packet.

Increasing qlen from what I can see artificially shortens queue by 1. 
For some classful schedulers (say like hfsc that instantly peeks next 
packet length after dequeuing), child qdiscs will be almost all the time 
formally operating at queue size decreased by 1.
