From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sched/sch_hfsc.c: initialize parent's cl_cfmin
 properly in init_vf()
Date: Fri, 17 Sep 2010 16:41:27 -0700 (PDT)
Message-ID: <20100917.164127.09754402.davem@davemloft.net>
References: <8100ed4475ac7a301a3d69611e97d510ea498c5d.1283197803.git.soltys@ziu.info>
	<20100901.143038.170100274.davem@davemloft.net>
	<4C910869.1050800@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: soltys@ziu.info, denys@visp.net.lb, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47607
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751136Ab0IQXlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 19:41:08 -0400
In-Reply-To: <4C910869.1050800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 15 Sep 2010 19:54:49 +0200

> Am 01.09.2010 23:30, schrieb David Miller:
>> From: Michal Soltys <soltys@ziu.info>
>> Date: Mon, 30 Aug 2010 23:34:10 +0200
>> 
>>> This patch fixes init_vf() function, so on each new backlog period parent's
>>> cl_cfmin is properly updated (including further propgation towards the root),
>>> even if the activated leaf has no upperlimit curve defined.
>>>
>>> Signed-off-by: Michal Soltys <soltys@ziu.info>
>> 
>> Applied, thanks.
> 
> For the record, the patch seems fine to me. The root cause seems to be
> an optimization I introduced (pre-git, even history.git unfortunately)
> in vttree_get_minvt() that wasn't present in the original version:
> 
> static struct hfsc_class *
> vttree_get_minvt(struct hfsc_class *cl, u64 cur_time)
> {
>         /* if root-class's cfmin is bigger than cur_time nothing to do */
>         if (cl->cl_cfmin > cur_time)
>                 return NULL;

Actually, the HFSC scheduler was added with this test present.
The function had a different name, actlist_get_minvt(), at the
time.  See commit:

commit 6e22ce74ea0666a869ce82f418ce78b5be089fb4
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 28 20:15:03 2004 -0800

    [NET_SCHED]: Add HFSC packet scheduler.

in the history-2.6 GIT tree.
