From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH v1 3/3] net: sched: do not use tcf_proto 'tp'
 argument from call_rcu
Date: Mon, 6 Oct 2014 10:05:06 -0700
Message-ID: <CAHA+R7Ne31LRdMgt3M=1GGDbR330XpMZwdXb+5yPPsy+BVDRVw@mail.gmail.com>
References: <20141006042335.6010.27000.stgit@nitbit.x32>
	<20141006042850.6010.176.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:39845 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbaJFRFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 13:05:07 -0400
Received: by mail-la0-f45.google.com with SMTP id q1so4802175lam.18
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 10:05:06 -0700 (PDT)
In-Reply-To: <20141006042850.6010.176.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 5, 2014 at 9:28 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> Using the tcf_proto pointer 'tp' from inside the classifiers callback
> is not valid because it may have been cleaned up by another call_rcu
> occuring on another CPU.
>
> 'tp' is currently being used by tcf_unbind_filter() in this patch we
> move instances of tcf_unbind_filter outside of the call_rcu() context.
> This is safe to do because any running schedulers will either read the
> valid class field or it will be zeroed.
>
> And all schedulers today when the class is 0 do a lookup using the
> same call used by the tcf_exts_bind(). So even if we have a running
> classifier hit the null class pointer it will do a lookup and get
> to the same result. This is particularly fragile at the moment because
> the only way to verify this is to audit the schedulers call sites.
>
> Reported-by: Cong Wang <xiyou.wangconf@gmail.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Cong Wang <cwang@twopensource.com>
