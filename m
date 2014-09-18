From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 2/2] net: sched: cls_u32 changes to knode must
 appear atomic to readers
Date: Thu, 18 Sep 2014 09:39:45 -0700
Message-ID: <541B0AD1.9070600@gmail.com>
References: <20140917191131.20529.91136.stgit@nitbit.x32> <20140917191202.20529.87231.stgit@nitbit.x32> <CAHA+R7NWzv8+2aUM1uQX8uZkQv-Dp9fYb0SNwmZqk3gKvXVWtw@mail.gmail.com> <541A21F8.3000206@gmail.com> <CAHA+R7Nk6kO_eXLYppwimX5Cp-QpzHGVo4yHCO+4xSf-kcpqkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:46776 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117AbaIRQkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 12:40:05 -0400
Received: by mail-ie0-f169.google.com with SMTP id tp5so1615757ieb.28
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 09:40:04 -0700 (PDT)
In-Reply-To: <CAHA+R7Nk6kO_eXLYppwimX5Cp-QpzHGVo4yHCO+4xSf-kcpqkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2014 09:28 AM, Cong Wang wrote:
> On Wed, Sep 17, 2014 at 5:06 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>>
>> Sure how about this,
>>
>> /* u32_delete_key_rcu_pf should be called when free'ing a copied
>>   * version of a tc_u_knode obtained from u32_init_knode(). When
>>   * copies are obtained from u32_init_knode() the statistics are
>>   * shared between the old and new copies to allow readers to
>>   * continue to update the statistics during the copy. To support
>>   * this the u32_delete_key_rcu_pf variant does not free the percpu
>>   * statistics.
>>   */
>>
>
> Looks good, but why you pick the name u32_delete_key_rcu_pf()?
> It sounds like you will free pf, but actually you will skip freeing pf. :)
>

hmm it was just the first thing that came to mind.

I'll rename the two calls to make it clear when reading the code.

Thanks,
John

-- 
John Fastabend         Intel Corporation
