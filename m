From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v3] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Wed, 14 Apr 2010 08:28:21 -0400
Message-ID: <1271248101.3943.67.camel@bigi>
References: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
	 <1271246304.3943.60.camel@bigi>
	 <o2k412e6f7f1004140513h8de62790tb775bb357e2db6b1@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f189.google.com ([209.85.221.189]:59933 "EHLO
	mail-qy0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753365Ab0DNM2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 08:28:25 -0400
Received: by qyk27 with SMTP id 27so100686qyk.23
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 05:28:23 -0700 (PDT)
In-Reply-To: <o2k412e6f7f1004140513h8de62790tb775bb357e2db6b1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-14 at 20:13 +0800, Changli Gao wrote:
> On Wed, Apr 14, 2010 at 7:58 PM, jamal <hadi@cyberus.ca> wrote:

> No extra IPI is needed.
> 
> +       qlen = queue->input_pkt_queue.qlen + queue->processing_queue.qlen;
> +       if (qlen <= netdev_max_backlog) {
> +               if (qlen) {
> 
> the packets in processing_queue are counted too.

Ok - Looks reasonable.

> > IPIs add to latency (refer to my other email). Did you test this
> > to reach some conclusion that it improves thing or was it just by
> > inspection?
> >
> 
> :( only insepection.

I am probably being pushy, but one simple test for latency of single
flow is: 

from machine 1, send ping -f

on rps machine:
Base test: no rps on ( a fresh boot with no sysctls should do fine)
Test 1: irq affinity on cpuX, rps to cpuY 
Test 2: repeat test1 with your change.

It should show no difference between test1 and 2. If it shows
improvement better - but showing worse latency is bad.

cheers,
jamal

