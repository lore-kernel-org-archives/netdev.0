From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 00/54][pull request] Using dev_kfree/consume_skb_any
 for functions called in multiple contexts
Date: Tue, 25 Mar 2014 13:49:51 -0700
Message-ID: <1395780591.12610.185.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	 <20140311.124907.1180556684992271103.davem@davemloft.net>
	 <87wqg0cy9d.fsf@xmission.com>
	 <20140311.160931.1395978386605601765.davem@davemloft.net>
	 <87r468bfqj.fsf_-_@xmission.com> <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:53746 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755227AbaCYUtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 16:49:53 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so942941pdj.6
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 13:49:53 -0700 (PDT)
In-Reply-To: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 22:58 -0700, Eric W. Biederman wrote:
> These changes are a result of walking through the network drivers
> supporting netpoll and verifying the code paths that netpoll can cause
> to be called in hard irq context use an appropriate flavor of
> kfree_skb.  Either dev_kfree_skb_any or dev_consume_skb_any.
> 
> Since my last pass at this I have become aware of the small differences
> between dev_kfree_skb_any and dev_consume_skb_any.
> net/core/drop_monitor.c reports the dev_kfree_skb_any as a drop and
> while being quite about the second.  With the weird twist that
> dev_kfree_skb is unintuitively consume_skb.
> 
> As netpoll now calls the napi poll function with budget == 0, pieces of
> a drivers the napi poll function that don't run when budget == 0 have
> been ignored.
> 
> The most interesting change is to the atl1c which tried unsuccesfully to
> tell one of it's functions which context it is called in so that it
> could call dev_kfree_skb_irq or dev_kfree_skb as appropriate.  I have
> just removed the extra parameter and called dev_consume_skb_any.
> 
> At 54 separate changes I will post each change as a separate patch (so
> they can be reviewed) but for general sanity sake I have gathered them
> all into a git branch for easy acces.
> 
> David when you are satisified with these changes please pull:
> 
>     git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master
> 
> Hopefully this will allow me to forget this class of error when dealing
> with netpoll.


Perfect, thanks Eric.

(the minor issues can be addressed later in a single followup)

Acked-by: Eric Dumazet <edumazet@google.com>
