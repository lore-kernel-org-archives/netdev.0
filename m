From: Martin Lau <kafai@fb.com>
Subject: Re: [Question] net/mlx4_en: Memory consumption issue with mlx4_en
 driver
Date: Thu, 12 Mar 2015 09:56:47 -0700
Message-ID: <20150312165647.GD1032293@devbig242.prn2.facebook.com>
References: <20150311185146.GA1032293@devbig242.prn2.facebook.com>
 <1426105262.11398.66.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58375 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932487AbbCLQ4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 12:56:55 -0400
Content-Disposition: inline
In-Reply-To: <1426105262.11398.66.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 01:21:02PM -0700, Eric Dumazet wrote:
> You know, even the order-3 allocations done for regular skb allocations
> will hurt you : a single copybreaked skb stored a long time in a tcp
> receive queue will hold 32KB of memory.
> 
> Even 4KB can lead to disasters.
Thanks for the pointer.  I look a little deeper at the allocation in skbuff.c.
I can see your point.

> You could lower tcp_rmem so that collapsing happens sooner.
It is what we did.  However, a buggy process accommodated enough stalled
sockets (stop reading from it but not closing it) will re-surface the problem.

Thanks,
--Martin
