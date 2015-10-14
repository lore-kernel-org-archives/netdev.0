From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 2/4] net_sched: update hierarchical backlog too
Date: Wed, 14 Oct 2015 08:11:15 -0400
Message-ID: <561E4663.4080101@mojatatu.com>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
 <1444675083-9825-3-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35728 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855AbbJNMLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 08:11:18 -0400
Received: by iofl186 with SMTP id l186so52687371iof.2
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 05:11:18 -0700 (PDT)
In-Reply-To: <1444675083-9825-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/15 14:38, Cong Wang wrote:
> When the bottom qdisc decides to, for example, drop some packet,
> it calls qdisc_tree_decrease_qlen() to update the queue length
> for all its ancestors, we need to update the backlog too to
> keep the stats on root qdisc accurate.
>


There is more than one change in there (the codel change seems
out of place and i wasnt sure why it was needed).
Also it seems possible you are double-dipping in some cases;
i dont have time to scrutinize - but looking at codel_change() change
when the queue limit is exceeded you will end up affecting backlog from
both qdisc_qstats_backlog_dec() and your new
qdisc_tree_reduce_backlog()

BTW: Codel usage of looking at queue limit during control update
seems strange.

cheers,
jamal
