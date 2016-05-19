From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: remove busylock
Date: Thu, 19 May 2016 12:35:23 -0700
Message-ID: <1463686523.18194.232.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
	 <1463684190.18194.228.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33872 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753910AbcESTf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 15:35:27 -0400
Received: by mail-pa0-f66.google.com with SMTP id yl2so8726267pac.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 12:35:26 -0700 (PDT)
In-Reply-To: <1463684190.18194.228.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-19 at 11:56 -0700, Eric Dumazet wrote:

> Removing busylock helped in all cases I tested. (at least on x86 as
> David pointed out)
> 
> As I said, we need to revisit busylock now that spinlocks are different.
> 
> In one case (20 concurrent UDP netperf), I even got a 500 % increase.
> 
> With busylock :
> 
> lpaa5:~# sar -n DEV 4 4|grep eth0
> Average:         eth0     12.19 112797.12      1.95  37672.28      0.00      0.00      0.69
> 


Hmpf, my sysctl logic was inverted. Really these results made little
sense.

Sorry for the noise. At least we have 8% confirmed gain with this
stuff ;)

> Presumably it would tremendously help if the actual kfree_skb()
> was done after qdisc lock is released, ie not from the qdisc->enqueue()
> method.
> 

This part is still valid.

We could have a per cpu storage of one skb pointer, so that we do not
have to change all ->enqueue() prototypes.
