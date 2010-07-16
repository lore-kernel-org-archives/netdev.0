From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH RFC] act_cpu: packet distributing
Date: Fri, 16 Jul 2010 09:16:08 -0400
Message-ID: <1279286168.4303.118.camel@bigi>
References: <1279077475-2956-1-git-send-email-xiaosuo@gmail.com>
	 <1279078875.2444.103.camel@edumazet-laptop>
	 <AANLkTimPmXWyAspJqnya7aM_vDRNzDdJJf2bl7CYrAXN@mail.gmail.com>
	 <1279198139.4510.710.camel@bigi>
	 <1279212897.2496.133.camel@edumazet-laptop>
	 <AANLkTiljdBpQkZAGybwFQtej-_j7sFtD72CTErT9TaOX@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:60645 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965234Ab0GPNQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 09:16:11 -0400
Received: by gxk23 with SMTP id 23so1189294gxk.19
        for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 06:16:11 -0700 (PDT)
In-Reply-To: <AANLkTiljdBpQkZAGybwFQtej-_j7sFtD72CTErT9TaOX@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-07-16 at 07:30 +0800, Changli Gao wrote:

> The tcf_lock is per-instance, so I should not an issue here if the
> corresponding NIC isn't an multiqueue NIC or the instance is
> per-rx-queue. 

It has more to do with config. Actions can be explicitly pointed to 
using the index parameter. Example for configuring two flows using an
aggregate rate with a policer instance 1:
tc filter add dev eth0 ... u32 flow1 action police blah index 1
tc filter add dev eth2 .... u32 flow2 action police blah index 1

If you dont configure it such that multiple tc flows share the same
action as above, then likely the same cpu will always grab the lock. It
is still costly as Eric points out - but i will be very curious to find
out the results.

> I agree
> the performance data is necessary and I'll publish it in the formal
> patch.

If you do this, please compare against rps and non-rps and then i feel
motivated to volunteer to create a setup (not in July unfortunately) to
do a similar test on your code and compare against rps on a
nehalem-with-shitty-sky2 that i can get time on.

cheers,
jamal

