From: Tom Herbert <therbert@google.com>
Subject: Very low latency TCP for clusters
Date: Mon, 19 Jul 2010 10:05:19 -0700
Message-ID: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:32447 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750Ab0GSRF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 13:05:26 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o6JH5NbT001337
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 10:05:24 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by wpaz33.hot.corp.google.com with ESMTP id o6JH5Kvh028838
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 10:05:22 -0700
Received: by pxi6 with SMTP id 6so2067017pxi.15
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 10:05:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have been looking at best case TCP latencies that might be achieved
within a cluster (low loss fabric).  The goal is to have latency
numbers roughly comparable to that which can be produced using RDMA/IB
in a low latency configuration  (<5 usecs round trip on netperf TCP_RR
test with one byte data for directly connected hosts as a starting
point).  This would be without changing sockets API, fabric, and
preferably not using TCP offload or a user space stack.

I think there are at least two techniques that will drive down TCP
latency: per connection queues and polling queues.  Per connection
queues (supported by device) should eliminate costs of connection
look-up, hopefully some locking.  Polling becomes viable as core
counts on systems increase, and burning a few CPUs for networking
polling on behalf of very low-latency threads would be reasonable.

Are there any efforts in progress to integrate per connection queues
in the stack or integrate polling of queues?

Thanks,
Tom
