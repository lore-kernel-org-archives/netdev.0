From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net 2/2] net_sched: always call ->destroy when ->init() fails
Date: Fri, 24 Oct 2014 17:53:33 -0700
Message-ID: <CAHA+R7NBr_K4fZ-nr2hi+isbxJt92D9o-q+n9xq5Y1rHv14F7Q@mail.gmail.com>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
	<1414194959-28006-2-git-send-email-xiyou.wangcong@gmail.com>
	<1414196053.20845.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141025003644.GB11289@acer.localdomain>
	<CAHA+R7M3y=Mj_L3yL0UM41mfGa+go+Kq4wYga7D6epY3uq_yWQ@mail.gmail.com>
	<20141025004403.GC11289@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Wang Bo <wang.bo116@zte.com.cn>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Terry Lam <vtlam@google.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:62422 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111AbaJYAxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 20:53:34 -0400
Received: by mail-qg0-f53.google.com with SMTP id q107so1786253qgd.40
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 17:53:33 -0700 (PDT)
In-Reply-To: <20141025004403.GC11289@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 5:44 PM, Patrick McHardy <kaber@trash.net> wrote:
> On Fri, Oct 24, 2014 at 05:38:48PM -0700, Cong Wang wrote:
>> On Fri, Oct 24, 2014 at 5:36 PM, Patrick McHardy <kaber@trash.net> wrote:
>> >
>> > Again, the correct fix is to make qdisc_create_dflt() not call
>> > qdisc_destroy() but clean up the qdisc manually as done in
>> > qdisc_create().
>>
>> I kindly wish you a good luck with fixing all callers of qdisc_create_dflt().
>> Go ahead. :)
>
> Here you go:
>

...

Did you check all ->init() call ->destroy() on failure? Look at the
sch_pie I have fixed in 1/2.

Also check those xxx_init() calling xxx_change().

Really, we don't have to make all ->init() doing cleanup by itself.
