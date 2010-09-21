From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net/sched/sch_hfsc.c: initialize parent's cl_cfmin properly
 in init_vf()
Date: Tue, 21 Sep 2010 17:00:46 +0200
Message-ID: <4C98C89E.6080103@trash.net>
References: <8100ed4475ac7a301a3d69611e97d510ea498c5d.1283197803.git.soltys@ziu.info>	<20100901.143038.170100274.davem@davemloft.net>	<4C910869.1050800@trash.net> <20100917.164127.09754402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: soltys@ziu.info, denys@visp.net.lb, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38746 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756195Ab0IUPAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 11:00:48 -0400
In-Reply-To: <20100917.164127.09754402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 18.09.2010 01:41, schrieb David Miller:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 15 Sep 2010 19:54:49 +0200
> 
>> Am 01.09.2010 23:30, schrieb David Miller:
>>> From: Michal Soltys <soltys@ziu.info>
>>> Date: Mon, 30 Aug 2010 23:34:10 +0200
>>>
>>>> This patch fixes init_vf() function, so on each new backlog period parent's
>>>> cl_cfmin is properly updated (including further propgation towards the root),
>>>> even if the activated leaf has no upperlimit curve defined.
>>>>
>>>> Signed-off-by: Michal Soltys <soltys@ziu.info>
>>>
>>> Applied, thanks.
>>
>> For the record, the patch seems fine to me. The root cause seems to be
>> an optimization I introduced (pre-git, even history.git unfortunately)
>> in vttree_get_minvt() that wasn't present in the original version:
>>
>> static struct hfsc_class *
>> vttree_get_minvt(struct hfsc_class *cl, u64 cur_time)
>> {
>>         /* if root-class's cfmin is bigger than cur_time nothing to do */
>>         if (cl->cl_cfmin > cur_time)
>>                 return NULL;
> 
> Actually, the HFSC scheduler was added with this test present.
> The function had a different name, actlist_get_minvt(), at the
> time.  See commit:
> 
> commit 6e22ce74ea0666a869ce82f418ce78b5be089fb4
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Wed Jan 28 20:15:03 2004 -0800
> 
>     [NET_SCHED]: Add HFSC packet scheduler.
> 
> in the history-2.6 GIT tree.

Indeed, what I meant to say was that I made this optimization
before HFSC was added to BitKeeper, so there's no changelog
present for this particular optimization.
