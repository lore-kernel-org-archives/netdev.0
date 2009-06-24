From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [2.6.30-git21] Network Namespace test failure
Date: Wed, 24 Jun 2009 09:00:56 -0500
Message-ID: <20090624140056.GA11912@us.ibm.com>
References: <4A422F1E.3050208@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, serue@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, matthltc@us.ibm.com
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:56867 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbZFXOJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 10:09:25 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5OE7LfV021318
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 08:07:21 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5OE9Nm3078844
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 08:09:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5OE9J2e028331
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 08:09:19 -0600
Content-Disposition: inline
In-Reply-To: <4A422F1E.3050208@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Sachin Sant (sachinp@in.ibm.com):
> While executing Newtork namespace tests from LTP[1] May release,
> the machine crashed with following o/p. This is a PowerPC
> blade(Power 6)

...

> The corresponding c code (veth_xmit) is:
>
> 9cc:   3b 44 06 00     addi    r26,r4,1536
>
>        cpu = smp_processor_id();
>        stats = per_cpu_ptr(priv->stats, cpu);
> 9d0:   79 6b 1f 24     rldicr  r11,r11,3,60
> 9d4:   7d 4a 50 f8     not     r10,r10
>        rcv_stats = per_cpu_ptr(rcv_priv->stats, cpu);
> 9d8:   e9 3a 00 08     ld      r9,8(r26)
>        priv = netdev_priv(dev);
>        rcv = priv->peer;
>        rcv_priv = netdev_priv(rcv);
>
>        cpu = smp_processor_id();
>        stats = per_cpu_ptr(priv->stats, cpu);
> 9dc:   7f 8b 50 2a     ldx     r28,r11,r10
>        rcv_stats = per_cpu_ptr(rcv_priv->stats, cpu);
> ^^^^^ PC points to this instruction ^^^^^
>
> I haven't tried these tests earlier so not sure if this
> is a new problem or not. Let me know if there is any
> other information you would like.

Precise kernel version and .config?

thanks,
-serge
