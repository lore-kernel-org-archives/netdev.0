From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Using HTB over MultiQ
Date: Fri, 08 Nov 2013 07:11:40 -0800
Message-ID: <527CFF2C.2020605@intel.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>  <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>  <1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>  <527BA63F.7040900@intel.com>  <CAEzD07JwrnqeB35BiTC2ztpyei2KNDtYO8zuewicKNBwyxmOtQ@mail.gmail.com> <1383923220.9412.236.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44486 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757410Ab3KHPLu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 10:11:50 -0500
In-Reply-To: <1383923220.9412.236.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/8/2013 7:07 AM, Eric Dumazet wrote:
> On Fri, 2013-11-08 at 18:53 +0400, Anton 'EvilMan' Danilov wrote:
>
>> Over 60 percent of 'perf top' is _raw_spin_lock function.
>> Speed of traffic is near 6Gbit/s, packet rate ~ 1.3 Mpps. But this
>> speed are limited by shaper.
>
> Please post :
>
> ethtool -S eth0  # or other nics
>
> perf record -a -g sleep 10
>
> perf report | tail -n 200
>
> And possibly it would be nice if you send your tc script so that we can
> check ;)
>

perf would be interesting but note that multiq still uses the root qdisc
lock which you original stated you were trying to avoid.

mq and mqprio are really the only two existing qdiscs that work well for
performance with small packet sizes and multiqueue nics at least in my
experience/setup with these kinds of micro-benchmarks.

.John
