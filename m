From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] remove netpoll rx support
Date: Tue, 11 Mar 2014 05:24:49 -0700
Message-ID: <1394540689.21721.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <871ty9qvaf.fsf_-_@xmission.com>
	 <87vbvlpgnk.fsf_-_@xmission.com>
	 <1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140311.004217.1616529960369263682.davem@davemloft.net>
	 <1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a9cxf7mp.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:59194 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754639AbaCKMYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 08:24:51 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so8478021pdj.34
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 05:24:50 -0700 (PDT)
In-Reply-To: <87a9cxf7mp.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-11 at 01:43 -0700, Eric W. Biederman wrote:

> It does seem desirable that netpoll should not drain the rx queues.
> Unfortunately that is not how netpoll is built.  By my quick count
> there are 132 drivers in the kernel that support netpoll.
> 
> Several of them such as the e1000e driver already call dev_kfree_skb_any
> or dev_kfree_skb_irq in their rx paths.  What I am implementing seems to
> be the pattern that the better drivers follow today.
> 
> Furthermore netpoll by it's design depends on the ability to receive
> packets in netpoll_poll_dev.  It is a capability I don't think we have
> ever used in the mainline kernel but it is a capability that is there
> deliberately.  Which means if we want netpoll to not mess with the rx
> path we need to change netpoll.
> 
> 
> If we are willing to change the definition of netpoll this is fixable.
> 
> The big enabler is the fact that calling the napi poll function with a
> budget of 0 means don't perform any rx work.
> 
> Which leads to the following set of changes to netpoll if we are brave.

Well, it cannot be worse than current situation, right ?

I never understood and never enabled CONFIG_NETPOLL_TRAP on any of my
builds, I can tell you.
