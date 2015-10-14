From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 3/4] sch_htb: update backlog as well
Date: Wed, 14 Oct 2015 08:25:01 -0400
Message-ID: <561E499D.7060402@mojatatu.com>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
 <1444675083-9825-4-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33329 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbbJNMZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 08:25:04 -0400
Received: by iodv82 with SMTP id v82so52948558iod.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 05:25:03 -0700 (PDT)
In-Reply-To: <1444675083-9825-4-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/15 14:38, Cong Wang wrote:
> It is odd to see qlen!=0 but backlog==0, for a real example:
>

Backlog is a transient stat so a lot of times it should be 0. Only when
the CPU is sending faster than the link can handle should you see
the backlog grow (and eventually drain to 0).

Even though your explanation above is inaccurate I think the spirit
of the patch looks reasonable. i.e keeping track of all additions to
the queue and removals from the queue in the backlog stats is useful.
However, you need to be extremely careful: This should only be done
at exactly the spot the packet is enqueued (and not by a parent's
enqueue asking for hierarchical enques).

I think some more work is needed Cong for this general patchset.

cheers,
jamal

> qdisc htb 1: dev eth0 root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver 3.17
>   Sent 172680457356 bytes 222469449 pkt (dropped 0, overlimits 123575834 requeues 0)
>   backlog 0b 72p requeues 0
>
> So we need to update backlog too when we update qlen.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
