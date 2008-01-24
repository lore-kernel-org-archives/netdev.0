From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH] [IPV4] route: fix locking in rt_run_flush()
Date: Thu, 24 Jan 2008 14:06:22 +0900
Message-ID: <b25c3fa70801232106l59aa637dxadd2c7881925af14@mail.gmail.com>
References: <12009281372201-git-send-email-joonwpark81@gmail.com>
	 <20080121.024043.105024413.davem@davemloft.net>
	 <20080123074320.GB9017@ehus.geninetworks.com>
	 <4797A729.4030006@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.185]:28293 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbYAXFGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 00:06:23 -0500
Received: by rv-out-0910.google.com with SMTP id k20so104404rvb.1
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 21:06:22 -0800 (PST)
In-Reply-To: <4797A729.4030006@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/1/24, Eric Dumazet <dada1@cosmosbay.com>:
>
> Unfortunatly, your patch doesnt work on CONFIG_SMP=n (softirq will be disabled
> for the whole scan of table)
>
> Also, some machines around there have 2^22 slots in hash table, and NR_CPUS=4,
> so softirqs will be disabled for a too long time.
>
> Please try net-2.6.25 and submit patches on top of it if necessary, since
> rt_run_flush() has pending changes, not in net-2.6
>
> Note : The 'soft lockup' can be avoided by other means.
>
>

Eric,
Thank you for your help.

I checked net-2.6.25 in this morining :(
And it brought me a conclusion that the fashion of it is the best solution for
the all circumstances.

I believe that
 'cond_resched()'
and
 'if (!rth) continue' without disable softirq
of net-2.6.25 is correct answer.

Thanks again!
Joonwoo
