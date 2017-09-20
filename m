From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: one perf event close won't free bpf program
 attached by another perf event
Date: Wed, 20 Sep 2017 14:12:48 -0700 (PDT)
Message-ID: <20170920.141248.405636883631460038.davem@davemloft.net>
References: <20170918233836.1817062-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, rostedt@goodmis.org, ast@fb.com,
        daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: yhs@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdITVMu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 17:12:50 -0400
In-Reply-To: <20170918233836.1817062-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yonghong Song <yhs@fb.com>
Date: Mon, 18 Sep 2017 16:38:36 -0700

> This patch fixes a bug exhibited by the following scenario:
>   1. fd1 = perf_event_open with attr.config = ID1
>   2. attach bpf program prog1 to fd1
>   3. fd2 = perf_event_open with attr.config = ID1
>      <this will be successful>
>   4. user program closes fd2 and prog1 is detached from the tracepoint.
>   5. user program with fd1 does not work properly as tracepoint
>      no output any more.
> 
> The issue happens at step 4. Multiple perf_event_open can be called
> successfully, but only one bpf prog pointer in the tp_event. In the
> current logic, any fd release for the same tp_event will free
> the tp_event->prog.
> 
> The fix is to free tp_event->prog only when the closing fd
> corresponds to the one which registered the program.
> 
> Signed-off-by: Yonghong Song <yhs@fb.com>

I've applied this and queued it up for -stable as it looks good
to me and 2 days is enough time for waiting for any other reviews.

Thanks.
