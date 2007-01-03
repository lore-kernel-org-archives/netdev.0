From: rbj2@njit.edu
Subject: Question regarding RED + ECN working
Date: Wed, 03 Jan 2007 17:39:37 -0500 (EST)
Message-ID: <1167863976.459c30a90611b@webmail.njit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: rbj2@njit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.njit.edu ([128.235.251.173]:63000 "EHLO mail-gw5.njit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932175AbXACXWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 18:22:04 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have been trying to get RED with ECN working on 2.6.x kernel for a few weeks 
now without any positive results. My setup is as follows

A 2.6.15 kernel running on a linux box configured as a router. I used the 
following command to add/replace the existing default qdisc of the NIC

tc qdisc replace dev eth3 root red limit 7000 min 1600 max 3500 avpkt 1000 burst 
3 probability 0.5 bandwidth 512 ecn

I am able to verify with "tc -s -d qdisc" that the RED qdisc does get attached 
to my outgoing interface, eth3. With such low values, I was expecting a lot of 
packets being marked ECN style i.e. ip.ce = 1. However, the statistics show no 
packet being marked or dropped. I inserted printk statements in sch_red.c to 
print the computed average queue length and the backlog. Both parameters are 0 
for the entire flow. 

This makes me wonder whether there is something wrong that I have been doing 
(most likely) or is there something wrong in the code. Any advice/help will be 
very helpfull. Please CC me in replies as I am not subscribed to the mailing 
list.

Thanks,
Rahul.
