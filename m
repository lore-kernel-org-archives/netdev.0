From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] neighbour.c: Avoid GC directly after state change
Date: Wed, 22 Apr 2015 19:46:59 +0900
Message-ID: <55377C23.1010400@miraclelinux.com>
References: <1426107673-45049-1-git-send-email-netdev@emagii.com> <20150312.142621.1128728353472907283.davem@davemloft.net> <5527892D.4020608@ericsson.com> <552F45AA.6010906@miraclelinux.com> <5530BE40.1000504@ericsson.com> <55346580.6060801@miraclelinux.com> <5534F5B8.1030405@ericsson.com> <5535CB00.4060209@miraclelinux.com> <553750CC.8010003@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Ulf Samuelsson <ulf.samuelsson@ericsson.com>, netdev@emagii.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og127.obsmtp.com ([64.18.2.210]:51994 "HELO
	exprod7og127.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756513AbbDVKrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 06:47:05 -0400
Received: by mail-pa0-f49.google.com with SMTP id sx10so269521815pab.3
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 03:47:04 -0700 (PDT)
In-Reply-To: <553750CC.8010003@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ulf Samuelsson wrote:
> 
> On 04/21/2015 05:58 AM, YOSHIFUJI Hideaki wrote:
>> Ulf Samuelsson wrote:
>>>> How many neighbors do you want to maintain?
>>>> I guess you have to increase the number of gc_thresh1.
>>> The current use cases have up to 2048 entries.
>>> This is expected to grow in the future.
>>> The 3.4 kernel used in the system today is limited to 1024,
>>> but that has been raised to about 10k.
>>>
>>> The gc_thresh1 test is not implemented in 3.4 but can be backported,
>>> but still not convinced it is a good idea.
>> Why?
>>
> A good solution makes sure that:
> * equipment which is connected NEVER IS garbage collected
> * equipment which is disconnected IS garbage collected.
> 
> The threshold idea does not meet the criteria for a good solution.

We try providing "good solution" if you have less than gc_thresh1
entries only.  Otherwise, we try hard to protect ourselves.


> With this solution you keep unnecessary entries in the table.
> If you ever pass the limit, then equipment which should not
> be garbage collected may be.
> It relies on someone keeping track of traffic loss,
> so needs more maintenance by the SysOp.try pr
> 
> The ARP probes should be considered to be NECESSARY traffic
> to maintain a quality link.
> Obviously not everyone would want to make this trade-off.
> 
> 
>>> To complicate things, one requirement is that for some interfaces
>>> you always want to keep things alive, if connected, but
>>> for other interfaces you want things to be removed
>>> to conserve memory.
>>> Actually you would want to do this selection on a subnet level.
>> If you want to introduce per-interface parameter, I am okay with it.
>>
>>> Internal discussions resulted in a proposal to change the patch,
>>> so that you have a "keepalive" flag which is tested after
>>> it has been decided to exit the REACHABLE state.
>>>
>>> if the "keepalive" flag is set, you always go to DELAY state from REACHABLE.
>> No.
>>
> And why is it a bad idea to have a high quality connection?

We reclaim neighbor entries as much as possible to protect
ourselves if the number is below gc_thresh1.  We could stop
purging entries, but the idea was rejected AFAIK.  That is
our design.

Again, you should increase gc_thresh1, first.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
