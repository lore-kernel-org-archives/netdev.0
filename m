From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Patch net-next] net_sched: avoid calling tcf_unbind_filter()
 in call_rcu callback
Date: Thu, 02 Oct 2014 11:04:50 -0700
Message-ID: <542D93C2.1010407@gmail.com>
References: <1412118444-29179-1-git-send-email-xiyou.wangcong@gmail.com> <1412118444-29179-2-git-send-email-xiyou.wangcong@gmail.com> <20141001.220123.1054083748022563765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:38922 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbaJBSFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 14:05:03 -0400
Received: by mail-ob0-f177.google.com with SMTP id uy5so1716716obc.22
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 11:05:02 -0700 (PDT)
In-Reply-To: <20141001.220123.1054083748022563765.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2014 07:01 PM, David Miller wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 30 Sep 2014 16:07:24 -0700
>
>> This fixes the following crash:
>   ...
>> tp could be freed in call_rcu callback too, the order is not guaranteed.
>>
>> Cc: John Fastabend <john.r.fastabend@intel.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> Applied, and I added John's description of why this is legal to the
> commit message.
> --

Thanks, I'll have another series shortly to fix the
other classifiers with the same issue and pull 'tp'
out of the ematch stuff.

Passing around free'd pointers that never get used
through the ematch code wont cause a crash but there is
no reason to propagate it like this.

.John

-- 
John Fastabend         Intel Corporation
