From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][RFC] cxgb4: Not need to hold the adap_rcu_lock lock
 when read adap_rcu_list
Date: Mon, 23 Jun 2014 23:38:23 -0700
Message-ID: <1403591903.27425.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1403256756-6557-1-git-send-email-rongqing.li@windriver.com>
	 <20140623.145035.915335524137481573.davem@davemloft.net>
	 <53A8ABAD.9090904@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rongqing.li@windriver.com,
	netdev@vger.kernel.org, hariprasad@chelsio.com,
	greearb@candelatech.com
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:37195 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbaFXGi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 02:38:28 -0400
Received: by mail-wi0-f177.google.com with SMTP id r20so5261304wiv.4
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2014 23:38:26 -0700 (PDT)
In-Reply-To: <53A8ABAD.9090904@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-23 at 15:35 -0700, Casey Leedom wrote:
> On 06/23/14 14:50, David Miller wrote:
> > From: <rongqing.li@windriver.com>
> > Date: Fri, 20 Jun 2014 17:32:36 +0800
> >
> >> cxgb4_netdev maybe lead to dead lock, since it uses a spin lock, and be called
> >> in both thread and softirq context, but not disable BH, the lockdep report is
> >> below; In fact, cxgb4_netdev only reads adap_rcu_list with RCU protection, so
> >> not need to hold spin lock again.
> > I think this change is fine, and correct, but I would like to see some
> > reviews from the cxgb4 maintainers.
> 
>    Thanks David.  Hari is gone on PTO so I think I'm the next logical 
> person ... :-)
> 
>    I've gone back and reviewed the original patch, Eric Dumazet6's reply 
> and revised patch and compared that against this proposed patch.  Li 
> RongQing is submitting the same patch that Eric suggested with the 
> addition of a call to synchronize_rcu() the in driver remove() 
> function.  I'm not super familiar with the RCU system but that addition 
> certainly seems innocuous enough.  Other than that, everything looks fine.

Yes, the synchronize_rcu() is needed.

In fact I do not really understand why RCU was even used in this slow
path...
