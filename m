From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] sched, cls: check if we could overwrite actions when
 changing a filter
Date: Mon, 21 Apr 2014 16:28:39 -0700
Message-ID: <CAM_iQpVM-djLiz9Z9Bhz9zac88m8b6t1S-SRUkRxYhOaW_xJvQ@mail.gmail.com>
References: <1397605563-29756-1-git-send-email-xiyou.wangcong@gmail.com>
	<534E77D0.8000307@mojatatu.com>
	<CAM_iQpXRVZ8_keaL-8OkmRVguA29bnTPS2ZHZ0j2SSeB6A=1jQ@mail.gmail.com>
	<534FBFF0.3020606@mojatatu.com>
	<CAM_iQpVqQbXcm0gGxe_JMURPtGYH+iOi8UGgvis5je6g9zbiKQ@mail.gmail.com>
	<53513619.5060202@mojatatu.com>
	<CAM_iQpX13QBbGnsKfD1oL6t331-=wRWFU_0ktdtgngpfE1Z6nA@mail.gmail.com>
	<535259C3.10404@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:38618 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211AbaDUX2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 19:28:40 -0400
Received: by mail-oa0-f51.google.com with SMTP id i4so4830357oah.24
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 16:28:40 -0700 (PDT)
In-Reply-To: <535259C3.10404@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 19, 2014 at 4:10 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 04/18/14 13:18, Cong Wang wrote:
>> IOW, what's wrong with changing if (icmp) { A } to if (icmp) { B } ?
>> where A and B could be any complex combination of actions.
>> RTNL lock guarantees this is transactional.
>>
>
> RTNL is one dimension. The other is the datapath processing.
> You need to make sure that packets still flow correctly during the
> change over.

Sure, since we grab tcf_tree_lock() before changing actions in
tcf_exts_change(), I think this is guaranteed too.


>
>> I never mean to only add or remove one of them inside, although
>> my specific case is just for appending, my patch should allow to
>> overwrite all the actions together.
>>
>
> Well - then go nuts and put out a patch.
> Replace _all or none_ is a reasonable approach.
>
>

Great! We both agree on this.

Looking at the current code, we first initialize a list of actions
and then replace them as a whole by splicing the lists with
tcf_tree_lock held, so this is already done. IOW, this patch
is enough.

Or am I missing anything?

Thanks!
