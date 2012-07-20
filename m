From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] b44: add 64 bit stats
Date: Fri, 20 Jul 2012 07:24:25 +0200
Message-ID: <1342761865.2626.5572.camel@edumazet-glaptop>
References: <CABF+-6XaYk8qXnFNXF_+rQ144jyDFgFqDVKsuZv+S_0VZxBAvw@mail.gmail.com>
	 <1342337165.3265.10640.camel@edumazet-glaptop>
	 <CABF+-6XVCTDZedzcp-gWACYpG9NLmZUdwW2zsXC8WNKWk3dE5w@mail.gmail.com>
	 <1342759989.2626.5472.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Groeneveld <kgroeneveld@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:61650 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909Ab2GTFYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 01:24:32 -0400
Received: by wibhr14 with SMTP id hr14so106147wib.1
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 22:24:31 -0700 (PDT)
In-Reply-To: <1342759989.2626.5472.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-20 at 06:53 +0200, Eric Dumazet wrote:
> On Thu, 2012-07-19 at 21:56 -0400, Kevin Groeneveld wrote:
> 
> > I am still trying to make sure I understand this fully.  I want to
> > update some other drivers with 64 bit stats as well.  What you said
> > seems to make sense, but...
> > 
> > I was looking at the virtio_net.c driver.  One spot in this driver
> > which updates the stats is the receive_buf function.  recive_buf is
> > called from virtnet_poll which is registered as a napi poll function.
> > According to Documentation/networking/netdevices.txt the poll function
> > is called in a softirq context.  However, the function which reads the
> > stats uses u64_stats_fetch_begin/u64_stats_fetch_retry.  Shouldn't
> > this be u64_stats_fetch_begin_bh/u64_stats_fetch_retry_bh for the
> > exact reasons you described for my b44 patch?
> 
> Absolutely. You can argue that probably nobody use this driver on a
> 32bit UP machine, but technically speaking the current implementation is
> racy.
> 

In fact all network drivers should use the _bh version.

Could you send a patch for all of them, based on net-next tree ?

Thanks !
