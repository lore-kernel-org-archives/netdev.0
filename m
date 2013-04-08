From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] Make sure GRED backlog does not get screwed up.
Date: Mon, 08 Apr 2013 06:26:44 -0400
Message-ID: <51629B64.2020406@mojatatu.com>
References: <CAD-Y_xtAvq5+mVe-=VDCDntY-NE2Oq+mhv56g6d8Tb2uiHw6bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Magnus Gille <mgille@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:49050 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965169Ab3DHK07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 06:26:59 -0400
Received: by mail-ie0-f177.google.com with SMTP id tp5so6482401ieb.8
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 03:26:58 -0700 (PDT)
In-Reply-To: <CAD-Y_xtAvq5+mVe-=VDCDntY-NE2Oq+mhv56g6d8Tb2uiHw6bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

please use my proper address (in the From:) for faster response.

On 13-04-02 02:32 PM, Magnus Gille wrote:
> First patch, comments, feedback, suggestions are welcome. Before this patch
> we could end up with a 4GB backlog on certain DPs without any packets. The
> patch is created against net-next.
>
> If a packet is enqueued on a GRED qdisc before the DPs are setup the packet
> will not be accounted for in the DP backlog queue.

In such a case, the packet will end up in the default queue

>   When the packet later
> gets
> dequeued from the DP queue it will subtract the length from the DP backlog
> but,
> since the packet was never accounted for we now wrap the backlog around.
> Fixed
> this by making sure we never subtract more than what's present in the
> backlog.

When no DPs set: if the packet was enqueued in a default queue,
at dequeue it will be pulled from the default queue.
What am i missing?

cheers,
jamal
