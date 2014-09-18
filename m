From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH 2/2] net: sched: cls_u32 changes to knode must
 appear atomic to readers
Date: Thu, 18 Sep 2014 09:28:05 -0700
Message-ID: <CAHA+R7Nk6kO_eXLYppwimX5Cp-QpzHGVo4yHCO+4xSf-kcpqkw@mail.gmail.com>
References: <20140917191131.20529.91136.stgit@nitbit.x32>
	<20140917191202.20529.87231.stgit@nitbit.x32>
	<CAHA+R7NWzv8+2aUM1uQX8uZkQv-Dp9fYb0SNwmZqk3gKvXVWtw@mail.gmail.com>
	<541A21F8.3000206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:42848 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756463AbaIRQ2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 12:28:08 -0400
Received: by mail-la0-f52.google.com with SMTP id gq15so1473524lab.25
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 09:28:05 -0700 (PDT)
In-Reply-To: <541A21F8.3000206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 5:06 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
> Sure how about this,
>
> /* u32_delete_key_rcu_pf should be called when free'ing a copied
>  * version of a tc_u_knode obtained from u32_init_knode(). When
>  * copies are obtained from u32_init_knode() the statistics are
>  * shared between the old and new copies to allow readers to
>  * continue to update the statistics during the copy. To support
>  * this the u32_delete_key_rcu_pf variant does not free the percpu
>  * statistics.
>  */
>

Looks good, but why you pick the name u32_delete_key_rcu_pf()?
It sounds like you will free pf, but actually you will skip freeing pf. :)
