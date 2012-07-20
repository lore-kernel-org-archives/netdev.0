From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: Re: [PATCH] b44: add 64 bit stats
Date: Thu, 19 Jul 2012 21:56:30 -0400
Message-ID: <CABF+-6XVCTDZedzcp-gWACYpG9NLmZUdwW2zsXC8WNKWk3dE5w@mail.gmail.com>
References: <CABF+-6XaYk8qXnFNXF_+rQ144jyDFgFqDVKsuZv+S_0VZxBAvw@mail.gmail.com>
	<1342337165.3265.10640.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:41239 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614Ab2GTB4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 21:56:31 -0400
Received: by vbbff1 with SMTP id ff1so2519810vbb.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 18:56:30 -0700 (PDT)
In-Reply-To: <1342337165.3265.10640.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Sun, Jul 15, 2012 at 3:26 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> So you must use u64_stats_fetch_begin_bh()
>
> Because on 32bit, uniprocessor, u64_stats_fetch_begin() only disables
> preemption. (there is no seqlock in syncp)
>
> So softirq are allowed to interrupt you and corrupt your stats while you
> read them, and you dont notice you have to retry.

I am still trying to make sure I understand this fully.  I want to
update some other drivers with 64 bit stats as well.  What you said
seems to make sense, but...

I was looking at the virtio_net.c driver.  One spot in this driver
which updates the stats is the receive_buf function.  recive_buf is
called from virtnet_poll which is registered as a napi poll function.
According to Documentation/networking/netdevices.txt the poll function
is called in a softirq context.  However, the function which reads the
stats uses u64_stats_fetch_begin/u64_stats_fetch_retry.  Shouldn't
this be u64_stats_fetch_begin_bh/u64_stats_fetch_retry_bh for the
exact reasons you described for my b44 patch?


Kevin
